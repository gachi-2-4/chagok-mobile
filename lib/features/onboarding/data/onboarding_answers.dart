import 'package:chagok_mobile/features/onboarding/data/housing_type.dart';
import 'package:chagok_mobile/features/onboarding/data/nationality.dart';
import 'package:chagok_mobile/features/onboarding/data/welfare_status.dart';

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

  /// 저장해 둔 JSON에서 답을 되살립니다. 모르는 값은 비워 둡니다.
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

  /// 국적. 아직 고르지 않았으면 null.
  final Nationality? nationality;

  /// 도로명주소.
  final String address;

  /// 사는 집의 형태. 아직 고르지 않았으면 null.
  final HousingType? housingType;

  /// 받고 있는 복지. 아직 고르지 않았으면 null.
  final WelfareStatus? welfareStatus;

  /// 넘긴 값만 바꾼 새 답을 돌려줍니다.
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
}
