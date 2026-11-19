#!/usr/bin/env bash
# 바꾼 Dart 파일이 규칙 문서(docs/CODE_STYLE.md, ARCHITECTURE.md, TESTING.md)에
# 맞는지 점검하는 스크립트. docs/AGENTS.md의 "규칙 점검 루프"에서 씁니다.
#
# 점검 대상은 기준 브랜치 이후 커밋한 파일과 아직 커밋하지 않은 파일입니다.
# - [위반] 항목에 결과가 있으면 고쳐야 합니다. 하나라도 있으면 종료 코드 1을 돌려줍니다.
# - [확인] 항목은 규칙 대상인지 사람이 판단합니다. 종료 코드에 영향을 주지 않습니다.
# - 기준 브랜치를 찾지 못하거나 바뀐 파일 목록을 모으지 못하면 종료 코드 2로 멈춥니다.
#
# 글자 패턴으로 찾기 때문에 놓치거나 잘못 잡는 경우가 있습니다. 스크립트가 통과해도
# 규칙 문서를 직접 읽고 대조하는 단계는 건너뛰지 않습니다.
#
# 사용법: tool/check_rules.sh [기준 브랜치, 기본값 main]

set -euo pipefail

readonly ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
readonly BASE_BRANCH="${1:-main}"

cd "${ROOT_DIR}"

# 기준 브랜치가 없으면 점검할 파일을 모을 수 없으므로, 통과로 보지 않고 멈춥니다.
if ! git rev-parse --verify --quiet "${BASE_BRANCH}^{commit}" >/dev/null; then
  echo "기준 브랜치 '${BASE_BRANCH}'를 찾을 수 없습니다." >&2
  exit 2
fi

# 기준 브랜치 이후 커밋한 파일, 스테이징한 파일, 아직 스테이징하지 않은 파일과 새 파일.
# 하위 셸에서 실패하면 멈출 수 없으므로 여기서 한 번에 모읍니다.
if ! ALL_CHANGED="$(
  git diff --name-only "${BASE_BRANCH}...HEAD" &&
    git diff --cached --name-only &&
    git ls-files --modified --others --exclude-standard
)"; then
  echo '바뀐 파일 목록을 모으지 못했습니다.' >&2
  exit 2
fi
readonly ALL_CHANGED

# [ALL_CHANGED] 중 [pattern]에 맞고 지금 남아 있는(지우지 않은) 파일.
changed_files() {
  local pattern="$1"
  echo "${ALL_CHANGED}" | sort -u | grep -E "${pattern}" | while read -r file; do
    if [[ -f "${file}" ]]; then echo "${file}"; fi
  done || true
}

LIB_FILES=()
while IFS= read -r file; do LIB_FILES+=("${file}"); done \
  < <(changed_files '^lib/.*\.dart$')
TEST_FILES=()
while IFS= read -r file; do TEST_FILES+=("${file}"); done \
  < <(changed_files '^test/.*\.dart$')

