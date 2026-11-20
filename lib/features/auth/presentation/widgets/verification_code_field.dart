import 'dart:math';

import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 숫자 한 자리씩 칸에 나눠 보여 주는 인증번호 입력창.
///
/// Figma `div.code`에 해당합니다. 칸 위에 보이지 않는 입력창 하나를 겹쳐
/// 두어, 붙여넣기와 문자 자동 채우기가 그대로 동작합니다.
class VerificationCodeField extends StatefulWidget {
  const VerificationCodeField({
    required this.length,
    required this.code,
    required this.onChanged,
    required this.semanticLabel,
    this.hasError = false,
    super.key,
  });

  /// 칸 개수.
  final int length;

  /// 지금까지 입력한 숫자.
  final String code;

  /// 입력값이 바뀔 때 숫자만 남긴 값을 받습니다.
  final ValueChanged<String> onChanged;

  /// 화면 읽기 프로그램이 읽어 줄 입력창 이름. 예: "인증번호 6자리"
  final String semanticLabel;

  /// 틀린 번호를 넣었을 때 칸 테두리를 경고 색으로 바꿉니다.
  final bool hasError;

  @override
  State<VerificationCodeField> createState() => _VerificationCodeFieldState();
}

class _VerificationCodeFieldState extends State<VerificationCodeField> {
  /// 칸의 기본 너비. 폭이 모자라면 칸 사이를 [AppSpacing.xs]만 남기고 줄입니다.
  static const _cellWidth = 46.0;
  static const _cellHeight = 56.0;

  late final _controller = TextEditingController(text: widget.code);
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(VerificationCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // "다시 받기"처럼 바깥에서 값을 비우면 입력창도 맞춥니다.
    if (widget.code != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.code,
        selection: TextSelection.collapsed(offset: widget.code.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final code = widget.code;
    final activeIndex = _focusNode.hasFocus ? code.length : -1;

    return SizedBox(
      height: _cellHeight,
      child: Stack(
        children: [
          // 320pt처럼 좁은 화면에서는 칸을 줄여 넘치지 않게 합니다.
          LayoutBuilder(
            builder: (context, constraints) {
              final fitWidth =
                  (constraints.maxWidth - AppSpacing.xs * (widget.length - 1)) /
                  widget.length;
              final cellWidth = min(_cellWidth, fitWidth);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var index = 0; index < widget.length; index++)
                    _CodeCell(
                      width: cellWidth,
                      digit: index < code.length ? code[index] : '',
                      isActive: index == activeIndex,
                      hasError: widget.hasError,
                    ),
                ],
              );
            },
          ),
          Positioned.fill(
            child: Semantics(
              label: widget.semanticLabel,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                showCursor: false,
                style: const TextStyle(color: AppColors.transparent),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeCell extends StatelessWidget {
  const _CodeCell({
    required this.width,
    required this.digit,
    required this.isActive,
    required this.hasError,
  });

  final double width;
  final String digit;
  final bool isActive;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final borderColor = switch ((hasError, isActive)) {
      (true, _) => AppColors.danger,
      (false, true) => AppColors.primary,
      (false, false) => AppColors.chipBorder,
    };

    return Container(
      width: width,
      height: _VerificationCodeFieldState._cellHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.codeCell),
        border: Border.all(color: borderColor),
      ),
      child: Text(digit, style: AppTypography.verificationDigit),
    );
  }
}
