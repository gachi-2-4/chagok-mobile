import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:flutter/material.dart';

/// 보관함 색·아이콘 값을 화면에 그릴 색과 아이콘으로 바꿉니다.
abstract final class BoxStyle {
  /// 상자 뚜껑과 손잡이 색.
  static Color lidColor(BoxColor color) => switch (color) {
    BoxColor.peach => AppColors.boxLid,
    BoxColor.green => AppColors.boxLidGreen,
    BoxColor.gray => AppColors.boxLidGray,
  };

  /// 상자 몸통 색. 색 고르기 칸과 상세 화면의 아이콘 칸에도 씁니다.
  static Color bodyColor(BoxColor color) => switch (color) {
    BoxColor.peach => AppColors.boxBody,
    BoxColor.green => AppColors.boxBodyGreen,
    BoxColor.gray => AppColors.boxBodyGray,
  };

  /// 종류 아이콘.
  static IconData icon(BoxIcon icon) => switch (icon) {
    BoxIcon.home => Icons.home_outlined,
    BoxIcon.car => Icons.directions_car_outlined,
    BoxIcon.tax => Icons.receipt_long_outlined,
    BoxIcon.health => Icons.favorite_border_rounded,
    BoxIcon.telecom => Icons.wifi_rounded,
    BoxIcon.work => Icons.work_outline_rounded,
    BoxIcon.education => Icons.school_outlined,
    BoxIcon.pet => Icons.pets_outlined,
    BoxIcon.travel => Icons.flight_outlined,
    BoxIcon.life => Icons.sentiment_satisfied_outlined,
    BoxIcon.bank => Icons.account_balance_outlined,
    BoxIcon.package => Icons.view_in_ar_outlined,
  };
}
