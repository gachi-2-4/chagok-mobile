import 'package:chagok_mobile/features/onboarding/data/housing_type.dart';
import 'package:chagok_mobile/features/onboarding/data/nationality.dart';
import 'package:chagok_mobile/features/onboarding/data/welfare_status.dart';

/// 첫 설문 화면에 보이는 문구.
///
/// 다국어를 도입할 때 옮기기 쉽도록 한곳에 모읍니다.
abstract final class OnboardingStrings {
  static const barTitle = '첫 설문';
  static const next = '다음';
  static const complete = '완료';
  static const submitFailed = '답을 저장하지 못했어요. 다시 시도해 주세요.';

  // O01 국적
  static const nationalityTitle = '내국인이신가요?';
  static const nationalityDescription = '상황에 맞는 설명을 준비할게요.';

  static String nationality(Nationality value) => switch (value) {
    Nationality.korean => '내국인',
    Nationality.foreigner => '외국인',
  };

  // O02 지역
  static const addressTitle = '어느 지역에 사시나요?';
  static const addressDescription = '사는 지역을 알려주세요.';
  static const addressLabel = '도로명주소 검색';
  static const addressHint = '예: 서울 마포구';

  /// 주소 후보 목록을 화면 읽기 프로그램에 알리는 이름.
  static const addressSuggestions = '주소 검색 결과';

  // O03 주거 형태
  static const housingTypeTitle = '어떤 집에서 사시나요?';
  static const housingTypeDescription = '집 형태에 맞는 서류를 알려 드릴게요.';

  static String housingType(HousingType value) => switch (value) {
    HousingType.monthlyRent => '월세',
    HousingType.jeonse => '전세',
    HousingType.owned => '자가',
    HousingType.dormitory => '기숙사/고시원',
    HousingType.parentsHome => '부모님 집',
  };

  // O04 복지
  static const welfareTitle = '현재 받고계신 복지가 있나요?';
  static const welfareDescription = '서류 대상자인지 알기 위해 필요해요.';

  static String welfareStatus(WelfareStatus value) => switch (value) {
    WelfareStatus.basicLivelihood => '기초생활수급 대상자',
    WelfareStatus.nearPoverty => '차상위계층 대상자',
    WelfareStatus.other => '기타',
    WelfareStatus.none => '해당 없음',
  };

  /// 화면 읽기 프로그램용 진행 상황. 예: "4단계 중 2단계"
  static String progress(int current, int total) => '$total단계 중 $current단계';
}
