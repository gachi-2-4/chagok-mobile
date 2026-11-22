# 아키텍처

이 문서는 앱 코드의 구조와 기술 선택, 계층 사이의 규칙을 정합니다.
새 기능을 만들거나 구조를 바꿀 때 이 문서를 기준으로 합니다.

## 기술 선택

| 영역 | 선택 | 비고 |
|------|------|------|
| 상태 관리 | [Riverpod](https://riverpod.dev) (`flutter_riverpod`) | `Notifier` / `AsyncNotifier` 사용 |
| 라우팅 | [go_router](https://pub.dev/packages/go_router) | 경로 상수는 한 곳에서 관리 |
| 폴더 구조 | 기능 단위 (feature-first) | 기능마다 `presentation / application / data` |
| 서버 통신 | [http](https://pub.dev/packages/http) | `core/network/ApiClient`가 토큰·재발급·에러 응답을 처리 |

> 사용 버전: `flutter_riverpod ^3.5.0`, `go_router ^18.1.4`
> 코드 생성(`riverpod_generator`, `freezed`, `build_runner`)은 처음엔 쓰지 않고, 보일러플레이트가 부담될 때 도입을 검토합니다.

## 폴더 구조

```
lib/
  main.dart                  # 진입점: ProviderScope로 감싼 App 실행만 담당
  app/
    app.dart                 # MaterialApp.router, 테마 연결
    router.dart              # GoRouter 설정, 경로 정의
    main_shell.dart          # 하단 탭 바를 두르는 바깥 틀
    tab_placeholder_screen.dart  # 아직 만들지 않은 탭의 임시 화면
    app_strings.dart         # 앱 틀(하단 탭 등)의 문구
    theme.dart               # ThemeData, 색상·텍스트 스타일
  core/
    constants/               # 앱 전역 상수
    extensions/              # Dart/Flutter 확장 메서드
    utils/                   # 순수 함수 유틸
    widgets/                 # 여러 기능에서 공유하는 공통 위젯
    network/                 # HTTP 클라이언트 등 공통 인프라
  features/
    <기능>/
      presentation/          # 화면(Screen)과 위젯
      application/           # Notifier(상태·비즈니스 로직)
      data/                  # Repository, 데이터 소스, 모델
```

- 기능 이름은 `snake_case` 단수형으로 씁니다. 예: `features/auth`, `features/todo`
- 두 개 이상의 기능에서 쓰이게 되면 그때 `core/`로 옮깁니다. 처음부터 공통으로 만들지 않습니다.
- 테스트 폴더는 `lib/` 구조를 그대로 따라갑니다. → [`TESTING.md`](TESTING.md)

## 계층과 의존 방향

```
presentation  →  application  →  data
   (UI)          (Notifier)      (Repository, 모델)
```

의존은 **한 방향**으로만 흐릅니다. 화살표 반대 방향의 import는 금지합니다.

### presentation (UI)
- 화면(`*_screen.dart`)과 위젯만 둡니다.
- `ref.watch`로 상태를 구독하고, 사용자 동작은 `ref.read(...notifier).메서드()`로 전달합니다.
- **Repository나 API를 직접 호출하지 않습니다.**
- 비즈니스 로직(계산, 검증, 분기)을 넣지 않습니다. 표시 형식 변환 정도만 허용합니다.

### application (상태·로직)
- `Notifier` / `AsyncNotifier`로 화면 상태와 로직을 관리합니다.
  - 예외: 비밀번호 보이기·숨기기처럼 그 위젯 안에서만 쓰고 다른 위젯·화면·저장소와 나누지 않는 작은 화면 상태는 위젯의 `State`에 둘 수 있고, 왜 Notifier에 두지 않는지 주석으로 적습니다. → [`CODE_STYLE.md`](CODE_STYLE.md) 위젯 작성
- Repository는 Provider로 주입받아 사용합니다.
- Flutter UI 의존(`BuildContext`, `Widget`)을 가지지 않습니다. → 단위 테스트가 가능해야 합니다.

### data (데이터)
- `*_repository.dart`: 데이터를 가져오고 저장하는 창구. application은 Repository만 압니다.
- 데이터 소스(API, 로컬 저장소)는 Repository 안으로 숨깁니다.
- 모델(`*.dart`)은 불변(immutable) 클래스로 만들고, 필요하면 `fromJson` / `toJson` / `copyWith`를 둡니다.

### 기능 사이의 의존
- 다른 기능의 `presentation`을 import하지 않습니다.
- 다른 기능의 데이터가 필요하면 그 기능의 Provider(application 또는 data)를 통해 접근합니다.

## 상태 관리 규칙 (Riverpod)

- Provider는 해당 기능의 `application/` 또는 `data/` 파일 안, 클래스 바로 위나 아래에 선언합니다.
- 이름은 `<대상>Provider` 형식입니다. 예: `todoListProvider`, `authRepositoryProvider`
- 비동기 데이터는 `AsyncNotifier`를 쓰고, UI에서는 `AsyncValue.when`으로 로딩·에러·데이터를 모두 처리합니다.
- 전역 가변 변수나 싱글턴 대신 Provider를 씁니다.
- 다른 위젯과 나누거나, 화면을 벗어나도 남거나, 저장해야 하는 상태는 반드시 Notifier에 둡니다. 위젯 안에서만 쓰는 작은 화면 상태의 예외는 위 application 계층 설명을 따릅니다.
- `ref.watch`는 `build` 안에서, `ref.read`는 이벤트 핸들러(버튼 콜백 등) 안에서만 씁니다.
  - GoRoute의 `redirect`도 화면을 이동할 때마다 불리는 콜백이므로 이벤트 핸들러로 보고 `ref.read`를 씁니다. 그 순간의 상태를 보고 보낼 곳을 정하는 것이 목적이고, `routerProvider`에서 `ref.watch`를 쓰면 상태가 바뀔 때마다 `GoRouter`가 다시 만들어지기 때문입니다.

예시:

```dart
// features/todo/data/todo_repository.dart
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

// features/todo/application/todo_list_notifier.dart
final todoListProvider =
    AsyncNotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

class TodoListNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() {
    return ref.watch(todoRepositoryProvider).fetchAll();
  }

  Future<void> add(String title) async {
    final repository = ref.read(todoRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repository.add(title);
      return repository.fetchAll();
    });
  }
}
```

## 라우팅 규칙 (go_router)

- 모든 경로는 `app/router.dart` 한 곳에서 정의합니다.
- 경로 문자열은 직접 쓰지 않고 상수나 라우트 이름으로 참조합니다.
- 화면 이동은 `context.go()`(교체) / `context.push()`(쌓기)를 의도에 맞게 구분해 씁니다.
- 화면에 넘기는 값은 경로 파라미터(id 등 단순 값) 위주로 하고, 큰 객체는 Provider로 공유합니다.
- 앞 단계를 건너뛰고 주소로 바로 들어오면 안 되는 화면은 GoRoute의 `redirect`에서 `ref.read`로 상태를 확인해 그 흐름의 첫 화면으로 돌려보냅니다.
- 하단 탭은 `StatefulShellRoute.indexedStack`으로 만들고, 탭마다 `StatefulShellBranch`를 하나씩 둡니다.
  - 탭 아래로 쌓이는 화면(예: 대화방)은 바텀바가 계속 보이도록 그 탭의 하위 경로로 둡니다.
  - 바텀바의 탭은 `app/main_shell.dart`의 `MainShell.tabs`에 두고, `router.dart`의 branch 순서와 맞춥니다.
  - 아직 만들지 않은 탭은 `TabPlaceholderScreen`을 두고, 기능을 만들면 실제 화면으로 바꿉니다.

## 서버 API 연동

- 서버 API 명세(APP ↔ BE)는 공유 문서(API명세)를 기준으로 합니다. 요청·응답 값 이름은 명세 그대로 씁니다.
- 서버와 주고받는 일은 data 계층의 `Api<기능>Repository`가 맡고, 기존 Repository 인터페이스를 구현합니다.
  application·presentation은 서버가 있는지 모릅니다.
- 모든 요청은 `core/network/ApiClient`(`apiClientProvider`)로 보냅니다.
  - Access Token을 붙이고, 401 `TOKEN_EXPIRED`면 재발급(동시에 여러 요청이 만료돼도 한 번만) 뒤 다시 보냅니다.
  - 서버는 모든 응답을 `{ success, data, error }`로 감싸 줍니다. `ApiClient`가 성공하면 `data`만 돌려주므로 Repository는 `data` 안의 값만 다룹니다.
  - 실패 응답의 `error: { code, message }`는 `ApiException`으로 던집니다. Repository는 화면이 아는 예외(예: `BoxNotFoundException`, `AuthException`)로 바꿉니다.
  - JSON은 `JsonMap`의 `string`·`integerOrNull`·`maps` 등으로 타입을 확인하며 꺼냅니다. 서버 숫자 ID는 앱 모델에서 문자열입니다(`id`, `apiId`).
  - 날짜·시각 형식은 `core/network/api_formats.dart`로 바꿉니다.
- 서버 주소는 저장소 루트의 `.env` 파일(`API_BASE_URL`)에 적습니다. [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)로 읽습니다.
  - 주소에는 포트와 API 경로(`/api/v1`)까지 적습니다. 예: `http://<호스트>:8080/api/v1`. 경로가 틀리면 서버는 모든 요청에 401 `UNAUTHORIZED`를 줍니다.
  - `.env`는 `.env.example`을 복사해 만들고, `.gitignore`에 있어 커밋되지 않습니다.
  - 앱 에셋으로 들어가므로 파일이 없으면 빌드·테스트가 실패합니다. 값이 없어도 파일은 만들어 둡니다.
  - 앱 안에 그대로 들어가 누구나 꺼내 볼 수 있으므로 비밀키는 적지 않습니다.
  - `main`에서 `loadAppEnv()`로 읽어 `appEnvProvider`에 넣고, 설정 Provider는 여기서 꺼내 씁니다. `appEnvProvider` 기본값은 빈 값이라 테스트는 `.env` 내용과 상관없이 돕니다.
  - 주소가 있으면 각 `*RepositoryProvider`가 `Api*Repository`를, 없으면 예시·메모리 저장소(`Sample*`·`InMemory*`)를 씁니다.
  - 서버 없이 화면을 만들고 테스트하기 위해서입니다. 테스트는 주소를 넘기지 않으므로 예시 저장소로 돕니다.
  - 요청은 HTTPS로만 보냅니다. 기기 안 개발 서버(`localhost`, `10.0.2.2` 등)만 HTTP를 씁니다.
  - HTTPS가 아직 없는 테스트 서버(예: EC2 기본 주소)는 `.env`의 `ALLOW_INSECURE_HTTP`를 `true`로 둬야 HTTP로 붙습니다(`isInsecureHttpAllowedProvider`).
    - release 빌드에서는 이 값을 넘겨도 HTTP를 쓰지 않습니다. 플랫폼 설정도 같습니다. Android는 debug·profile 매니페스트에서만 HTTP를 허용하고, iOS는 `Info.plist` ATS 예외로 `amazonaws.com`만 허용합니다.
    - 서버에 HTTPS가 생기면 이 예외(ATS 예외, debug·profile 매니페스트의 `usesCleartextTraffic`)를 지웁니다.
  - 서버 주소는 코드·커밋에 적지 않습니다.
- 로그인 토큰은 `TokenStorage`(`tokenStorageProvider`)에 둡니다.
  - 서버를 쓰면 기기 보안 저장소(`SecureTokenStorage`, [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage))에 두어 앱을 다시 열어도 로그인이 유지됩니다. 로그인할 때 "자동 로그인"을 끄면 메모리에만 둡니다.
  - 토큰을 저장·삭제하면 로그인 상태(`sessionProvider`)가 바뀌고, 라우터의 최상위 `redirect`가 시작 화면(확인 중) · 로그인 화면(로그아웃) · 가려던 화면(로그인)으로 보냅니다. 로그아웃·탈퇴·재발급 실패도 같은 길로 로그인 화면에 갑니다.
  - 서버 없이 돌리면(`requiresLoginProvider`가 false) 로그인 없이 홈부터 엽니다.
- `Api*Repository` 테스트는 `test/helpers/fake_api_server.dart`의 가짜 서버로 요청과 응답을 확인합니다.

## 에러 처리

- data 계층에서 발생한 예외는 application 계층에서 `AsyncValue.guard` 등으로 잡아 상태로 바꿉니다.
- UI는 예외를 직접 `try/catch`하지 않고, 에러 상태를 받아 사용자에게 보여줍니다.
- 사용자에게 보여줄 메시지와 개발용 로그를 구분합니다. `print` 대신 `debugPrint` 또는 로거를 씁니다.

## 이 문서를 바꿀 때

- 구조나 기술 선택을 바꾸면 이 문서를 먼저 고치고, 같은 PR에서 코드를 바꿉니다.
