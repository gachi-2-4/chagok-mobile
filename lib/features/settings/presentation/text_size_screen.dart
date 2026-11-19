import 'dart:async';

import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
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

  static const _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.dialogSurface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: AppColors.chipBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        // 아직 저장하지 않은 크기를 보여 주므로 앱 전체 배율 대신 고른 배율만 씁니다.
        child: MediaQuery.withClampedTextScaling(
          minScaleFactor: textSize.scale,
          maxScaleFactor: textSize.scale,
          child: const Text(
            SettingsStrings.previewText,
            style: AppTypography.textSizePreview,
          ),
        ),
      ),
    );
  }
}
