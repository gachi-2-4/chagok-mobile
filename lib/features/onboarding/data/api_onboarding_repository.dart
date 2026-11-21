import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:chagok_mobile/features/onboarding/data/address_region.dart';
import 'package:chagok_mobile/features/onboarding/data/housing_type.dart';
import 'package:chagok_mobile/features/onboarding/data/nationality.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_repository.dart';
import 'package:chagok_mobile/features/onboarding/data/welfare_status.dart';

/// 차곡 API 서버의 온보딩 설문 저장·내 정보 조회로 설문 답을 다루는 [OnboardingRepository].
///
/// 서버는 주소를 시·도와 시·군·구로만 저장하므로, 불러온 답의 [OnboardingAnswers.address]는
/// `서울특별시 마포구`처럼 두 값을 이은 글입니다.
class ApiOnboardingRepository implements OnboardingRepository {
  ApiOnboardingRepository({required this._client});

  final ApiClient _client;

  @override
  Future<OnboardingAnswers?> fetch() async {
    final profile = (await _client.get('/user/me')).mapOrNull('profile');
    if (profile == null) return null;
    final region = profile.mapOrNull('region');
    return OnboardingAnswers(
      nationality: switch (profile.stringOrNull('nationality')) {
        'KR' => Nationality.korean,
        'FOREIGN' => Nationality.foreigner,
        _ => null,
      },
      address: [
        region?.stringOrNull('sido'),
        region?.stringOrNull('sigungu'),
      ].whereType<String>().where((word) => word.isNotEmpty).join(' '),
      housingType: _housingTypes[profile.stringOrNull('housingType')],
      welfareStatus: _welfareStatuses[profile.stringOrNull('welfareType')],
    );
  }

  /// 네 질문의 답을 한 번에 저장합니다. 답하지 않은 질문(빈 주소 포함)이 있으면
  /// [ArgumentError]를 던집니다.
  @override
  Future<void> save(OnboardingAnswers answers) async {
    final OnboardingAnswers(:nationality, :housingType, :welfareStatus) =
        answers;
    if (nationality == null ||
        housingType == null ||
        welfareStatus == null ||
        answers.address.trim().isEmpty) {
      throw ArgumentError.value(answers, 'answers', '모든 질문에 답해야 저장할 수 있습니다');
    }
    final region = regionOf(answers.address);
    await _client.put(
      '/user/me/profile',
      body: {
        'nationality': switch (nationality) {
          Nationality.korean => 'KR',
          Nationality.foreigner => 'FOREIGN',
        },
        'region': {'sido': region.sido, 'sigungu': region.sigungu},
        'housingType': _codeOf(_housingTypes, housingType),
        'welfareType': _codeOf(_welfareStatuses, welfareStatus),
        // 생년월일은 가입할 때 받습니다. 소셜 가입자의 입력 화면이 생기면 넘깁니다.
        'birthDate': null,
      },
    );
  }

  static const _housingTypes = {
    'MONTHLY_RENT': HousingType.monthlyRent,
    'JEONSE': HousingType.jeonse,
    'OWNED': HousingType.owned,
    'DORMITORY': HousingType.dormitory,
    'WITH_PARENTS': HousingType.parentsHome,
  };

  static const _welfareStatuses = {
    'BASIC_LIVELIHOOD': WelfareStatus.basicLivelihood,
    'NEAR_POVERTY': WelfareStatus.nearPoverty,
    'OTHER': WelfareStatus.other,
    'NONE': WelfareStatus.none,
  };

  String _codeOf<T>(Map<String, T> codes, T value) =>
      codes.entries.firstWhere((entry) => entry.value == value).key;
}
