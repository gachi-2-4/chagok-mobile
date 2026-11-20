import 'package:chagok_mobile/features/auth/data/auth_failure.dart';

/// 계정 요청이 실패했을 때 던지는 예외.
class AuthException implements Exception {
  const AuthException(this.failure);

  /// 실패한 이유.
  final AuthFailure failure;

  @override
  String toString() => 'AuthException: ${failure.name}';
}
