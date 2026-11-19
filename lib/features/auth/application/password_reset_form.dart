import 'package:chagok_mobile/features/auth/application/auth_validators.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';

/// 비밀번호 찾기 화면(L02~L04)에서 입력한 값과 진행 상태.
class PasswordResetForm {
  const PasswordResetForm({
    this.phoneNumber = '',
    this.newPassword = '',
    this.newPasswordConfirm = '',
    this.isSubmitting = false,
    this.failure,
  });

  /// 입력한 전화번호. 하이픈이 섞여 있을 수 있습니다.
  final String phoneNumber;

  /// 새 비밀번호.
  final String newPassword;

  /// 새 비밀번호 확인 칸.
  final String newPasswordConfirm;

  /// 요청을 보내는 중이면 true.
  final bool isSubmitting;

  /// 마지막 요청이 실패한 이유. 화면에서 이유에 맞는 안내를 보여 줍니다.
  final AuthFailure? failure;

  /// 하이픈 등을 뺀, 숫자만 남긴 전화번호.
  String get normalizedPhoneNumber => AuthValidators.digitsOnly(phoneNumber);

  /// 전화번호 형식이 맞고 보내는 중이 아니면 true.
  bool get canRequestCode =>
      AuthValidators.isValidPhoneNumber(phoneNumber) && !isSubmitting;

  /// 새 비밀번호가 비밀번호 규칙에 맞으면 true.
  bool get isNewPasswordValid => AuthValidators.isValidPassword(newPassword);

  /// 확인 칸을 채웠는데 새 비밀번호와 다르면 true.
  bool get hasPasswordMismatch =>
      newPasswordConfirm.isNotEmpty && newPasswordConfirm != newPassword;

  /// 새 비밀번호가 규칙에 맞고 확인 칸과 같으며 보내는 중이 아니면 true.
  bool get canReset =>
      isNewPasswordValid && newPasswordConfirm == newPassword && !isSubmitting;

  /// 넘긴 값만 바꾼 새 상태를 돌려줍니다. [failure]는 null로도 바꿀 수 있게 함수로 받습니다.
  PasswordResetForm copyWith({
    String? phoneNumber,
    String? newPassword,
    String? newPasswordConfirm,
    bool? isSubmitting,
    AuthFailure? Function()? failure,
  }) {
    return PasswordResetForm(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      newPassword: newPassword ?? this.newPassword,
      newPasswordConfirm: newPasswordConfirm ?? this.newPasswordConfirm,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: failure == null ? this.failure : failure(),
    );
  }
}
