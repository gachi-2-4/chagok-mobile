# AGENTS.md

이 문서는 이 저장소에서 작업하는 AI 코딩 에이전트(Claude Code, Codex, Cursor 등)를 위한 작업 지침입니다.
코드를 수정하기 전에 이 문서를 먼저 읽고 따릅니다.

## 프로젝트 개요

- **서비스**: 차곡 (Chagok), 문서 자동 정리 서비스
- **이 저장소**: 차곡의 모바일 앱 (Flutter)
- **GitHub**: [`gachi-2-4/chagok-mobile`](https://github.com/gachi-2-4/chagok-mobile)
- **Dart 패키지 이름**: `chagok_mobile` (import 경로: `package:chagok_mobile/...`)
- **종류**: Flutter 애플리케이션 (멀티 플랫폼: Android, iOS, Web, macOS, Windows, Linux)
- **SDK**: Flutter 3.47.x (stable) / Dart `^3.13.5`
- **현재 상태**: 기본 구조(`app/`, `features/home/`) 구성 완료, 첫 기능 개발 전

> TODO: 주요 기능과 주력 대상 플랫폼을 정해지는 대로 여기에 적습니다.

## 디렉터리 구조

```
docs/           # 프로젝트 문서 (AGENTS.md, COMMIT_CONVENTION.md 등)
lib/            # 앱 소스 코드 (진입점: lib/main.dart)
test/           # 단위·위젯 테스트
assets/         # 아이콘(icons/)·폰트(fonts/) 에셋
tool/           # 개발용 스크립트 (예: subset_fonts.sh, check_rules.sh)
android/ ios/ web/ macos/ windows/ linux/   # 플랫폼별 네이티브 프로젝트
pubspec.yaml    # 의존성 및 에셋 설정
analysis_options.yaml  # 린트 설정 (flutter_lints + CODE_STYLE.md 규칙)
```

`lib/`은 `app/`, `core/`, `features/<기능>/` 구조로 나눕니다. 자세한 구조와 계층 규칙은 [`ARCHITECTURE.md`](ARCHITECTURE.md)를 따릅니다.

## 규칙 문서

작업 전에 관련 문서를 읽고 따릅니다.

| 문서 | 내용 |
|------|------|
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | 폴더 구조, 계층 규칙, Riverpod·go_router 사용법 |
| [`CODE_STYLE.md`](CODE_STYLE.md) | 이름 규칙, import, 위젯 작성, 주석 |
| [`TESTING.md`](TESTING.md) | 테스트 대상, 위치, 작성 방법 |
| [`COMMIT_CONVENTION.md`](COMMIT_CONVENTION.md) | 커밋 메시지 규칙 |

## 자주 쓰는 명령어

```bash
flutter pub get            # 의존성 설치
flutter run                # 앱 실행 (기기 선택: -d <device>)
flutter analyze            # 정적 분석
dart format .              # 코드 포맷
flutter test               # 전체 테스트
flutter test test/<파일>    # 특정 테스트
tool/check_rules.sh        # 바꾼 파일의 규칙 위반 점검 (기준 브랜치: main)
```

## 작업 규칙

### 코드 스타일
- [`CODE_STYLE.md`](CODE_STYLE.md)를 따릅니다.
- 변경 후 반드시 `dart format .` 과 `flutter analyze` 를 실행해 통과시킵니다.

### 테스트
- [`TESTING.md`](TESTING.md)를 따릅니다. Notifier·Repository·유틸은 단위 테스트가 필수입니다.
- 작업을 마치기 전에 `flutter test` 가 통과해야 합니다.

### 규칙 점검 루프
작업을 마쳤다고 보고하기 전에, 바꾼 코드가 규칙 문서에 맞는지 점검하고 고치는 일을 **위반이 하나도 남지 않을 때까지 반복**합니다.

1. `tool/check_rules.sh`를 실행해 바꾼 파일에서 글자 패턴으로 찾을 수 있는 위반을 먼저 찾습니다.
   - `[위반]`이 하나라도 있으면 종료 코드 1을 돌려줍니다. `[확인]`은 규칙 대상인지 직접 판단합니다.
   - 스크립트는 놓치거나 잘못 잡는 경우가 있으므로, 통과해도 2번을 건너뛰지 않습니다.
2. 바꾼 파일(`git status`, `git diff --name-only main...HEAD`)을 읽으며 규칙 문서를 한 항목씩 대조합니다.
   - [`CODE_STYLE.md`](CODE_STYLE.md): 이름, import, 위젯 분리(긴 `build`, 위젯을 만드는 private 메서드), 색상·글자 크기·간격 하드코딩, 화면 문자열 관리, `!` 사용, 문서 주석, 파일당 public 클래스 하나
   - [`ARCHITECTURE.md`](ARCHITECTURE.md): 계층 의존 방향, `ref.watch`·`ref.read` 위치, `AsyncValue.when`으로 로딩·에러·데이터 처리, 예외를 application 계층에서 상태로 바꾸기, 경로 상수
   - [`TESTING.md`](TESTING.md): 필수 단위 테스트, 핵심 화면 위젯 테스트, 파일 위치, 테스트 이름 "~하면 ~한다"
   - [`COMMIT_CONVENTION.md`](COMMIT_CONVENTION.md): 커밋 메시지 형식
3. 위반이 있으면 고치고 `dart format .`, `flutter analyze`, `flutter test`를 다시 실행합니다.
4. 고친 코드가 새 위반을 만들 수 있으므로 1번부터 다시 점검합니다.
5. 한 바퀴를 다 돌았는데 위반이 없고 세 명령이 모두 통과하면 끝냅니다.

- 규칙을 지키기 어렵거나 규칙끼리 부딪히면 임의로 넘기지 않고, 이유를 적어 사용자에게 확인합니다.
- 작업을 보고할 때 몇 바퀴를 돌았는지, 무엇을 찾아 고쳤는지 함께 적습니다.

### 의존성
- 새 패키지는 `flutter pub add <패키지>` 로 추가하고, 추가 이유를 변경 요약에 적습니다.
- 꼭 필요한 경우에만 추가하며, pub.dev에서 유지보수 상태를 확인합니다.

### 수정 범위
- 요청받은 범위만 수정합니다. 관련 없는 리팩터링은 따로 제안합니다.
- 플랫폼 폴더(`android/`, `ios/` 등)는 필요한 경우에만 수정하고, 수정 시 이유를 명시합니다.
- 비밀키·API 키 등은 코드나 커밋에 포함하지 않습니다.

### Git
- 커밋 메시지는 [`COMMIT_CONVENTION.md`](COMMIT_CONVENTION.md) 규칙을 따릅니다.
- `main`에 직접 커밋·푸시하지 않습니다. 모든 작업은 브랜치에서 하고 PR로 병합합니다.

### 브랜치 & PR 작업 흐름
1. 최신 `main`에서 브랜치를 만듭니다.
   ```bash
   git checkout main && git pull
   git checkout -b <type>/<짧은-설명>
   ```
2. 브랜치 이름은 `<type>/<kebab-case 설명>` 형식이며, type은 커밋 규칙의 type을 씁니다.
   - 예: `feat/email-login`, `fix/home-empty-list`, `docs/branch-pr-workflow`
3. 커밋 규칙에 맞춰 커밋하고, 푸시 전에 `dart format .`, `flutter analyze`, `flutter test`를 통과시킵니다.
4. 브랜치를 푸시하고 PR을 생성합니다.
   ```bash
   git push -u origin <브랜치>
   gh pr create --base main
   ```
5. PR 규칙
   - **제목**: 커밋 규칙과 같은 형식 (`<type>(<scope>): <subject>`)
   - **본문**: `## 변경 사항` (무엇을 왜), `## 확인 방법` (테스트·실행 결과) 섹션을 포함합니다.
   - 하나의 PR에는 하나의 목적만 담습니다.
6. PR 병합은 사용자가 확인한 뒤 진행합니다. 에이전트가 임의로 병합하지 않습니다.
7. 병합은 항상 **Squash and merge**로 하고, 병합 후 브랜치를 삭제합니다.
   ```bash
   gh pr merge <번호> --squash --delete-branch
   ```
   - squash 커밋 제목은 PR 제목(커밋 규칙 형식) + `(#PR번호)`가 되도록 합니다.

## 미정 사항 (정해지면 갱신)

- 백엔드/데이터 소스: 차곡 API 서버. 연동 방식은 [`ARCHITECTURE.md`](ARCHITECTURE.md)의 "서버 API 연동"을 따릅니다.
  - 서버와 붙여 실행: `flutter run --dart-define=API_BASE_URL=<서버 주소>` (주소 없이 실행하면 예시 데이터로 돕니다)
- 디자인 시스템·테마: 토큰은 `lib/core/constants/`(`AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppIcons`), 공통 위젯은 `lib/core/widgets/`(`App*`)에 있습니다. 새 화면은 이 위젯과 토큰을 먼저 씁니다.
  - 폰트: Figtree(영문·숫자)와 Noto Sans KR(한글)을 `assets/fonts/`에 넣었고, 로고에는 Jua를 씁니다. 용량을 줄이려고 Noto Sans KR은 한자를 뺐고 Jua는 '차곡' 두 글자만 남겼습니다. 폰트 파일은 직접 고치지 말고 `tool/subset_fonts.sh`로 다시 만듭니다.
