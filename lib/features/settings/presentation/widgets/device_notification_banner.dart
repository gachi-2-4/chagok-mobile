import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/settings/presentation/settings_strings.dart';
import 'package:flutter/material.dart';

/// "알림이 오지 않는다면? 기기 알림 켜기" 주황 배너.
///
/// Figma S03 `div.banner`에 해당합니다. 꺼진 종 그림은 아이콘으로 대신합니다.
class DeviceNotificationBanner extends StatelessWidget {
  const DeviceNotificationBanner({required this.onTap, super.key});

  final VoidCallback onTap;

  static const _height = 92.0;
  static const _radius = 6.0;
  static const _illustrationSize = 72.0;
  static const _iconSize = 44.0;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(_radius);

    return Material(
      color: AppColors.primary,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: AppSpacing.xl),
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
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      SettingsStrings.deviceNotificationQuestion,
                      style: AppTypography.fieldLabel.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.peach,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      SettingsStrings.turnOnDeviceNotification,
                      style: AppTypography.topBarTitle.copyWith(
                        color: AppColors.dialogSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
