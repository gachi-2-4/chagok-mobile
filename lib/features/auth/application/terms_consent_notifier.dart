import 'package:chagok_mobile/features/auth/application/terms_consent_form.dart';
import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 간편 로그인 뒤 약관 동의 상태. 화면을 벗어나면 비웁니다.
final termsConsentProvider =
    NotifierProvider.autoDispose<TermsConsentNotifier, TermsConsentForm>(
      TermsConsentNotifier.new,
    );

/// 간편 로그인으로 만든 계정의 약관 동의를 받고 서버에 기록합니다.
///
/// 전화번호 가입은 가입 요청에 동의를 함께 보내지만(`SignUpNotifier`), 간편 로그인은
/// 계정이 먼저 생기므로 동의만 따로 보냅니다.
class TermsConsentNotifier extends Notifier<TermsConsentForm> {
  @override
  TermsConsentForm build() => const TermsConsentForm();

  /// 약관 하나의 동의 여부를 바꿉니다.
  void toggleTerm(Term term) {
    final agreed = {...state.agreedTerms};
    if (!agreed.remove(term)) agreed.add(term);
    state = state.copyWith(agreedTerms: agreed);
  }

  /// 모두 동의했으면 모두 해제하고, 아니면 모두 동의합니다.
  void toggleAllTerms() {
    state = state.copyWith(
      agreedTerms: state.hasAgreedToAll ? const {} : Term.values.toSet(),
    );
  }

  /// 동의를 기록합니다. 기록했으면 true.
  Future<bool> complete() async {
    final form = state;
    if (!form.canComplete) return false;
    state = state.copyWith(isSubmitting: true, failure: () => null);
    try {
      await ref
          .read(authRepositoryProvider)
          .agreeToTerms(
            agreedToMarketing: form.agreedTerms.contains(Term.marketing),
          );
      if (ref.mounted) state = state.copyWith(isSubmitting: false);
      return true;
    } catch (error, stackTrace) {
      // AuthException이 아닌 예외도 잡아 보내는 중 상태로 멈추지 않게 합니다.
      final failure = switch (error) {
        AuthException(:final failure) => failure,
        _ => AuthFailure.unknown,
      };
      if (failure == AuthFailure.unknown) {
        debugPrint('약관 동의를 기록하지 못했습니다: $error\n$stackTrace');
      }
      if (ref.mounted) {
        state = state.copyWith(isSubmitting: false, failure: () => failure);
      }
      return false;
    }
  }
}
