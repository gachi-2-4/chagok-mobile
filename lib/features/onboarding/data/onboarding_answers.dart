/// 국적.
enum Nationality { korean, foreigner }

/// 사는 집의 형태.
enum HousingType { monthlyRent, jeonse, owned, dormitory, parentsHome }

/// 받고 있는 복지.
enum WelfareStatus { basicLivelihood, nearPoverty, other, none }

/// 첫 설문(O01~O04)에서 받은 답.
///
/// 답에 맞춰 서류 설명과 알림을 고르는 데 씁니다.
class OnboardingAnswers {
  const OnboardingAnswers({
    this.nationality,
    this.address = '',
    this.housingType,
    this.welfareStatus,
  });

  final Nationality? nationality;

  /// 도로명주소.
  final String address;

  final HousingType? housingType;
  final WelfareStatus? welfareStatus;

  OnboardingAnswers copyWith({
    Nationality? nationality,
    String? address,
    HousingType? housingType,
    WelfareStatus? welfareStatus,
  }) {
    return OnboardingAnswers(
      nationality: nationality ?? this.nationality,
      address: address ?? this.address,
      housingType: housingType ?? this.housingType,
      welfareStatus: welfareStatus ?? this.welfareStatus,
    );
  }

  /// 저장할 때 쓰는 JSON.
  Map<String, Object?> toJson() {
    return {
      'nationality': nationality?.name,
      'address': address,
      'housingType': housingType?.name,
      'welfareStatus': welfareStatus?.name,
    };
  }

  factory OnboardingAnswers.fromJson(Map<String, Object?> json) {
    T? byName<T extends Enum>(List<T> values, Object? name) {
      for (final value in values) {
        if (value.name == name) return value;
      }
      return null;
    }

    return OnboardingAnswers(
      nationality: byName(Nationality.values, json['nationality']),
      address: json['address'] as String? ?? '',
      housingType: byName(HousingType.values, json['housingType']),
      welfareStatus: byName(WelfareStatus.values, json['welfareStatus']),
    );
  }
}
