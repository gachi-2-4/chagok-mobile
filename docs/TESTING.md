# 테스트

이 문서는 무엇을, 어디에, 어떻게 테스트할지 정합니다.

## 무엇을 테스트하나

| 대상 | 종류 | 기준 |
|------|------|------|
| `application/` Notifier | 단위 테스트 | **필수.** 상태 변화와 로직을 모두 검증 |
| `data/` Repository, 모델 | 단위 테스트 | **필수.** JSON 변환, 데이터 가공 로직 |
| `core/utils`, 확장 메서드 | 단위 테스트 | **필수.** 순수 함수는 테스트하기 쉬우므로 빠짐없이 |
| `presentation/` 화면 | 위젯 테스트 | 핵심 화면만. 로딩·에러·데이터 상태 표시, 주요 사용자 동작 |
| 전체 사용자 흐름 | 통합 테스트 | 지금은 쓰지 않음. 핵심 흐름이 생기면 도입 검토 |

- 버그를 고칠 때는 그 버그를 재현하는 테스트를 먼저 추가하고 고칩니다.
- 단순히 값을 전달만 하는 코드나 화면 레이아웃 자체는 테스트하지 않아도 됩니다.

## 파일 위치와 이름

- `test/` 폴더는 `lib/` 구조를 그대로 따릅니다.
- 파일 이름은 대상 파일 이름 뒤에 `_test.dart`를 붙입니다.

```
lib/features/todo/application/todo_list_notifier.dart
test/features/todo/application/todo_list_notifier_test.dart
```

## 작성 방법

- `group`으로 대상(클래스·메서드)을 묶고, `test` 설명은 **"~하면 ~한다"** 형식으로 씁니다.
- 한 테스트는 한 가지 동작만 검증합니다.
- 구조는 준비(Arrange) → 실행(Act) → 검증(Assert) 순서로, 빈 줄로 구분합니다.

```dart
void main() {
  group('TodoListNotifier', () {
    test('할 일을 추가하면 목록에 포함된다', () async {
      final container = ProviderContainer(
        overrides: [
          todoRepositoryProvider.overrideWithValue(FakeTodoRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(todoListProvider.notifier).add('장보기');

      final todos = await container.read(todoListProvider.future);
      expect(todos.map((todo) => todo.title), contains('장보기'));
    });
  });
}
```

## Riverpod 테스트

- Notifier 테스트는 `ProviderContainer`를 만들어 진행하고, `addTearDown(container.dispose)`로 정리합니다.
- 위젯 테스트는 `ProviderScope(overrides: [...])`로 감싸서 진행합니다.
- 외부 의존(API, 저장소)은 `overrides`로 가짜 구현을 주입합니다. 실제 네트워크·디스크에 접근하지 않습니다.

## 가짜 객체 (Fake / Mock)

- 먼저 **직접 만든 Fake 클래스**를 씁니다. (`class FakeTodoRepository implements TodoRepository`)
  - 동작이 단순하고 읽기 쉬우며 패키지가 필요 없습니다.
- 호출 횟수·인자 검증이 꼭 필요할 때만 mock 패키지(`mocktail`) 도입을 검토합니다.
- 여러 테스트에서 쓰는 Fake는 `test/helpers/`에 둡니다.

## 실행

```bash
flutter test                                  # 전체
flutter test test/features/todo/              # 폴더 단위
flutter test --name "할 일을 추가하면"          # 이름으로 골라 실행
flutter test --coverage                       # 커버리지 (coverage/lcov.info)
```

- PR을 올리기 전 전체 테스트가 통과해야 합니다.
- 커버리지 수치 목표는 두지 않고, 위 "무엇을 테스트하나" 기준을 지키는 것을 우선합니다.
