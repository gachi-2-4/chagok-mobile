import 'dart:async';

import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/features/archive/application/new_box_notifier.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/box_style.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/sheet_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 새 박스 만들기 시트(05)를 아래에서 띄웁니다. 만들었으면 true를 돌려줍니다.
Future<bool> showNewBoxSheet(BuildContext context) async {
  final isCreated = await showModalBottomSheet<bool>(
    context: context,
    // 디자인처럼 하단 탭 바까지 덮도록 탭 바깥의 가장 바깥 Navigator에 띄웁니다.
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
    ),
    builder: (context) => const NewBoxSheet(),
  );
  return isCreated ?? false;
}

/// 박스 이름을 적고 색·아이콘을 골라 새 보관함을 만드는 시트.
class NewBoxSheet extends ConsumerWidget {
  const NewBoxSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(newBoxProvider);

    NewBoxNotifier notifier() => ref.read(newBoxProvider.notifier);

    return Padding(
      // 키보드가 올라오면 시트도 그만큼 올립니다.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.sheetHandleTop,
          AppSpacing.screenHorizontal,
          AppSpacing.actionsBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: SheetHandle()),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              ArchiveStrings.newBoxTitle,
              style: AppTypography.sheetTitle,
            ),
            const SizedBox(height: AppSpacing.block),
            AppTextField(
              hintText: ArchiveStrings.boxNameHint,
              onChanged: (value) => notifier().updateName(value),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.block),
            const Text(
              ArchiveStrings.colorLabel,
              style: AppTypography.fieldLabel,
            ),
            const SizedBox(height: AppSpacing.fieldLabelGap),
            _ColorRow(
              selected: form.color,
              onSelect: (color) => notifier().selectColor(color),
            ),
            const SizedBox(height: AppSpacing.block),
            const Text(
              ArchiveStrings.iconLabel,
              style: AppTypography.fieldLabel,
            ),
            const SizedBox(height: AppSpacing.fieldLabelGap),
            _IconGrid(
              selected: form.icon,
              onSelect: (icon) => notifier().selectIcon(icon),
            ),
            const SizedBox(height: AppSpacing.md),
            const _SheetActions(),
          ],
        ),
      ),
    );
  }
}

/// 실패 안내와 취소·만들기 버튼. 만들었으면 시트를 닫습니다.
class _SheetActions extends ConsumerWidget {
  const _SheetActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(newBoxProvider);

    Future<void> submit() async {
      final isCreated = await ref.read(newBoxProvider.notifier).submit();
      if (isCreated && context.mounted) Navigator.pop(context, true);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (form.hasSaveFailed)
          Text(
            ArchiveStrings.createFailed,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(color: AppColors.danger),
          ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: ArchiveStrings.cancel,
                onPressed: () => Navigator.pop(context, false),
              ),
            ),
            const SizedBox(width: AppSpacing.buttonGap),
            Expanded(
              flex: 2,
              child: AppButton.primary(
                label: ArchiveStrings.create,
                onPressed: form.canSubmit ? () => unawaited(submit()) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 고를 수 있는 상자 색을 한 줄로 늘어놓습니다.
class _ColorRow extends StatelessWidget {
  const _ColorRow({required this.selected, required this.onSelect});

  final BoxColor selected;
  final ValueChanged<BoxColor> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (index, color) in BoxColor.values.indexed) ...[
          if (index > 0) const SizedBox(width: AppSpacing.sm),
          _ColorOption(
            color: color,
            isSelected: color == selected,
            onTap: () => onSelect(color),
          ),
        ],
      ],
    );
  }
}

/// 상자 색 하나. 고르면 바깥에 테두리를 두릅니다.
class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final BoxColor color;
  final bool isSelected;
  final VoidCallback onTap;

  static const _size = 44.0;
  static const _ringWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: ArchiveStrings.colorName(color),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: _size,
          height: _size,
          padding: const EdgeInsets.all(AppSpacing.selectionRingGap),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? AppColors.chipSelectedText
                  : AppColors.transparent,
              width: _ringWidth,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: BoxStyle.bodyColor(color),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// 한 줄에 여섯 개씩 놓은 아이콘 칸.
class _IconGrid extends StatelessWidget {
  const _IconGrid({required this.selected, required this.onSelect});

  final BoxIcon selected;
  final ValueChanged<BoxIcon> onSelect;

  static const _columns = 6;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: _columns,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final icon in BoxIcon.values)
          _IconOption(
            icon: icon,
            isSelected: icon == selected,
            onTap: () => onSelect(icon),
          ),
      ],
    );
  }
}

/// 종류 아이콘 하나. 고르면 연두색 바탕으로 바꿉니다.
class _IconOption extends StatelessWidget {
  const _IconOption({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final BoxIcon icon;
  final bool isSelected;
  final VoidCallback onTap;

  static const _iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: ArchiveStrings.iconName(icon),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.boxBodyGreen : AppColors.softFill,
            borderRadius: BorderRadius.circular(AppRadius.iconTile),
          ),
          child: Center(
            child: Icon(
              BoxStyle.icon(icon),
              size: _iconSize,
              color: isSelected
                  ? AppColors.chipSelectedText
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
