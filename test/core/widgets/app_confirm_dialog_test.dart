import 'package:chagok_mobile/core/widgets/app_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

/// 버튼을 누르면 확인 창을 띄우고 결과를 [onResult]로 넘기는 테스트용 화면.
class _DialogLauncher extends StatelessWidget {
  const _DialogLauncher({required this.onResult});

  final ValueChanged<bool> onResult;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final result = await AppConfirmDialog.show(
          context,
          title: '로그아웃하시겠어요?',
        );
        onResult(result);
      },
      child: const Text('열기'),
    );
  }
}

void main() {
  group('AppConfirmDialog', () {
    testWidgets('"예"를 누르면 true를 돌려준다', (tester) async {
      bool? result;
      await tester.pumpApp(
        _DialogLauncher(onResult: (value) => result = value),
      );
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('예'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.text('로그아웃하시겠어요?'), findsNothing);
    });

    testWidgets('"아니요"를 누르면 false를 돌려준다', (tester) async {
      bool? result;
      await tester.pumpApp(
        _DialogLauncher(onResult: (value) => result = value),
      );
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('아니요'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('바깥을 눌러 닫으면 false를 돌려준다', (tester) async {
      bool? result;
      await tester.pumpApp(
        _DialogLauncher(onResult: (value) => result = value),
      );
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });
}
