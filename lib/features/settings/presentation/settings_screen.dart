import 'dart:async';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileHeader = ref
        .watch(userProfileProvider)
        .when(
          data: (profile) => ProfileHeader(profile: profile),
          loading: () => const ProfileHeader(profile: null),
          error: (error, stackTrace) => const ProfileHeader(
            profile: null,
            errorMessage: SettingsStrings.profileLoadFailed,
          ),
        );

    return SettingsScaffold(
      appBar: const AppTopBar(
        title: SettingsStrings.brand,
        showBackButton: false,
      ),
      body: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.sm,
            AppSpacing.screenHorizontal,
            AppSpacing.md,
          ),
          child: Text(
            SettingsStrings.title,
            style: AppTypography.boldPageTitle,
          ),
        ),
        profileHeader,
        const AppSectionBand(),
        const _AppSettingsSection(),
        const AppSectionBand(),
        const _InfoSection(),
        const AppSectionBand(),
        const _AccountSection(),
      ],
    );
  }
}

/// "앱 설정" 구역. 글자 크기와 알림 설정의 현재 값을 보여 줍니다.
class _AppSettingsSection extends ConsumerWidget {
  const _AppSettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (textSize, notifications) = ref
        .watch(settingsProvider)
        .when(
          data: (settings) => (
            SettingsStrings.textSizeLabel(settings.textSize),
            settings.hasAnyNotificationOn
                ? SettingsStrings.notificationsOn
                : SettingsStrings.notificationsOff,
          ),
          loading: () => (null, null),
          error: (error, stackTrace) => (
            SettingsStrings.valueUnavailable,
            SettingsStrings.valueUnavailable,
          ),
        );

    return Column(
      children: [
        const AppListSectionHeader(title: SettingsStrings.appSection),
        AppListRow(
          title: SettingsStrings.textSize,
          value: textSize,
          onTap: () => unawaited(context.push(AppRoute.textSizeSettings)),
        ),
        AppListRow(
          title: SettingsStrings.notifications,
          value: notifications,
          onTap: () => unawaited(context.push(AppRoute.notificationSettings)),
        ),
      ],
    );
  }
}

/// "정보" 구역. 앱 버전, 약관, 개인정보 처리방침.
class _InfoSection extends StatelessWidget {
  const _InfoSection();

  @override
  Widget build(BuildContext context) {
    void showComingSoon() {
      // TODO: 약관·방침 문서가 정해지면 화면으로 연결합니다.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(SettingsStrings.comingSoon)));
    }

    return Column(
      children: [
        const AppListSectionHeader(title: SettingsStrings.infoSection),
        const AppListRow(
          title: SettingsStrings.appVersion,
          value: SettingsStrings.appVersionValue,
          showChevron: false,
        ),
        AppListRow(title: SettingsStrings.terms, onTap: showComingSoon),
        AppListRow(title: SettingsStrings.privacyPolicy, onTap: showComingSoon),
      ],
    );
  }
}

/// "계정" 구역. 로그아웃과 회원 탈퇴. 둘 다 확인 창을 거칩니다.
class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void showMessage(String message) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    Future<void> confirmLogOut() async {
      final isConfirmed = await AppConfirmDialog.show(
        context,
        title: SettingsStrings.logOutConfirm,
      );
      if (!isConfirmed) return;
      final isDone = await ref.read(settingsProvider.notifier).logOut();
      if (!context.mounted) return;
      if (isDone) {
        context.go(AppRoute.home);
      } else {
        showMessage(SettingsStrings.logOutFailed);
      }
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
      final isDone = await ref.read(settingsProvider.notifier).deleteAccount();
      if (!context.mounted) return;
      if (isDone) {
        context.go(AppRoute.home);
      } else {
        showMessage(SettingsStrings.deleteAccountFailed);
      }
    }

    return Column(
      children: [
        const AppListSectionHeader(title: SettingsStrings.accountSection),
        AppListRow(
          title: SettingsStrings.logOut,
          onTap: () => unawaited(confirmLogOut()),
        ),
        AppListRow(
          title: SettingsStrings.deleteAccount,
          isDestructive: true,
          onTap: () => unawaited(confirmDeleteAccount()),
        ),
      ],
    );
  }
}
