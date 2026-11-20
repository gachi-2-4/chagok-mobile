import 'dart:async';

import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/utils/app_text_scaler.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_list_section_header.dart';
import 'package:chagok_mobile/core/widgets/app_section_band.dart';
import 'package:chagok_mobile/core/widgets/app_select_row.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/settings/application/text_size_notifier.dart';
import 'package:chagok_mobile/features/settings/data/text_size.dart';
import 'package:chagok_mobile/features/settings/presentation/settings_strings.dart';
import 'package:chagok_mobile/features/settings/presentation/widgets/settings_header.dart';
import 'package:chagok_mobile/features/settings/presentation/widgets/settings_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S02 · 글자 크기를 골라 미리 보고 저장하는 화면.
class TextSizeScreen extends ConsumerWidget {
  const TextSizeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(textSizeDraftProvider);

    Future<void> save() async {
      final isSaved = await ref.read(textSizeDraftProvider.notifier).save();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSaved
                ? SettingsStrings.textSizeSaved
                : SettingsStrings.textSizeSaveFailed,
          ),
        ),
      );
      if (isSaved) await Navigator.maybePop(context);
    }

    return SettingsScaffold(
      appBar: const AppTopBar(title: SettingsStrings.textSize),
      body: [
        const SettingsHeader(
          title: SettingsStrings.textSizeTitle,
          description: SettingsStrings.textSizeDescription,
        ),
        const AppSectionBand(),
        const AppListSectionHeader(title: SettingsStrings.textSize),
        _TextSizeOptions(selected: draft),
        const AppSectionBand(),
        const AppListSectionHeader(title: SettingsStrings.previewSection),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.xxs,
            AppSpacing.screenHorizontal,
            0,
          ),
          child: _TextSizePreview(textSize: draft),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.md,
            AppSpacing.screenHorizontal,
            0,
          ),
          child: Text(
            SettingsStrings.textSizeNote,
            style: AppTypography.listSubtitle,
          ),
        ),
      ],
      actions: [
        AppButton.primary(
          label: SettingsStrings.saveTextSize,
          onPressed: () => unawaited(save()),
        ),
      ],
    );
  }
}

/// 고를 수 있는 글자 크기 목록. 누르면 미리 보기 크기만 바꿉니다.
class _TextSizeOptions extends ConsumerWidget {
  const _TextSizeOptions({required this.selected});

  final TextSize selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        for (final size in TextSize.values)
          AppSelectRow(
            label: SettingsStrings.textSizeLabel(size),
            isSelected: size == selected,
            onTap: () => ref.read(textSizeDraftProvider.notifier).select(size),
          ),
      ],
    );
  }
}

/// 고른 글자 크기로 예시 문장을 보여 주는 카드.
class _TextSizePreview extends StatelessWidget {
  const _TextSizePreview({required this.textSize});

  final TextSize textSize;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final deviceScaler = scaler is AppTextScaler ? scaler.base : scaler;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.dialogSurface,
        borderRadius: BorderRadius.circular(AppRadius.paper),
        border: Border.all(color: AppColors.chipBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        // 앱 전체에는 기기 배율에 저장한 배율이 곱해져 있습니다. 미리 보기는
        // 저장한 배율을 빼고 기기 배율에 고른 배율만 곱해, 저장 뒤 크기와 맞춥니다.
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: AppTextScaler(deviceScaler, textSize.scale)),
          child: const Text(
            SettingsStrings.previewText,
            style: AppTypography.textSizePreview,
          ),
        ),
      ),
    );
  }
}
