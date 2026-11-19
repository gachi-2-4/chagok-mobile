import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:flutter/material.dart';

/// 입력 내용을 가리고, 오른쪽 눈 버튼으로 보였다 숨길 수 있는 비밀번호 입력창.
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.label,
    required this.onChanged,
    this.hintText,
    this.textInputAction,
    super.key,
  });

  final String label;
  final String? hintText;
  final ValueChanged<String> onChanged;
  final TextInputAction? textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

// 보이기/숨기기는 이 입력창 안에서만 쓰는 화면 상태라 Notifier에 두지 않습니다.
class _PasswordFieldState extends State<PasswordField> {
  var _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hintText: widget.hintText,
      onChanged: widget.onChanged,
      obscureText: _isObscured,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      suffix: Semantics(
        button: true,
        label: _isObscured
            ? AuthStrings.showPassword
            : AuthStrings.hidePassword,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _isObscured = !_isObscured),
          child: Icon(
            _isObscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
