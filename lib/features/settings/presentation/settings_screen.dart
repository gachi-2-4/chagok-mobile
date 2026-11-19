import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_confirm_dialog.dart';
import 'package:chagok_mobile/core/widgets/app_list_row.dart';
import 'package:chagok_mobile/core/widgets/app_list_section_header.dart';
import 'package:chagok_mobile/core/widgets/app_section_band.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/settings/application/settings_notifier.dart';
import 'package:chagok_mobile/features/settings/presentation/settings_strings.dart';
import 'package:chagok_mobile/features/settings/presentation/widgets/profile_header.dart';
import 'package:chagok_mobile/features/settings/presentation/widgets/settings_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S01 · 설정 첫 화면. 앱 설정, 정보, 계정 메뉴를 모아 보여 줍니다.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Figma `title` 여백.
  static const _titleTop = 8.0;
  static const _titleBottom = 12.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final profile = ref.watch(userProfileProvider).value;

    void showComingSoon() {
      // TODO: 약관·방침 문서가 정해지면 화면으로 연결합니다.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(SettingsStrings.comingSoon)));
    }

    Future<void> confirmLogOut() async {
      final isConfirmed = await AppConfirmDialog.show(
        context,
        title: SettingsStrings.logOutConfirm,
      );
      if (!isConfirmed) return;
      await ref.read(settingsProvider.notifier).logOut();
      if (context.mounted) context.go(AppRoute.home);
    }

    Future<void> confirmDeleteAccount() async {
      final isConfirmed = await AppConfirmDialog.show(
        context,
        title: SettingsStrings.deleteAccountConfirm,
        description: SettingsStrings.deleteAccountDescription,
        confirmLabel: SettingsStrings.deleteAccountAction,
        isDestructive: true,
      );
      if (!isConfirmed) return;
      await ref.read(settingsProvider.notifier).deleteAccount();
      if (context.mounted) context.go(AppRoute.home);
    }

    return SettingsScaffold(
      appBar: const AppTopBar(
        title: SettingsStrings.brand,
        showBackButton: false,
      ),
      body: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            _titleTop,
            AppSpacing.screenHorizontal,
            _titleBottom,
          ),
          child: Text(
            SettingsStrings.title,
            style: AppTypography.pageTitle.copyWith(
              fontSize: 26,
              height: 36.4 / 26,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        ProfileHeader(profile: profile),
        const AppSectionBand(),
        const AppListSectionHeader(title: SettingsStrings.appSection),
        AppListRow(
          title: SettingsStrings.textSize,
          value: settings == null
              ? null
              : SettingsStrings.textSizeLabel(settings.textSize),
          onTap: () => context.push(AppRoute.textSizeSettings),
        ),
        AppListRow(
          title: SettingsStrings.notifications,
          value: switch (settings?.hasAnyNotificationOn) {
            true => SettingsStrings.notificationsOn,
            false => SettingsStrings.notificationsOff,
            null => null,
          },
          onTap: () => context.push(AppRoute.notificationSettings),
        ),
        const AppSectionBand(),
        const AppListSectionHeader(title: SettingsStrings.infoSection),
        const AppListRow(
          title: SettingsStrings.appVersion,
          value: SettingsStrings.appVersionValue,
          showChevron: false,
        ),
        AppListRow(title: SettingsStrings.terms, onTap: showComingSoon),
        AppListRow(title: SettingsStrings.privacyPolicy, onTap: showComingSoon),
        const AppSectionBand(),
        const AppListSectionHeader(title: SettingsStrings.accountSection),
        AppListRow(title: SettingsStrings.logOut, onTap: confirmLogOut),
        AppListRow(
          title: SettingsStrings.deleteAccount,
          isDestructive: true,
          onTap: confirmDeleteAccount,
        ),
      ],
    );
  }
}
