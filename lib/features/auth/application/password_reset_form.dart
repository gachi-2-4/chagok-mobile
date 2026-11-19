import 'package:chagok_mobile/features/auth/application/auth_validators.dart';

/// 비밀번호 찾기 화면(L02~L04)에서 입력한 값과 진행 상태.
class PasswordResetForm {
  const PasswordResetForm({
    this.phoneNumber = '',
    this.newPassword = '',
    this.newPasswordConfirm = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String phoneNumber;
  final String newPassword;
  final String newPasswordConfirm;
  final bool isSubmitting;

  /// 마지막 요청이 실패한 이유. 사용자에게 보여 줍니다.
  final String? errorMessage;

  /// 하이픈 등을 뺀, 숫자만 남긴 전화번호.
  String get normalizedPhoneNumber => AuthValidators.digitsOnly(phoneNumber);

  bool get canRequestCode =>
      AuthValidators.isValidPhoneNumber(phoneNumber) && !isSubmitting;

  bool get isNewPasswordValid => AuthValidators.isValidPassword(newPassword);

  /// 확인 칸을 채웠는데 새 비밀번호와 다르면 true.
  bool get hasPasswordMismatch =>
      newPasswordConfirm.isNotEmpty && newPasswordConfirm != newPassword;

  bool get canReset =>
      isNewPasswordValid && newPasswordConfirm == newPassword && !isSubmitting;

  PasswordResetForm copyWith({
    String? phoneNumber,
    String? newPassword,
    String? newPasswordConfirm,
    bool? isSubmitting,
    String? Function()? errorMessage,
  }) {
    return PasswordResetForm(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      newPassword: newPassword ?? this.newPassword,
      newPasswordConfirm: newPasswordConfirm ?? this.newPasswordConfirm,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage == null ? this.errorMessage : errorMessage(),
    );
  }
}
