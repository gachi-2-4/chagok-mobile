import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_page_header.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/auth/application/password_reset_notifier.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/form_message.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// L03 · 인증을 마친 뒤 새 비밀번호를 정하는 화면.
class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  /// 제목 묶음과 입력창 사이 간격.
  static const _headerGap = 24.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(passwordResetProvider);
    final notifier = ref.read(passwordResetProvider.notifier);
    final errorMessage = form.errorMessage;

    Future<void> reset() async {
      final isReset = await notifier.reset();
      if (!isReset || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AuthStrings.passwordChanged)),
      );
      ref.invalidate(passwordResetProvider);
      context.go(AppRoute.login);
    }

    return AuthFormLayout(
      appBar: const AppTopBar(title: ''),
      body: [
        const AppPageHeader(
          title: AuthStrings.resetPasswordTitle,
          description: AuthStrings.resetPasswordDescription,
        ),
        const SizedBox(height: _headerGap),
        PasswordField(
          label: AuthStrings.newPasswordLabel,
          hintText: AuthStrings.passwordHint,
          onChanged: notifier.updateNewPassword,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.stack),
        FormMessage(
          AuthStrings.passwordRule,
          isError: form.newPassword.isNotEmpty && !form.isNewPasswordValid,
        ),
        const SizedBox(height: AppSpacing.stack),
        PasswordField(
          label: AuthStrings.newPasswordConfirmLabel,
          hintText: AuthStrings.passwordConfirmHint,
          onChanged: notifier.updateNewPasswordConfirm,
          textInputAction: TextInputAction.done,
        ),
        if (form.hasPasswordMismatch) ...[
          const SizedBox(height: AppSpacing.stack),
          const FormMessage(AuthStrings.passwordMismatch, isError: true),
        ],
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.stack),
          FormMessage(errorMessage, isError: true),
        ],
      ],
      actions: [
        AppButton.primary(
          label: AuthStrings.changePassword,
          onPressed: form.canReset ? reset : null,
        ),
      ],
    );
  }
}
