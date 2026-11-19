import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 라벨이 위에 붙은 둥근 입력창.
///
/// Figma `div.field` / `div.input`에 해당합니다.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.hintText,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    super.key,
  });

  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;

  /// 날짜·종류 선택처럼 직접 입력하지 않고 눌러서 고르는 경우 true.
  final bool readOnly;
  final VoidCallback? onTap;

  /// 입력창 오른쪽에 붙는 위젯. 예: 단위("원"), 펼침 아이콘
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: color),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTypography.fieldLabel),
        const SizedBox(height: AppSpacing.fieldLabelGap),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          style: AppTypography.fieldInput,
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.fieldFill,
            hintText: hintText,
            hintStyle: AppTypography.fieldInput.copyWith(
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.fieldPaddingHorizontal,
              vertical: AppSpacing.fieldPaddingVertical,
            ),
            suffixIcon: suffix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(
                      right: AppSpacing.fieldPaddingHorizontal,
                    ),
                    child: suffix,
                  ),
            suffixIconConstraints: const BoxConstraints(),
            border: border(AppColors.fieldBorder),
            enabledBorder: border(AppColors.fieldBorder),
            focusedBorder: border(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
