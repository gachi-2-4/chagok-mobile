import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_banner.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_card.dart';
import 'package:chagok_mobile/core/widgets/app_select_row.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/chat/application/chat_attach_notifier.dart';
import 'package:chagok_mobile/features/chat/application/chat_attach_state.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// H02 · 보관함 서류를 골라 대화에 연결하는 화면.
class ChatAttachScreen extends ConsumerWidget {
  const ChatAttachScreen({required this.threadId, super.key});

  final String threadId;

  static const _top = 11.0;
  static const _gap = 18.0;
  static const _actionsTop = 18.0;
  static const _actionsBottom = 24.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatAttachProvider(threadId);
    final state = ref.watch(provider).value;
    final notifier = ref.read(provider.notifier);
    final selected = state?.selected;

    Future<void> pickDocument(ChatAttachState state) async {
      final documentId = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              for (final document in state.documents)
                AppSelectRow(
                  label: document.fileName,
                  isSelected: document.id == state.selectedId,
                  onTap: () => Navigator.pop(context, document.id),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      );
      if (documentId != null) notifier.select(documentId);
    }

    Future<void> attach() async {
      final isAttached = await notifier.attach();
      if (isAttached && context.mounted) Navigator.maybePop(context);
    }

    return Scaffold(
      appBar: const AppTopBar(title: AppTopBar.logoText),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  _top,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xl,
                ),
                children: [
                  const Text(
                    ChatStrings.attachTitle,
                    style: AppTypography.pageTitle,
                  ),
                  const SizedBox(height: _gap),
                  const Text(
                    ChatStrings.attachDescription,
                    style: AppTypography.pageDescription,
                  ),
                  const SizedBox(height: _gap),
                  AppCard.green(
                    onTap: state == null ? null : () => pickDocument(state),
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
                        SizedBox(height: 10),
                        Text(
                          ChatStrings.pickFromBoxDescription,
                          style: AppTypography.pageDescription,
                        ),
                      ],
                    ),
                  ),
                  if (selected != null) ...[
                    const SizedBox(height: _gap),
                    AppBanner(
                      child: Text(ChatStrings.selected(selected.fileName)),
                    ),
                  ],
                  const SizedBox(height: _gap),
                  const Text(
                    ChatStrings.externalFileHelp,
                    style: AppTypography.pageDescription,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                _actionsTop,
                AppSpacing.screenHorizontal,
                _actionsBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state?.hasAttachFailed ?? false) ...[
                    Text(
                      ChatStrings.attachFailed,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.buttonGap),
                  ],
                  AppButton.primary(
                    label: ChatStrings.attach,
                    onPressed: (state?.canAttach ?? false) ? attach : null,
                  ),
                  const SizedBox(height: AppSpacing.buttonGap),
                  AppButton.secondary(
                    label: ChatStrings.cancel,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
