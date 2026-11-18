# 아키텍처

이 문서는 앱 코드의 구조와 기술 선택, 계층 사이의 규칙을 정합니다.
새 기능을 만들거나 구조를 바꿀 때 이 문서를 기준으로 합니다.

## 기술 선택

| 영역 | 선택 | 비고 |
|------|------|------|
| 상태 관리 | [Riverpod](https://riverpod.dev) (`flutter_riverpod`) | `Notifier` / `AsyncNotifier` 사용 |
| 라우팅 | [go_router](https://pub.dev/packages/go_router) | 경로 상수는 한 곳에서 관리 |
| 폴더 구조 | 기능 단위 (feature-first) | 기능마다 `presentation / application / data` |

> 패키지는 첫 기능을 만들 때 `flutter pub add flutter_riverpod go_router`로 추가합니다.
> 코드 생성(`riverpod_generator`, `freezed`, `build_runner`)은 처음엔 쓰지 않고, 보일러플레이트가 부담될 때 도입을 검토합니다.

## 폴더 구조

```
lib/
  main.dart                  # 진입점: ProviderScope로 감싼 App 실행만 담당
  app/
    app.dart                 # MaterialApp.router, 테마 연결
    router.dart              # GoRouter 설정, 경로 정의
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
- `ref.watch`는 `build` 안에서, `ref.read`는 이벤트 핸들러(버튼 콜백 등) 안에서만 씁니다.

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

## 에러 처리

- data 계층에서 발생한 예외는 application 계층에서 `AsyncValue.guard` 등으로 잡아 상태로 바꿉니다.
- UI는 예외를 직접 `try/catch`하지 않고, 에러 상태를 받아 사용자에게 보여줍니다.
- 사용자에게 보여줄 메시지와 개발용 로그를 구분합니다. `print` 대신 `debugPrint` 또는 로거를 씁니다.

## 이 문서를 바꿀 때

- 구조나 기술 선택을 바꾸면 이 문서를 먼저 고치고, 같은 PR에서 코드를 바꿉니다.
