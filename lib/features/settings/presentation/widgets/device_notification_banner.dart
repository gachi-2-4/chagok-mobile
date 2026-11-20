import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/settings/presentation/settings_strings.dart';
import 'package:flutter/material.dart';

/// "알림이 오지 않는다면? 기기 알림 켜기" 주황 배너.
///
/// Figma S03 `div.banner`에 해당합니다. 꺼진 종 그림은 아이콘으로 대신합니다.
class DeviceNotificationBanner extends StatelessWidget {
  const DeviceNotificationBanner({required this.onTap, super.key});

  /// 배너를 눌렀을 때 동작. 기기 알림 설정을 엽니다.
  final VoidCallback onTap;

  /// 배너의 최소 높이. 글자를 키우면 내용에 맞게 늘어납니다.
  static const _minHeight = 92.0;
  static const _illustrationSize = 72.0;
  static const _iconSize = 44.0;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.solidBanner);

    return Material(
      color: AppColors.primary,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.bannerIllustrationInset,
              right: AppSpacing.xl,
            ),
            child: Row(
              children: [
                Container(
                  width: _illustrationSize,
                  height: _illustrationSize,
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_off_rounded,
                    size: _iconSize,
                    color: AppColors.peach,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // 글자를 키워도 넘치지 않도록 남은 너비 안에서 줄을 바꿉니다.
                const Expanded(child: _BannerText()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "알림이 오지 않는다면? / 기기 알림 켜기" 두 줄. 글자를 키우면 줄을 바꿉니다.
class _BannerText extends StatelessWidget {
  const _BannerText();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          SettingsStrings.deviceNotificationQuestion,
          textAlign: TextAlign.right,
          style: AppTypography.fieldLabel.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.peach,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          SettingsStrings.turnOnDeviceNotification,
          textAlign: TextAlign.right,
          style: AppTypography.topBarTitle.copyWith(
            color: AppColors.dialogSurface,
          ),
        ),
      ],
    );
  }
}
