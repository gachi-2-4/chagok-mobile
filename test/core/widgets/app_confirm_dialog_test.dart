import 'package:chagok_mobile/core/widgets/app_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

/// 버튼을 누르면 확인 창을 띄우고 결과를 [onResult]로 넘기는 테스트용 화면.
class _DialogLauncher extends StatelessWidget {
  const _DialogLauncher({required this.onResult, this.description});

  final ValueChanged<bool> onResult;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final result = await AppConfirmDialog.show(
          context,
          title: '로그아웃하시겠어요?',
          description: description,
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

    testWidgets('설명이 길고 글자가 커도 "예"를 눌러 true를 돌려준다', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      bool? result;
      await tester.pumpApp(
        _DialogLauncher(
          description: '회원 정보와 모든 서류가 삭제됩니다. ' * 100,
          onResult: (value) => result = value,
        ),
      );
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();

      final screenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(tester.getRect(find.text('예')).bottom, lessThan(screenHeight));
      await tester.tap(find.text('예'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });
}
