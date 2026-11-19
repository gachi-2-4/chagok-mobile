/// 설정 화면 위에 보이는 내 정보.
class UserProfile {
  const UserProfile({required this.name, required this.phoneNumber});

  final String name;

  /// 숫자만 남긴 전화번호. 예: "01041845036"
  final String phoneNumber;

  factory UserProfile.fromJson(Map<String, Object?> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
    );
  }
}
