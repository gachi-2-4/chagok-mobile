import 'package:chagok_mobile/features/auth/application/terms_consent_notifier.dart';
import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(termsConsentProvider, (_, _) {});
  });

  TermsConsentNotifier notifier() =>
      container.read(termsConsentProvider.notifier);

  group('TermsConsentNotifier', () {
    test('필수 약관에 모두 동의하면 완료할 수 있다', () {
      notifier().toggleTerm(Term.service);
      expect(container.read(termsConsentProvider).canComplete, isFalse);

      notifier().toggleTerm(Term.privacy);

      expect(container.read(termsConsentProvider).canComplete, isTrue);
    });

    test('전체 동의를 두 번 누르면 모두 해제한다', () {
      notifier()
        ..toggleAllTerms()
        ..toggleAllTerms();

      expect(container.read(termsConsentProvider).agreedTerms, isEmpty);
    });

    test('필수 약관에 동의하지 않으면 기록하지 않는다', () async {
      final isCompleted = await notifier().complete();

      expect(isCompleted, isFalse);
      expect(repository.termsAgreements, isEmpty);
    });

    test('완료하면 마케팅 동의 여부를 기록한다', () async {
      notifier().toggleAllTerms();

      final isCompleted = await notifier().complete();

      expect(isCompleted, isTrue);
      expect(repository.termsAgreements, [true]);
    });

    test('기록이 실패하면 실패 이유를 상태에 담고 보내는 중 상태를 푼다', () async {
      repository.error = const AuthException(AuthFailure.unknown);
      notifier().toggleAllTerms();

      final isCompleted = await notifier().complete();

      final form = container.read(termsConsentProvider);
      expect(isCompleted, isFalse);
      expect(form.failure, AuthFailure.unknown);
      expect(form.isSubmitting, isFalse);
    });
  });
}
