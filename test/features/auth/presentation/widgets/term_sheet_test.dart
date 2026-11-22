import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:chagok_mobile/features/auth/presentation/term_texts.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/terms_agreement_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpForm(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: TermsAgreementForm(
          agreedTerms: const {},
          hasAgreedToAll: false,
          canComplete: false,
          failure: null,
          onToggleAll: () {},
          onToggleTerm: (_) {},
          onComplete: () {},
        ),
      ),
    );
  }

  group('showTermSheet', () {
    testWidgets('약관 보기를 누르면 그 약관의 조항을 시트로 보여 준다', (tester) async {
      await pumpForm(tester);

      await tester.tap(find.text(AuthStrings.viewTerm).first);
      await tester.pumpAndSettle();

      expect(find.text(TermTexts.draftNotice), findsOneWidget);
      expect(find.text(TermTexts.of(Term.service).first.title), findsOneWidget);
    });

    testWidgets('마케팅 약관 보기를 누르면 곧 지원 안내 대신 본문을 보여 준다', (tester) async {
      await pumpForm(tester);

      await tester.tap(find.text(AuthStrings.viewTerm).last);
      await tester.pumpAndSettle();

      expect(find.text(AuthStrings.comingSoon), findsNothing);
      expect(
        find.text(TermTexts.of(Term.marketing).first.title),
        findsOneWidget,
      );
    });
  });
}
