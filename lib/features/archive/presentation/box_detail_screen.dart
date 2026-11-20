import 'dart:async';

import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/constants/core_strings.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/features/archive/application/box_detail.dart';
import 'package:chagok_mobile/features/archive/application/box_detail_notifier.dart';
import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/box_not_found_exception.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/box_style.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/document_grid.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/upload_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 06 · 보관함 하나를 열어 담긴 서류를 두 줄씩 보여 주는 화면.
class BoxDetailScreen extends ConsumerWidget {
  const BoxDetailScreen({required this.boxId, super.key});

  /// 연 보관함 id.
  final String boxId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: const UploadButton(),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.pageTop,
            AppSpacing.screenHorizontal,
            AppSpacing.floatingButtonClearance,
          ),
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: _CircleBackButton(),
            ),
            const SizedBox(height: AppSpacing.block),
            ref
                .watch(boxDetailProvider(boxId))
                .when(
                  data: (detail) => _BoxDetailContent(detail: detail),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => Column(
                    children: [
                      Text(
                        error is BoxNotFoundException
                            ? ArchiveStrings.boxNotFound
                            : ArchiveStrings.loadFailed,
                        style: AppTypography.body,
                      ),
                      if (error is! BoxNotFoundException) ...[
                        const SizedBox(height: AppSpacing.lg),
                        AppButton.secondary(
                          label: ArchiveStrings.retry,
                          onPressed: () =>
                              ref.invalidate(boxDetailProvider(boxId)),
                        ),
                      ],
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// 보관함 머리와 서류 목록.
class _BoxDetailContent extends StatelessWidget {
  const _BoxDetailContent({required this.detail});

  final BoxDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BoxHeader(box: detail.box),
        const SizedBox(height: AppSpacing.sectionGapLarge),
        if (detail.documents.isEmpty)
          const Text(ArchiveStrings.emptyBox, style: AppTypography.listSubtitle)
        else
          DocumentGrid(items: detail.documents),
      ],
    );
  }
}

/// 종류 아이콘 칸과 보관함 이름·서류 수.
class _BoxHeader extends StatelessWidget {
  const _BoxHeader({required this.box});

  final ArchiveBox box;

  static const _iconTileSize = 48.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: _iconTileSize,
          height: _iconTileSize,
          decoration: BoxDecoration(
            color: BoxStyle.bodyColor(box.color),
            borderRadius: BorderRadius.circular(AppRadius.iconTile),
          ),
          child: Icon(
            BoxStyle.icon(box.icon),
            size: _iconSize,
            color: AppColors.boxIcon,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(box.name, style: AppTypography.pageTitle),
              Text(
                ArchiveStrings.documentCount(box.documentCount),
                style: AppTypography.listSubtitle.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 동그란 바탕 위의 뒤로 가기(‹) 버튼.
class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton();

  static const _size = 40.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: CoreStrings.back,
      child: Material(
        color: AppColors.softFill,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => unawaited(Navigator.maybePop(context)),
          child: SizedBox.square(
            dimension: _size,
            child: Center(
              child: SvgPicture.asset(
                AppIcons.back,
                width: _iconSize,
                height: _iconSize,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
