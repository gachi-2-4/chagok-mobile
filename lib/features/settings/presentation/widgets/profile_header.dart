import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/settings/data/user_profile.dart';
import 'package:flutter/material.dart';

/// 설정 화면 위의 프로필 한 줄. 동그란 사진 자리, 이름, 전화번호.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.profile, super.key});

  final UserProfile? profile;

  static const _avatarSize = 48.0;
  static const _avatarGap = 14.0;

  /// Figma `profile` 위·아래·오른쪽 여백.
  static const _top = 12.0;
  static const _bottom = 18.0;

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        _top,
        AppSpacing.xl,
        _bottom,
      ),
      child: Row(
        children: [
          const SizedBox.square(
            dimension: _avatarSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: _avatarGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.name ?? '',
                  style: AppTypography.cardTitle.copyWith(height: 23.8 / 17),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _formatPhoneNumber(profile?.phoneNumber ?? ''),
                  style: AppTypography.listSubtitle.copyWith(height: 18.2 / 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "01041845036" → "010-4184-5036". 형식이 다르면 그대로 둡니다.
String _formatPhoneNumber(String digits) {
  return switch (digits.length) {
    11 =>
      '${digits.substring(0, 3)}-${digits.substring(3, 7)}-'
          '${digits.substring(7)}',
    10 =>
      '${digits.substring(0, 3)}-${digits.substring(3, 6)}-'
          '${digits.substring(6)}',
    _ => digits,
  };
}
