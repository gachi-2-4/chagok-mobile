import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/settings/data/user_profile.dart';
import 'package:flutter/material.dart';

/// 설정 화면 위의 프로필 한 줄. 동그란 사진 자리, 이름, 전화번호.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.profile, this.errorMessage, super.key});

  /// 보여 줄 내 정보. 불러오는 중이면 null.
  final UserProfile? profile;

  /// 내 정보를 불러오지 못했을 때 이름 자리에 보여 줄 안내.
  final String? errorMessage;

  static const _avatarSize = 48.0;

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.block,
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
          const SizedBox(width: AppSpacing.avatarGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorMessage ?? profile?.name ?? '',
                  style: AppTypography.profileName,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _formatPhoneNumber(profile?.phoneNumber ?? ''),
                  style: AppTypography.profileDetail,
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
