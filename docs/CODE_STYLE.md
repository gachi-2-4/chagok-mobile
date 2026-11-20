# 코드 스타일

이 문서는 Dart/Flutter 코드를 작성하는 방식을 정합니다.
기본은 [Effective Dart](https://dart.dev/effective-dart)와 `flutter_lints`이고, 여기서는 이 프로젝트에서 추가로 지킬 규칙을 적습니다.

## 기본

- 커밋 전 `dart format .`과 `flutter analyze`를 통과시킵니다. 경고(warning)·정보(info)도 남기지 않습니다.
- 이 문서의 규칙 중 자동으로 검사할 수 있는 것은 `analysis_options.yaml` 린트로 켜 두었습니다. 규칙을 바꿀 때는 두 파일을 함께 고칩니다.
- 린트를 끄는 `// ignore:`는 꼭 필요할 때만 쓰고, 이유를 같은 줄이나 위 줄에 적습니다.
- 문자열은 작은따옴표(`'`)를 씁니다.
- 줄 끝 쉼표(trailing comma)는 `dart format`이 자동으로 넣고 빼므로 직접 맞추지 않습니다.

## 이름 규칙

| 대상 | 형식 | 예 |
|------|------|-----|
| 파일·폴더 | `snake_case` | `todo_list_screen.dart` |
| 클래스·enum·typedef | `UpperCamelCase` | `TodoListScreen` |
| 변수·함수·매개변수 | `lowerCamelCase` | `fetchTodos` |
| 상수 | `lowerCamelCase` | `const defaultPadding = 16.0;` |
| private | `_` 접두사 | `_buildHeader` |
| Provider | `<대상>Provider` | `todoListProvider` |

### 파일 이름 접미사

| 역할 | 접미사 | 예 |
|------|--------|-----|
| 화면(라우트 단위) | `_screen.dart` | `login_screen.dart` |
| 재사용 위젯 | 역할을 드러내는 이름 | `todo_tile.dart` |
| 상태·로직 | `_notifier.dart` | `todo_list_notifier.dart` |
| 저장소 | `_repository.dart` | `todo_repository.dart` |
| 모델 | 단수 명사 | `todo.dart` |

- 이름은 줄이지 않고 뜻이 드러나게 씁니다. (`btn` ✗ → `button` ✓)
- bool은 `is`, `has`, `can` 등으로 시작합니다. 예: `isLoading`, `hasError`
- 한 파일에는 public 클래스 하나를 원칙으로 합니다. 그 클래스만 쓰는 작은 private 위젯은 같은 파일에 둘 수 있습니다.
  - `sealed` 클래스와 그 하위 클래스는 언어 규칙상 같은 파일에 있어야 하므로 한 묶음으로 봅니다.

## import

- 프로젝트 내부 파일은 `package:chagok_mobile/...` 절대 경로로 import합니다. 상대 경로(`../`)는 쓰지 않습니다.
- 순서는 `directives_ordering` 린트를 따릅니다.
  1. `dart:` 
  2. `package:` (Flutter, 외부 패키지, 프로젝트 내부 구분 없이 **알파벳순**)
- 두 그룹 사이는 한 줄 띄웁니다. IDE의 "Organize Imports"를 쓰면 자동으로 정렬됩니다.

```dart
import 'dart:async';

import 'package:chagok_mobile/features/todo/application/todo_list_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
```

## 위젯 작성

- 가능한 모든 곳에 `const`를 붙입니다.
- `build` 메서드가 길어지면(대략 80줄 이상, 들여쓰기가 깊어지면) 별도 위젯 클래스로 분리합니다.
  - `Widget _buildXxx()` private 메서드보다 **위젯 클래스**로 분리합니다. (리빌드 범위, `const` 활용, 테스트에 유리)
- 상태가 필요 없으면 `StatelessWidget`, Riverpod 상태를 읽으면 `ConsumerWidget`을 씁니다.
  - `StatefulWidget`은 `TextEditingController`, `AnimationController`처럼 위젯 생명주기에 묶인 객체가 있을 때만 씁니다.
- 생성자의 매개변수는 named parameter로 받고, 필수 값은 `required`를 붙입니다.
- 색상·글자 크기·간격·모서리는 하드코딩하지 않고 `Theme.of(context)`나 `core/constants`의 값(`AppColors`·`AppTypography`·`AppSpacing`·`AppRadius`)을 씁니다.
  - 너비·높이·아이콘 크기처럼 부품 자체의 크기(모서리 제외)는 위젯 안에 이름을 붙인 private 상수로 둘 수 있습니다. (예: `static const _iconSize = 22.0;`) 이름 없는 숫자를 바로 쓰지는 않습니다.
- 화면에 보이는 문자열은 한 곳에 모아 관리할 수 있게 작성합니다. (다국어 도입 시 옮기기 쉽도록)

## Dart 문법

- 타입을 추론할 수 있으면 지역 변수는 `final` / `var`를 쓰고, public API(함수 반환값, 필드)는 타입을 명시합니다.
- 다시 대입하지 않는 변수는 항상 `final`로 선언합니다.
- `!`(null 강제 해제)는 피하고, null 체크나 패턴 매칭으로 처리합니다.
- 분기가 여러 개면 `if-else` 연쇄 대신 `switch` 식과 패턴 매칭을 씁니다.
- 비동기 함수는 `async`/`await`로 쓰고, 반환하지 않는 `Future`는 `unawaited()`로 의도를 표시합니다.

## 주석

- 코드가 **무엇을** 하는지는 코드로 드러나게 쓰고, 주석은 **왜** 그렇게 했는지를 적습니다.
- public 클래스·함수에는 `///` 문서 주석을 답니다. 첫 문장은 한 줄 요약입니다.
- 할 일은 `// TODO: 내용` 형식으로 남기고, 오래 남기지 않습니다.
- 주석 처리한 옛 코드는 지우고 커밋합니다. (기록은 git에 있습니다)
