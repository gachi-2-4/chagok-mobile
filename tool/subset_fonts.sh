#!/usr/bin/env bash
# 앱에 넣는 폰트 파일(assets/fonts/)을 다시 만드는 스크립트.
#
# Google Fonts 저장소에서 원본을 받아, 앱 용량을 줄이기 위해 필요한 글자만 남깁니다.
# - Noto Sans KR: 한글 전체(11,172자)·자모와 영문·숫자·기호. 한자는 뺍니다. (10.4MB → 약 4.9MB)
# - Figtree: 원본 그대로 씁니다. (약 63KB)
# - Jua: 로고 '차곡' 두 글자만 남깁니다.
#
# 세 폰트 모두 굵기 축(wght)을 유지하는 가변 폰트라 굵기마다 파일을 나누지 않습니다.
#
# 필요한 도구: curl, fonttools (`pip install fonttools`)
# 사용법: tool/subset_fonts.sh

set -euo pipefail

# 원본 폰트를 받을 google/fonts 저장소 커밋. 바꾸면 폰트가 달라질 수 있습니다.
readonly FONTS_COMMIT='5bd87dfc525c8a0d1d8529d3684716e00c3fc59a'
readonly BASE_URL="https://raw.githubusercontent.com/google/fonts/${FONTS_COMMIT}/ofl"

readonly ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
readonly OUT_DIR="${ROOT_DIR}/assets/fonts"

# Noto Sans KR에 남길 글자 범위.
readonly HANGUL_UNICODES=(
  'U+0020-007E' # 영문·숫자·기본 문장부호
  'U+00A0-00FF' # 라틴-1 보충 (·, ° 등)
  'U+1100-11FF' # 한글 자모
  'U+2000-206F' # 일반 문장부호 (—, …, ‘’ 등)
  'U+20A9'      # ₩
  'U+2190-21FF' # 화살표
  'U+2460-24FF' # 원 숫자 (①)
  'U+25A0-25FF' # 도형 (■, ○)
  'U+2600-26FF' # 기타 기호 (★)
  'U+3000-303F' # 한중일 문장부호 (「」 등)
  'U+3131-318F' # 한글 호환 자모 (ㄱ, ㅏ)
  'U+3200-321E' # 괄호 한글
  'U+3260-327F' # 원 한글
  'U+A960-A97F' # 한글 자모 확장-A
  'U+AC00-D7A3' # 한글 음절 전체
  'U+D7B0-D7FF' # 한글 자모 확장-B
  'U+FF01-FF60' # 전각 문장부호 (＋ 등)
  'U+FFE0-FFE6' # 전각 기호 (￦ 등)
)

if ! command -v pyftsubset >/dev/null 2>&1; then
  echo 'pyftsubset이 없습니다. `pip install fonttools`로 설치해 주세요.' >&2
  exit 1
fi

work_dir="$(mktemp -d)"
trap 'rm -rf "${work_dir}"' EXIT

download() {
  curl -fsSL -o "${work_dir}/$2" "${BASE_URL}/$1"
}

download 'notosanskr/NotoSansKR%5Bwght%5D.ttf' 'NotoSansKR.ttf'
download 'notosanskr/OFL.txt' 'OFL-NotoSansKR.txt'
download 'figtree/Figtree%5Bwght%5D.ttf' 'Figtree.ttf'
download 'figtree/OFL.txt' 'OFL-Figtree.txt'
download 'jua/Jua-Regular.ttf' 'Jua.ttf'
download 'jua/OFL.txt' 'OFL-Jua.txt'

mkdir -p "${OUT_DIR}"

pyftsubset "${work_dir}/NotoSansKR.ttf" \
  --unicodes="$(IFS=,; echo "${HANGUL_UNICODES[*]}")" \
  --layout-features='*' \
  --output-file="${OUT_DIR}/NotoSansKR-Hangul.ttf"

pyftsubset "${work_dir}/Jua.ttf" \
  --text='차곡' \
  --layout-features='*' \
  --output-file="${OUT_DIR}/Jua-Logo.ttf"

cp "${work_dir}/Figtree.ttf" "${OUT_DIR}/Figtree.ttf"
cp "${work_dir}"/OFL-*.txt "${OUT_DIR}/"

ls -l "${OUT_DIR}"
