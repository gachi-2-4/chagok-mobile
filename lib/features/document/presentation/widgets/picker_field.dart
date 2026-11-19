import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

/// 직접 입력하지 않고 눌러서 고르는 입력창. 예: 문서 종류, 납부일, 날짜
///
/// [value]가 바뀌면 입력창 글자도 따라 바뀝니다.
class PickerField extends StatefulWidget {
  const PickerField({
    required this.label,
    required this.value,
    required this.onTap,
    this.hintText,
    this.icon = Icons.keyboard_arrow_down_rounded,
    super.key,
  });

  final String label;
  final String value;
  final String? hintText;
  final VoidCallback onTap;

  /// 오른쪽 아이콘. 기본은 펼침(⌄)입니다.
  final IconData icon;

  @override
  State<PickerField> createState() => _PickerFieldState();
}

class _PickerFieldState extends State<PickerField> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(PickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hintText: widget.hintText,
      controller: _controller,
      readOnly: true,
      onTap: widget.onTap,
      suffix: Icon(widget.icon, size: 20, color: AppColors.textPrimary),
    );
  }
}
