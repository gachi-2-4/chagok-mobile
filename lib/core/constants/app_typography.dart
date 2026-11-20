import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:flutter/painting.dart';

/// 차곡 디자인 시스템의 글자 스타일 토큰.
///
/// 크기·굵기·줄 높이는 Figma 값을 그대로 옮겼습니다.
///
/// 영문·숫자는 Figtree로, Figtree에 없는 한글은 Noto Sans KR로 그립니다.
/// Figma에서도 Figtree 글자의 한글은 Noto Sans KR로 보입니다.
abstract final class AppTypography {
  /// 기본 글꼴. 영문·숫자를 그립니다.
  static const fontFamily = 'Figtree';

  /// [fontFamily]에 없는 글자를 그릴 글꼴. 한글을 그립니다.
  static const fontFamilyFallback = ['NotoSansKR'];

  /// 로고 '차곡' 글자. 로고 두 글자만 담은 Jua 폰트를 씁니다.
  static const logo = TextStyle(
    fontFamily: 'Jua',
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 18,
    height: 27.9 / 18,
    fontWeight: FontWeight.w400,
    color: AppColors.logo,
  );

  /// 화면 상단의 큰 제목. 예: "처음 만나는 차곡"
  static const pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 27,
    height: 36.5 / 27,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  /// 제목 아래 설명 문장.
  static const pageDescription = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    height: 23.1 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 상단 바 가운데의 브랜드·화면 이름.
  static const topBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.brand,
  );

  /// 브랜드 색 없이 진한 글자로 쓰는 상단 바 제목. 예: "알림"
  static const topBarTitlePlain = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 17,
    height: 20.4 / 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 카드 제목. 예: "통신요금 비교"
  static const cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 17,
    height: 20.4 / 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 다이얼로그 제목.
  static const dialogTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 18,
    height: 26.1 / 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 다이얼로그 설명.
  static const dialogBody = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    height: 20.3 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// 다이얼로그 버튼 글자.
  static const dialogButton = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    height: 23.2 / 16,
    fontWeight: FontWeight.w700,
  );

  /// 본문.
  static const body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    height: 24.8 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 목록 행의 제목.
  static const listTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    height: 22.5 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 목록 행의 오른쪽 값. 예: "보통"
  static const listValue = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// 목록 행의 보조 설명, 목록 구역 제목.
  static const listSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    height: 19.5 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// 선택지(라디오·체크) 행의 글자.
  static const option = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    height: 21 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 버튼 글자.
  static const button = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    height: 18 / 15,
    fontWeight: FontWeight.w700,
  );

  /// 입력창 위 라벨.
  static const fieldLabel = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    height: 15.6 / 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 입력창 안의 글자.
  static const fieldInput = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    height: 16.8 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 작은 안내 문구·배너 글자.
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    height: 19.2 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// 칩·하단 탭 라벨처럼 한 줄로 쓰는 작은 글자.
  static const label = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    height: 14.4 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 목록 위에 붙는 작은 구역 이름. 예: "오늘", "이전 대화"
  static const eyebrow = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    height: 14.4 / 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    color: AppColors.brand,
  );

  /// 대화 말풍선 글자.
  static const chatBubble = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    height: 23.8 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 요일, 알림 시각처럼 가장 작은 글자.
  static const small = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 11,
    height: 13.2 / 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// "D-2"처럼 작은 표 안의 굵은 글자. 색은 표마다 바꿔 씁니다.
  static const tag = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 11,
    height: 13.2 / 11,
    fontWeight: FontWeight.w700,
    color: AppColors.brand,
  );

  /// 미니 캘린더의 날짜 숫자.
  static const calendarDay = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    height: 18 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 홈의 보관함 이름.
  static const boxName = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    height: 19.2 / 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}
