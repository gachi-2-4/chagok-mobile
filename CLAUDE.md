# CLAUDE.md

이 저장소의 공통 에이전트 지침은 `docs/AGENTS.md`에 있습니다. 아래 파일을 먼저 읽고 따릅니다.

@docs/AGENTS.md
@docs/COMMIT_CONVENTION.md

## Claude Code 전용 메모

- Dart/Flutter 코드를 수정한 뒤에는 실행 중인 앱이 있으면 hot reload(또는 hot restart)로 반영을 확인합니다.
- 작업 완료 전 `dart format .`, `flutter analyze`, `flutter test`를 실행해 결과를 보고합니다.
- 커밋할 때는 항상 `docs/COMMIT_CONVENTION.md` 규칙(type, scope, 한국어 subject, body, footer)을 지켜 메시지를 작성합니다.
