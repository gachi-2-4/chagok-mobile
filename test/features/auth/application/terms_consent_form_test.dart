import 'package:chagok_mobile/features/auth/application/terms_consent_form.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TermsConsentForm', () {
    test('필수 약관만 동의하면 완료할 수 있지만 전체 동의는 아니다', () {
      const form = TermsConsentForm(agreedTerms: {Term.service, Term.privacy});

      expect(form.canComplete, isTrue);
      expect(form.hasAgreedToAll, isFalse);
    });

    test('필수 약관 하나가 빠지면 완료할 수 없다', () {
      const form = TermsConsentForm(
        agreedTerms: {Term.service, Term.marketing},
      );

      expect(form.canComplete, isFalse);
    });

    test('보내는 중이면 모두 동의해도 완료할 수 없다', () {
      final form = TermsConsentForm(
        agreedTerms: Term.values.toSet(),
        isSubmitting: true,
      );

      expect(form.canComplete, isFalse);
    });
  });
}
