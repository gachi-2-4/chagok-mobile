# 커밋 메시지 규칙

이 저장소는 [Conventional Commits](https://www.conventionalcommits.org/ko/v1.0.0/) 형식을 따릅니다.
사람과 AI 에이전트 모두 이 규칙으로 커밋합니다.

## 형식

```
<type>(<scope>): <subject>

<body>

<footer>
```

- **type**: 필수. 아래 목록 중 하나 (영문 소문자)
- **scope**: 선택. 변경된 영역 (예: `auth`, `home`, `router`, `android`)
- **subject**: 필수. 무엇을 바꿨는지 한국어로 간결하게
- **body**: 선택. 왜 바꿨는지, 무엇이 달라지는지
- **footer**: 선택. 이슈 번호, Breaking Change 등

## type 목록

| type | 용도 |
|------|------|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `refactor` | 동작 변화 없는 코드 구조 개선 |
| `style` | 포맷, 세미콜론 등 동작에 영향 없는 변경 |
| `ui` | 화면·디자인·레이아웃 변경 |
| `test` | 테스트 추가·수정 |
| `docs` | 문서 변경 (README, AGENTS.md 등) |
| `chore` | 빌드 설정, 패키지 추가·업데이트, 기타 잡무 |
| `perf` | 성능 개선 |
| `ci` | CI/CD 설정 변경 |
| `revert` | 이전 커밋 되돌리기 |

## subject 작성 규칙

- 50자 이내로 작성합니다.
- 끝에 마침표를 붙이지 않습니다.
- "~추가", "~수정", "~제거"처럼 명사형으로 끝냅니다.
- 무엇을 했는지가 드러나게 씁니다. (`수정함`, `작업중` 같은 모호한 표현 금지)

## body 작성 규칙

- subject와 한 줄 띄우고 작성합니다.
- 한 줄은 72자 내외로 줄바꿈합니다.
- "무엇을"보다 "왜"를 중심으로 설명합니다.
- 여러 항목은 `-` 목록으로 정리합니다.

## footer 작성 규칙

- 관련 이슈: `Closes #12`, `Refs #34`
- 공동 작성자: `Co-Authored-By: 이름 <이메일>` (AI 에이전트가 작성한 커밋 포함)
- 호환성을 깨는 변경: `BREAKING CHANGE: <설명>`
  - 또는 type 뒤에 `!`를 붙입니다. 예: `feat(api)!: 응답 형식 변경`

## 예시

```
feat(auth): 이메일 로그인 화면 추가
```

```
fix(home): 목록이 비어 있을 때 발생하는 RangeError 수정

빈 리스트에서 first를 호출해 앱이 종료되던 문제를 해결한다.
- firstOrNull 사용으로 변경
- 빈 상태 위젯 표시 추가

Closes #7
```

```
chore: go_router 패키지 추가

선언형 라우팅과 딥링크 지원을 위해 추가한다.
```

```
refactor(core)!: 네트워크 클라이언트 구조 변경

BREAKING CHANGE: ApiClient 생성자에 baseUrl 인자가 필수로 바뀜
```

## 커밋 단위

- 하나의 커밋에는 하나의 논리적 변경만 담습니다.
- 기능 변경과 포맷/리팩터링은 가능한 한 별도 커밋으로 나눕니다.
- 커밋 전 `dart format .`, `flutter analyze`, `flutter test`가 통과해야 합니다.
- `pubspec.yaml`을 바꿨다면 `pubspec.lock`도 함께 커밋합니다.
