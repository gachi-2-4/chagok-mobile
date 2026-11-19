/// 설정 화면 위에 보이는 내 정보.
class UserProfile {
  const UserProfile({required this.name, required this.phoneNumber});

  /// 서버가 준 JSON에서 만듭니다. 없는 값은 빈 글로 둡니다.
  factory UserProfile.fromJson(Map<String, Object?> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
    );
  }

  /// 이름.
  final String name;

  /// 숫자만 남긴 전화번호. 예: "01041845036"
  final String phoneNumber;
}
