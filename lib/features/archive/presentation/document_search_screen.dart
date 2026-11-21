import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/extensions/scroll_end_inset.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/archive/application/document_search_notifier.dart';
import 'package:chagok_mobile/features/archive/application/document_search_query_notifier.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/document_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 모든 보관함에서 이름이나 내용이 맞는 서류를 찾아 보여 주는 화면.
///
/// 보관함 목록의 "서류 이름·내용 검색"을 누르면 열립니다. 적는 대로 다시 찾습니다.
class DocumentSearchScreen extends ConsumerWidget {
  const DocumentSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AppTopBar.plain(title: ArchiveStrings.searchTitle),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.pageTop,
          AppSpacing.screenHorizontal,
          context.scrollEndInset(),
        ),
        children: [
          AppTextField(
            hintText: ArchiveStrings.search,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (query) =>
                ref.read(documentSearchQueryProvider.notifier).update(query),
            suffix: const Icon(
              Icons.search_rounded,
              size: AppIcons.mediumSize,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGapLarge),
          const _SearchResults(),
        ],
      ),
    );
  }
}

/// 검색어에 맞는 서류. 검색어가 없으면 안내를, 맞는 서류가 없으면 그 사실을 보여 줍니다.
class _SearchResults extends ConsumerWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(documentSearchQueryProvider).trim();
    if (query.isEmpty) {
      return const Text(
        ArchiveStrings.searchGuide,
        textAlign: TextAlign.center,
        style: AppTypography.listSubtitle,
      );
    }

    return ref
        .watch(documentSearchProvider)
        .when(
          data: (items) => items.isEmpty
              ? Text(
                  ArchiveStrings.noSearchResult(query),
                  textAlign: TextAlign.center,
                  style: AppTypography.listSubtitle,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ArchiveStrings.documentCount(items.length),
                      style: AppTypography.listSubtitle,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DocumentGrid(items: items),
                  ],
                ),
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Column(
            children: [
              const Text(
                ArchiveStrings.searchFailed,
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton.secondary(
                label: ArchiveStrings.retry,
                onPressed: () => ref.invalidate(documentSearchProvider),
              ),
            ],
          ),
        );
  }
}
