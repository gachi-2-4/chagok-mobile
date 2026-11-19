import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:flutter/material.dart';

/// 대화 화면 아래 입력줄. "서류 추가" 버튼, 질문 입력칸, 보내기(↑) 버튼.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.onSend,
    required this.onAddDocument,
    this.isEnabled = true,
    super.key,
  });

  /// 앞뒤 공백을 지운 질문을 받습니다. 빈 글은 보내지 않습니다.
  final ValueChanged<String> onSend;

  /// "서류 추가"를 눌렀을 때 동작.
  final VoidCallback onAddDocument;

  /// false면 답을 기다리는 동안 보내기를 막습니다.
  final bool isEnabled;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.isEnabled) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(AppRadius.field),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: widget.onAddDocument,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              textStyle: AppTypography.fieldInput,
              padding: const EdgeInsets.only(
                left: AppSpacing.fieldPaddingHorizontal,
                right: AppSpacing.sm,
              ),
              minimumSize: const Size(0, kMinInteractiveDimension),
            ),
            child: const Text(ChatStrings.addDocument),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _send(),
              textInputAction: TextInputAction.send,
              style: AppTypography.fieldInput,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: ChatStrings.inputHint,
                hintStyle: AppTypography.fieldInput.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: widget.isEnabled ? _send : null,
            tooltip: ChatStrings.send,
            icon: const Icon(
              Icons.arrow_upward_rounded,
              size: AppIcons.smallSize,
            ),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