# core/constants는 토큰을 정의하는 곳이라 하드코딩 점검에서 뺍니다.
NON_CONSTANT_FILES=()
SCREEN_FILES=()
PRESENTATION_FILES=()
for file in ${LIB_FILES[@]+"${LIB_FILES[@]}"}; do
  if [[ "${file}" != lib/core/constants/* ]]; then
    NON_CONSTANT_FILES+=("${file}")
    # 화면 문구를 모아 두는 *_strings.dart와, 서버 데이터를 흉내 내는
    # 예시·메모리 저장소(sample_*·in_memory_*)는 문자열 점검에서 뺍니다.
    if [[ "${file}" != *_strings.dart && "${file}" != */sample_* && "${file}" != */in_memory_* ]]; then
      SCREEN_FILES+=("${file}")
    fi
  fi
  if [[ "${file}" == */presentation/* ]]; then PRESENTATION_FILES+=("${file}"); fi
done

violation_count=0

# check <위반|확인> <제목> <명령...>: 명령 결과가 있으면 보여 주고, 위반이면 셉니다.
check() {
  local kind="$1" title="$2"
  shift 2
  local result
  result="$("$@" 2>/dev/null || true)"
  if [[ -n "${result}" ]]; then
    echo "== [${kind}] ${title}"
    echo "${result}"
    echo
    if [[ "${kind}" == '위반' ]]; then violation_count=$((violation_count + 1)); fi
  fi
}

# grep_in <패턴> <파일...>: 파일이 없으면 아무것도 하지 않습니다.
grep_in() {
  local pattern="$1"
  shift
  if [[ $# -gt 0 ]]; then grep -nE "${pattern}" "$@"; fi
}

# ── CODE_STYLE.md ──

null_assertions() {
  # `!=`와 타입 검사 `is!`는 null 강제 해제가 아니므로 뺍니다.
  grep_in '[]a-zA-Z0-9_)]!(\.|\)|;|,| |\[)' ${LIB_FILES[@]+"${LIB_FILES[@]}"} \
    | grep -v '!=' | grep -vE '(^|[^A-Za-z0-9_])is! '
}

# CODE_STYLE은 색상·글자 크기·간격을 토큰으로 쓰게 합니다. 다음을 잡습니다.
# - 이름 없이 바로 쓴 숫자: `height: 12`, `size: 18`, `EdgeInsets.all(16)` 등 (0은 제외)
# - 간격을 뜻하는 이름의 private 상수: `_gap`, `_bodyTop`, `_padding` 등 (AppSpacing으로)
# - 글자 크기·줄 높이·자간 숫자: `fontSize: 14`, `height: 18 / 15` 등 (AppTypography로)
# 너비·높이·아이콘 크기처럼 부품 자체의 크기는 이름을 붙인 private 상수로 둘 수 있습니다.
hardcoded_sizes() {
  grep_in '(height|width|size|top|bottom|left|right|all|horizontal|vertical|letterSpacing|fontSize|dimension)\s*:\s*([1-9]|0\.[0-9])|SizedBox(\.square)?\((height|width|dimension): ([1-9]|0\.[0-9])|static const _[a-zA-Z]*([Gg]ap|[Pp]adding|[Tt]op|[Bb]ottom|[Ll]eft|[Rr]ight|[Mm]argin|[Ss]pacing|[Ii]nset|[Ii]ndent) = [0-9]|EdgeInsets\.[a-zA-Z]+\(([1-9]|0\.[0-9])' \
    ${NON_CONSTANT_FILES[@]+"${NON_CONSTANT_FILES[@]}"}
}

hardcoded_colors() {
  grep_in 'Color\(0x|(^|[^A-Za-z])Colors\.[a-z]' \
    ${NON_CONSTANT_FILES[@]+"${NON_CONSTANT_FILES[@]}"}
}

string_literals() {
  grep_in "Text\('|label: '|hintText: '|tooltip: '|Text\('\\$" \
    ${SCREEN_FILES[@]+"${SCREEN_FILES[@]}"}
}

private_widget_methods() {
  grep_in '^\s+(Widget|List<Widget>) _[a-zA-Z]+\(' \
    ${LIB_FILES[@]+"${LIB_FILES[@]}"}
}

# sealed 클래스의 하위 클래스는 언어 규칙상 같은 파일에 있어야 하므로 한 묶음으로 셉니다.
multiple_public_types() {
  local file count
  for file in ${LIB_FILES[@]+"${LIB_FILES[@]}"}; do
    count="$(awk '
      /^sealed class [A-Z]/ { sealed[$3] = 1 }
      /^(abstract |final |sealed |base |interface )*(class|enum|extension|mixin) [A-Z]/ {
        for (name in sealed) if ($0 ~ ("(extends|implements|with) " name "[ {<]")) next
        count++
      }
      END { print count + 0 }' "${file}")"
    if [[ "${count}" -gt 1 ]]; then echo "${file}: public 타입 ${count}개"; fi
  done
}

# CODE_STYLE은 대략 80줄을 기준으로 하지만, 여유를 두고 60줄부터 알립니다.
long_build_methods() {
  local file
  for file in ${LIB_FILES[@]+"${LIB_FILES[@]}"}; do
    awk -v file="${file}" '
      /Widget build\(BuildContext/ { start = NR }
      start && /^  }$/ {
        if (NR - start > 60) print file ":" start ": build " NR - start "줄"
        start = 0
      }' "${file}"
  done
}

# public 클래스와, 클래스 안의 public 멤버(필드 제외) 위에 /// 주석이 있는지 봅니다.
missing_doc_comments() {
  local file
  for file in ${LIB_FILES[@]+"${LIB_FILES[@]}"}; do
    awk -v file="${file}" '
      /^(abstract |final |sealed |base |interface )*(class|enum|mixin|extension) / {
        in_class = 1
        # private 클래스의 멤버는 밖에서 쓰지 않으므로 문서 주석을 요구하지 않습니다.
        in_private = ($0 ~ /(class|enum|mixin|extension) _/)
        if ($0 !~ / _[A-Za-z]/ && prev !~ /^\/\/\//) print file ":" NR ": " $0
      }
      /^final [a-zA-Z]+Provider/ && prev !~ /^\/\/\// { print file ":" NR ": " $0 }
      in_class && !in_private && /^  ([A-Z][A-Za-z<>?, ]*|void|bool|String|int|double) (get )?[a-z][A-Za-z]*( =>|\(| \{)/ \
        && $0 !~ /build\(|createState\(|dispose\(|toString\(/ \
        && prev !~ /\/\/\// && prev !~ /@override/ { print file ":" NR ": " $0 }
      /^}/ { in_class = 0 }
      { prev = $0 }' "${file}"
  done | grep -vE '^\S+: class _|State<' || true
}

positional_widget_parameters() {
  local file
  for file in ${LIB_FILES[@]+"${LIB_FILES[@]}"}; do
    awk -v file="${file}" '
      /class [A-Za-z_]+ extends (Stateless|Stateful|Consumer|ConsumerStateful)Widget/ { in_widget = 1 }
      in_widget && /^  const [A-Za-z_]+\(this\./ { print file ":" NR ": " $0 }
      /^}/ { in_widget = 0 }' "${file}"
  done
}

abbreviated_names() {
  local files=(${LIB_FILES[@]+"${LIB_FILES[@]}"} ${TEST_FILES[@]+"${TEST_FILES[@]}"})
  if [[ ${#files[@]} -gt 0 ]]; then
    grep -nwE '(doc|docs|btn|ctx|idx|msg|err|res|req|val|tmp|cb)' "${files[@]}" \
      | grep -vE '^\S+:[0-9]+:\s*//'
  fi
}

# ── ARCHITECTURE.md ──

# build 본문에서 바로 실행되는 ref.read만 잡습니다.
# 중괄호 블록을 쌓아 가며 종류를 기억합니다.
# - if·else·for·while·switch·try 블록은 build와 함께 바로 실행되므로 그 안의 ref.read도 잡습니다.
# - 그 밖의 블록(콜백 `() {`, 지역 함수 `foo() async {`)은 나중에 실행되므로 그 안은 뺍니다.
# - `=>` 뒤(같은 줄 또는 바로 윗줄 끝)의 ref.read도 콜백이라 뺍니다. 단 switch 식의
#   갈래(`A() => ...`)는 바로 실행되므로 잡습니다.
read_in_build() {
  local file
  for file in ${PRESENTATION_FILES[@]+"${PRESENTATION_FILES[@]}"}; do
    awk -v file="${file}" '
      function is_immediate(text) {
        return text ~ /(^|[^A-Za-z_])(if|else|for|while|switch|try|do|finally)([^A-Za-z_]|$)/ \
          && text !~ /\)[[:space:]]*(async[[:space:]]*)?\{[[:space:]]*$/ \
          || text ~ /^[[:space:]]*\}?[[:space:]]*(else|try|finally|do)[[:space:]]*\{/ \
          || text ~ /^[[:space:]]*(\}[[:space:]]*else[[:space:]]+)?(if|for|while|switch)[[:space:]]*\(.*\)[[:space:]]*\{[[:space:]]*$/ \
          || text ~ /switch[[:space:]]*\(.*\)[[:space:]]*\{/
      }
      /Widget build\(BuildContext/ { in_build = 1; top = 0; prev = ""; }
      in_build {
        line = $0
        gsub(/\x27[^\x27]*\x27/, "", line)  # 문자열 안의 괄호는 세지 않습니다.
        deferred = 0
        for (k = 2; k <= top; k++) if (kind[k] == "deferred") deferred = 1
        # ref.read 앞에 있는 `=>` 개수. switch 갈래 안이면 첫 `=>`는 갈래 표시라 빼고 셉니다.
        before = line
        sub(/ref\.read.*/, "", before)
        arrows = gsub(/=>/, "=>", before)
        if (top >= 1 && kind[top] == "switch" && arrows > 0) arrows--
        else if (prev ~ /=>[[:space:]]*$/) arrows++
        if (top >= 1 && !deferred && line ~ /ref\.read/ && arrows == 0) {
          print file ":" NR ": " $0
        }
        # 줄 맨 앞의 닫는 중괄호를 먼저 처리합니다. 예: "} else {"
        rest = line
        while (rest ~ /^[[:space:]]*\}/) { sub(/^[[:space:]]*\}/, "", rest); top-- }
        opened = gsub(/\{/, "{", rest)
        closed = gsub(/\}/, "}", rest)
        for (k = 0; k < opened; k++) {
          top++
          kind[top] = (line ~ /switch[[:space:]]*\(/) ? "switch" : (top == 1 || is_immediate(line)) ? "immediate" : "deferred"
        }
        top -= closed
        if (top <= 0 && (opened + closed) > 0) in_build = 0
        if (top <= 0 && line ~ /^[[:space:]]*\}/) in_build = 0
        if (line !~ /^[[:space:]]*$/) prev = line
      }' "${file}"
  done
}

async_value_without_when() {
  grep_in 'ref\.watch\([^)]*\)\.(value|valueOrNull|requireValue)' \
    ${PRESENTATION_FILES[@]+"${PRESENTATION_FILES[@]}"}
}

repository_in_presentation() {
  grep_in 'RepositoryProvider|_repository\.dart' \
    ${PRESENTATION_FILES[@]+"${PRESENTATION_FILES[@]}"}
}

print_calls() {
  grep_in '(^|[^A-Za-z])print\(' ${LIB_FILES[@]+"${LIB_FILES[@]}"}
}

raw_route_paths() {
  grep_in "(push|go|pushReplacement)\('/" ${LIB_FILES[@]+"${LIB_FILES[@]}"}
}

# ── TESTING.md ──

test_names_without_condition() {
  if [[ ${#TEST_FILES[@]} -gt 0 ]]; then
    grep -nHoE "(test|testWidgets)\('[^']+'" "${TEST_FILES[@]}" | grep -v '면'
  fi
}

missing_test_files() {
  local file test_file
  for file in ${LIB_FILES[@]+"${LIB_FILES[@]}"}; do
    if [[ "${file}" =~ /(application|data)/|^lib/core/(utils|extensions)/ ]]; then
      test_file="test/${file#lib/}"
      test_file="${test_file%.dart}_test.dart"
      if [[ ! -f "${test_file}" ]]; then echo "${file} → ${test_file} 없음"; fi
    fi
  done
}

echo "점검 대상: lib ${#LIB_FILES[@]}개, test ${#TEST_FILES[@]}개 (기준: ${BASE_BRANCH})"
echo

check 위반 'CODE_STYLE · ! (null 강제 해제)' null_assertions
check 위반 'CODE_STYLE · 간격·글자 크기 하드코딩 (AppSpacing·AppTypography 토큰, 부품 크기는 이름 붙인 상수)' hardcoded_sizes
check 위반 'CODE_STYLE · 색상 하드코딩 (AppColors 사용)' hardcoded_colors
check 위반 'CODE_STYLE · 화면 문자열 직접 작성 (*_strings.dart로 모으기)' string_literals
check 위반 'CODE_STYLE · 위젯을 만드는 private 메서드 (위젯 클래스로 분리)' private_widget_methods
check 위반 'CODE_STYLE · 파일당 public 타입 2개 이상' multiple_public_types
check 위반 'CODE_STYLE · 긴 build (위젯 클래스로 분리)' long_build_methods
check 위반 'CODE_STYLE · 문서 주석(///) 없는 public 선언' missing_doc_comments
check 위반 'CODE_STYLE · 위젯 생성자의 위치 매개변수 (named로)' positional_widget_parameters
check 위반 'CODE_STYLE · 줄인 이름' abbreviated_names
check 위반 'ARCHITECTURE · build 안에서 ref.read (콜백 안으로)' read_in_build
check 위반 'ARCHITECTURE · AsyncValue를 when 없이 읽음' async_value_without_when
check 위반 'ARCHITECTURE · presentation에서 저장소 직접 접근' repository_in_presentation
check 위반 'ARCHITECTURE · print 사용 (debugPrint로)' print_calls
check 위반 'ARCHITECTURE · 경로 문자열 직접 사용 (AppRoute로)' raw_route_paths
check 위반 "TESTING · 테스트 이름이 '~하면 ~한다' 형식이 아님" test_names_without_condition
check 확인 'TESTING · 테스트 파일 없음 (값만 담는 클래스면 생략 가능)' missing_test_files

if [[ "${violation_count}" -gt 0 ]]; then
  echo "위반 ${violation_count}건. 고친 뒤 다시 실행합니다."
  exit 1
fi
echo '위반 없음. 규칙 문서를 직접 읽고 대조하는 점검도 함께 합니다.'
