import 'dart:async';

import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_banner.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_card.dart';
import 'package:chagok_mobile/core/widgets/app_select_row.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/chat/application/chat_attach_notifier.dart';
import 'package:chagok_mobile/features/chat/application/chat_attach_state.dart';
import 'package:chagok_mobile/features/chat/data/chat_document.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:chagok_mobile/features/chat/presentation/widgets/chat_load_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// H02 · 보관함 서류를 골라 대화에 연결하는 화면.
class ChatAttachScreen extends ConsumerWidget {
  const ChatAttachScreen({required this.threadId, super.key});

  /// 서류를 연결할 대화 id.
  final String threadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatAttachProvider(threadId);
    final value = ref.watch(provider);

    return Scaffold(
      appBar: const AppTopBar(title: AppTopBar.logoText),
      body: value.when(
        data: (state) => _ChatAttachBody(
          state: state,
          onSelect: (documentId) =>
              ref.read(provider.notifier).select(documentId),
          onAttach: () => ref.read(provider.notifier).attach(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: ChatLoadError(
              message: ChatStrings.documentsLoadFailed,
              onRetry: () => ref.invalidate(provider),
            ),
          ),
        ),
      ),
    );
  }
}

/// 서류 고르기 안내와 아래 버튼 묶음.
class _ChatAttachBody extends StatelessWidget {
  const _ChatAttachBody({
    required this.state,
    required this.onSelect,
    required this.onAttach,
  });

  final ChatAttachState state;
  final ValueChanged<String> onSelect;

  /// 연결했으면 true를 돌려줍니다.
  final Future<bool> Function() onAttach;

  Future<void> _pickDocument(BuildContext context) async {
    final documentId = await showModalBottomSheet<String>(
      context: context,
      // 이 화면은 채팅 탭 안에 있어, 탭 Navigator에 띄우면 하단 탭 바에 가려집니다.
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.dialogSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.medium),
        ),
      ),
      builder: (context) => _DocumentPickerSheet(
        documents: state.documents,
        selectedId: state.selectedId,
      ),
    );
    if (documentId != null) onSelect(documentId);
  }

  Future<void> _attach(BuildContext context) async {
    final isAttached = await onAttach();
    if (isAttached && context.mounted) await Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final selected = state.selected;

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.pageTop,
                AppSpacing.screenHorizontal,
                AppSpacing.xl,
              ),
              children: [
                const Text(
                  ChatStrings.attachTitle,
                  style: AppTypography.pageTitle,
                ),
                const SizedBox(height: AppSpacing.block),
                const Text(
                  ChatStrings.attachDescription,
                  style: AppTypography.pageDescription,
                ),
                const SizedBox(height: AppSpacing.block),
                _PickFromBoxCard(
                  onTap: state.isSaving
                      ? null
                      : () => unawaited(_pickDocument(context)),
                ),
                if (selected != null) ...[
                  const SizedBox(height: AppSpacing.block),
                  AppBanner(
                    child: Text(ChatStrings.selected(selected.fileName)),
                  ),
                ],
                const SizedBox(height: AppSpacing.block),
                const Text(
                  ChatStrings.externalFileHelp,
                  style: AppTypography.pageDescription,
                ),
              ],
            ),
          ),
          _AttachActions(
            hasFailed: state.hasAttachFailed,
            onAttach: state.canAttach
                ? () => unawaited(_attach(context))
                : null,
            onCancel: () => unawaited(Navigator.maybePop(context)),
          ),
        ],
      ),
    );
  }
}

/// "내 보관함에서 선택 ›" 카드.
class _PickFromBoxCard extends StatelessWidget {
  const _PickFromBoxCard({required this.onTap});

  /// null이면 누를 수 없습니다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard.green(
      onTap: onTap,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              ChatStrings.pickFromBox,
              style: AppTypography.cardTitle,
            ),
          ),
          SizedBox(height: AppSpacing.cardTitleGap),
          Text(
            ChatStrings.pickFromBoxDescription,
            style: AppTypography.pageDescription,
          ),
        ],
      ),
    );
  }
}

/// 보관함 서류를 고르는 아래 시트. 고른 서류 id를 돌려주며 닫힙니다.
///
/// 보관한 서류가 없으면 빈 시트 대신 서류를 먼저 올리라는 안내를 보여 줍니다.
class _DocumentPickerSheet extends StatelessWidget {
  const _DocumentPickerSheet({
    required this.documents,
    required this.selectedId,
  });

  final List<ChatDocument> documents;
  final String? selectedId;

  /// 서류가 많아도 화면을 다 덮지 않도록 둔 화면 높이 대비 최대 비율.
  static const _maxHeightFactor = 0.6;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      // 시트는 내용 너비만큼만 펼쳐지므로, 짧은 안내도 화면 너비를 채우게 합니다.
      return const SizedBox(
        width: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Text(
              ChatStrings.noDocumentsInBox,
              textAlign: TextAlign.center,
              style: AppTypography.pageDescription,
            ),
          ),
        ),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            for (final document in documents)
              AppSelectRow(
                label: document.fileName,
                isSelected: document.id == selectedId,
                onTap: () => Navigator.pop(context, document.id),
              ),
          ],
        ),
      ),
    );
  }
}

/// 실패 안내와 "이 서류로 대화하기" · "취소" 버튼.
class _AttachActions extends StatelessWidget {
  const _AttachActions({
    required this.hasFailed,
    required this.onAttach,
    required this.onCancel,
  });

  final bool hasFailed;

  /// null이면 추가 버튼을 누를 수 없습니다.
  final VoidCallback? onAttach;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.block,
        AppSpacing.screenHorizontal,
        AppSpacing.actionsBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasFailed) ...[
            Text(
              ChatStrings.attachFailed,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: AppSpacing.buttonGap),
          ],
          AppButton.primary(label: ChatStrings.attach, onPressed: onAttach),
          const SizedBox(height: AppSpacing.buttonGap),
          AppButton.secondary(label: ChatStrings.cancel, onPressed: onCancel),
        ],
      ),
    );
  }
}
