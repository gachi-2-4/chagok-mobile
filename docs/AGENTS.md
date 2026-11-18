# AGENTS.md

이 문서는 이 저장소에서 작업하는 AI 코딩 에이전트(Claude Code, Codex, Cursor 등)를 위한 작업 지침입니다.
코드를 수정하기 전에 이 문서를 먼저 읽고 따릅니다.

## 프로젝트 개요

- **이름**: `stack`
- **종류**: Flutter 애플리케이션 (멀티 플랫폼: Android, iOS, Web, macOS, Windows, Linux)
- **SDK**: Flutter 3.47.x (stable) / Dart `^3.13.5`
- **현재 상태**: `flutter create` 직후의 초기 템플릿 상태

> TODO: 앱의 목적, 주요 기능, 대상 플랫폼을 정해지는 대로 여기에 적습니다.

## 디렉터리 구조

```
docs/           # 프로젝트 문서 (AGENTS.md, COMMIT_CONVENTION.md 등)
lib/            # 앱 소스 코드 (진입점: lib/main.dart)
test/           # 단위·위젯 테스트
android/ ios/ web/ macos/ windows/ linux/   # 플랫폼별 네이티브 프로젝트
pubspec.yaml    # 의존성 및 에셋 설정
analysis_options.yaml  # 린트 설정 (flutter_lints)
```

기능이 늘어나면 `lib/` 아래를 다음처럼 계층별로 나눕니다.

```
lib/
  main.dart
  app/            # MaterialApp, 라우팅, 테마
  features/<기능>/  # 기능 단위 (ui / logic / data)
  core/           # 공통 유틸, 상수, 확장
```

## 자주 쓰는 명령어

```bash
flutter pub get            # 의존성 설치
flutter run                # 앱 실행 (기기 선택: -d <device>)
flutter analyze            # 정적 분석
dart format .              # 코드 포맷
flutter test               # 전체 테스트
flutter test test/<파일>    # 특정 테스트
```

## 작업 규칙

### 코드 스타일
- `analysis_options.yaml`의 린트(`flutter_lints`)를 따르고, 경고를 남기지 않습니다.
- 변경 후 반드시 `dart format .` 과 `flutter analyze` 를 실행해 통과시킵니다.
- 가능한 곳에는 `const` 생성자를 사용합니다.
- 위젯이 커지면 private 메서드보다 별도 위젯 클래스로 분리합니다.
- 파일명은 `snake_case.dart`, 클래스는 `UpperCamelCase`, 변수·함수는 `lowerCamelCase`.

### 테스트
- 새 로직에는 단위 테스트, 새 화면/컴포넌트에는 위젯 테스트를 추가합니다.
- 작업을 마치기 전에 `flutter test` 가 통과해야 합니다.

### 의존성
- 새 패키지는 `flutter pub add <패키지>` 로 추가하고, 추가 이유를 변경 요약에 적습니다.
- 꼭 필요한 경우에만 추가하며, pub.dev에서 유지보수 상태를 확인합니다.

### 수정 범위
- 요청받은 범위만 수정합니다. 관련 없는 리팩터링은 따로 제안합니다.
- 플랫폼 폴더(`android/`, `ios/` 등)는 필요한 경우에만 수정하고, 수정 시 이유를 명시합니다.
- 비밀키·API 키 등은 코드나 커밋에 포함하지 않습니다.

### Git
- 사용자가 요청할 때만 커밋/푸시합니다.
- 커밋 메시지는 [`COMMIT_CONVENTION.md`](COMMIT_CONVENTION.md) 규칙을 따릅니다.

## 미정 사항 (정해지면 갱신)

- 상태 관리 방식: TODO (예: Provider / Riverpod / Bloc)
- 라우팅: TODO (예: go_router)
- 백엔드/데이터 소스: TODO
- 디자인 시스템·테마: TODO
