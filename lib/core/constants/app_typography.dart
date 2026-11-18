import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:flutter/painting.dart';

/// 차곡 디자인 시스템의 글자 스타일 토큰.
///
/// 크기·굵기·줄 높이는 Figma 값을 그대로 옮겼습니다.
// TODO: 디자인에서 쓰는 Noto Sans KR·Figtree 폰트를 번들할지 정해지면 fontFamily 지정
abstract final class AppTypography {
  /// 화면 상단의 큰 제목. 예: "처음 만나는 차곡"
  static const pageTitle = TextStyle(
    fontSize: 27,
    height: 36.5 / 27,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  /// 제목 아래 설명 문장.
  static const pageDescription = TextStyle(
    fontSize: 14,
    height: 23.1 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 상단 바 가운데의 브랜드·화면 이름.
  static const topBarTitle = TextStyle(
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.brand,
  );

  /// 카드 제목. 예: "통신요금 비교"
  static const cardTitle = TextStyle(
    fontSize: 17,
    height: 20.4 / 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 다이얼로그 제목.
  static const dialogTitle = TextStyle(
    fontSize: 18,
    height: 26.1 / 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 다이얼로그 설명.
  static const dialogBody = TextStyle(
    fontSize: 14,
    height: 20.3 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// 다이얼로그 버튼 글자.
  static const dialogButton = TextStyle(
    fontSize: 16,
    height: 23.2 / 16,
    fontWeight: FontWeight.w700,
  );

  /// 본문.
  static const body = TextStyle(
    fontSize: 15,
    height: 24.8 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 목록 행의 제목.
  static const listTitle = TextStyle(
    fontSize: 15,
    height: 22.5 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 목록 행의 오른쪽 값. 예: "보통"
  static const listValue = TextStyle(
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// 목록 행의 보조 설명, 목록 구역 제목.
  static const listSubtitle = TextStyle(
    fontSize: 13,
    height: 19.5 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// 선택지(라디오·체크) 행의 글자.
  static const option = TextStyle(
    fontSize: 15,
    height: 21 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 버튼 글자.
  static const button = TextStyle(
    fontSize: 15,
    height: 18 / 15,
    fontWeight: FontWeight.w700,
  );

  /// 입력창 위 라벨.
  static const fieldLabel = TextStyle(
    fontSize: 13,
    height: 15.6 / 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 입력창 안의 글자.
  static const fieldInput = TextStyle(
    fontSize: 14,
    height: 16.8 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// 작은 안내 문구·배너 글자.
  static const caption = TextStyle(
    fontSize: 12,
    height: 19.2 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// 칩·하단 탭 라벨처럼 한 줄로 쓰는 작은 글자.
  static const label = TextStyle(
    fontSize: 12,
    height: 14.4 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
}
