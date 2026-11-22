import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';

/// 간편 로그인으로 만든 계정의 약관 동의(A03) 상태.
class TermsConsentForm {
  const TermsConsentForm({
    this.agreedTerms = const {},
    this.isSubmitting = false,
    this.failure,
  });

  /// 동의한 약관.
  final Set<Term> agreedTerms;

  /// 동의 기록을 보내는 중이면 true.
  final bool isSubmitting;

  /// 마지막 요청이 실패한 이유.
  final AuthFailure? failure;

  /// 모든 약관에 동의했으면 true.
  bool get hasAgreedToAll => agreedTerms.length == Term.values.length;

  /// 필수 약관에 모두 동의했고 보내는 중이 아니면 true.
  bool get canComplete =>
      Term.values
          .where((term) => term.isRequired)
          .every(agreedTerms.contains) &&
      !isSubmitting;

  /// 넘긴 값만 바꾼 새 상태를 돌려줍니다.
  ///
  /// [failure]는 null로도 바꿀 수 있게 함수로 받습니다.
  TermsConsentForm copyWith({
    Set<Term>? agreedTerms,
    bool? isSubmitting,
    AuthFailure? Function()? failure,
  }) {
    return TermsConsentForm(
      agreedTerms: agreedTerms ?? this.agreedTerms,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: failure == null ? this.failure : failure(),
    );
  }
}
