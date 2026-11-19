import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_list_row.dart';
import 'package:chagok_mobile/core/widgets/app_list_section_header.dart';
import 'package:chagok_mobile/core/widgets/app_section_band.dart';
import 'package:chagok_mobile/core/widgets/app_toggle_row.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/settings/application/settings_notifier.dart';
import 'package:chagok_mobile/features/settings/presentation/settings_strings.dart';
import 'package:chagok_mobile/features/settings/presentation/widgets/device_notification_banner.dart';
import 'package:chagok_mobile/features/settings/presentation/widgets/settings_header.dart';
import 'package:chagok_mobile/features/settings/presentation/widgets/settings_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S03 · 납부일·마케팅 알림과 알림 시각을 정하는 화면.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsValue = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    void openDeviceSettings() {
      // TODO: 기기 설정 화면을 여는 플러그인을 정하면 연결합니다.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(SettingsStrings.comingSoon)));
    }

    Future<void> pickReminderTime(int minuteOfDay) async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: minuteOfDay ~/ 60,
          minute: minuteOfDay % 60,
        ),
      );
      if (picked == null) return;
      await notifier.setReminderTime(hour: picked.hour, minute: picked.minute);
    }

    return SettingsScaffold(
      appBar: const AppTopBar(title: SettingsStrings.brand),
      body: [
        const SettingsHeader(
          title: SettingsStrings.notificationTitle,
          description: SettingsStrings.notificationDescription,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            0,
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
          ),
          child: DeviceNotificationBanner(onTap: openDeviceSettings),
        ),
        const AppSectionBand(),
        const AppListSectionHeader(title: SettingsStrings.receiveSection),
        ...settingsValue.when(
          data: (settings) => [
            AppToggleRow(
              title: SettingsStrings.paymentReminder,
              subtitle: SettingsStrings.paymentReminderDescription,
              value: settings.isPaymentReminderOn,
              onChanged: (isOn) => notifier.setPaymentReminder(isOn: isOn),
            ),
            AppToggleRow(
              title: SettingsStrings.marketing,
              subtitle: SettingsStrings.marketingDescription,
              value: settings.isMarketingOn,
              onChanged: (isOn) => notifier.setMarketing(isOn: isOn),
            ),
            AppListRow(
              title: SettingsStrings.reminderTime,
              value: SettingsStrings.reminderTimeLabel(
                settings.reminderMinuteOfDay,
              ),
              onTap: () => pickReminderTime(settings.reminderMinuteOfDay),
            ),
          ],
          loading: () => const [
            Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
          error: (error, stackTrace) => [
            AppListRow(
              title: SettingsStrings.loadFailed,
              value: SettingsStrings.retry,
              onTap: () => ref.invalidate(settingsProvider),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.sm,
            AppSpacing.screenHorizontal,
            0,
          ),
          child: Text(
            SettingsStrings.notificationNote,
            style: AppTypography.caption,
          ),
        ),
      ],
      actions: [
        AppButton.primary(
          label: SettingsStrings.openDeviceSettings,
          onPressed: openDeviceSettings,
        ),
        AppButton.secondary(
          label: SettingsStrings.later,
          onPressed: () => Navigator.maybePop(context),
        ),
      ],
    );
  }
}
