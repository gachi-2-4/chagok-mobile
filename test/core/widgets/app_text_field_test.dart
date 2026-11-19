import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppTextField', () {
    testWidgets('라벨과 힌트를 보여 준다', (tester) async {
      await tester.pumpApp(
        const AppTextField(label: '이메일', hintText: 'hello@example.com'),
      );

      expect(find.text('이메일'), findsOneWidget);
      expect(find.text('hello@example.com'), findsOneWidget);
    });

    testWidgets('글자를 입력하면 onChanged로 전달한다', (tester) async {
      String? changedText;
      await tester.pumpApp(
        AppTextField(label: '이메일', onChanged: (text) => changedText = text),
      );

      await tester.enterText(find.byType(TextField), 'a@b.com');

      expect(changedText, 'a@b.com');
    });

    testWidgets('obscureText가 true면 입력 내용을 가린다', (tester) async {
      await tester.pumpApp(
        const AppTextField(label: '비밀번호', obscureText: true),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.obscureText, isTrue);
    });

    testWidgets('라벨을 비우면 입력창만 보여 준다', (tester) async {
      await tester.pumpApp(const AppTextField(hintText: '대화 내용 검색'));

      final labels = find.byWidgetPredicate(
        (widget) => widget is Text && widget.style == AppTypography.fieldLabel,
      );
      expect(labels, findsNothing);
      expect(find.text('대화 내용 검색'), findsOneWidget);
    });
  });
}
