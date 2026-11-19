import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_page_header.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/auth/application/sign_up_form.dart';
import 'package:chagok_mobile/features/auth/application/sign_up_notifier.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/form_message.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A01 · 회원가입 정보 입력 화면.
class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(signUpProvider);

    Future<void> requestCode() async {
      final isSent = await ref
          .read(signUpProvider.notifier)
          .requestVerificationCode();
      if (!isSent || !context.mounted) return;
      await context.push(AppRoute.signUpVerification);
    }

    return AuthFormLayout(
      appBar: const AppTopBar(title: AuthStrings.signUpBarTitle),
      body: [
        const AppPageHeader(
          title: AuthStrings.signUpTitle,
          description: AuthStrings.signUpDescription,
        ),
        const SizedBox(height: AppSpacing.block),
        _SignUpFields(form: form),
      ],
      actions: [
        AuthSwitchPrompt(
          message: AuthStrings.hasAccount,
          actionLabel: AuthStrings.goToLogin,
          onTap: () => context.go(AppRoute.login),
        ),
        AppButton.primary(
          label: AuthStrings.requestCode,
          onPressed: form.canRequestCode
              ? () => unawaited(requestCode())
              : null,
        ),
      ],
    );
  }
}

/// 전화번호·이름·생년월일·비밀번호 입력과 비밀번호 규칙·실패 안내.
class _SignUpFields extends ConsumerWidget {
  const _SignUpFields({required this.form});

  final SignUpForm form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SignUpNotifier notifier() => ref.read(signUpProvider.notifier);
    final failure = form.failure;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: AuthStrings.phoneLabel,
          hintText: AuthStrings.phoneHint,
          onChanged: (value) => notifier().updatePhoneNumber(value),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.stack),
        AppTextField(
          label: AuthStrings.nameLabel,
          hintText: AuthStrings.nameHint,
          onChanged: (value) => notifier().updateName(value),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.stack),
        AppTextField(
          label: AuthStrings.birthDateLabel,
          hintText: AuthStrings.birthDateHint,
          onChanged: (value) => notifier().updateBirthDate(value),
          keyboardType: TextInputType.datetime,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.stack),
        PasswordField(
          label: AuthStrings.passwordLabel,
          hintText: AuthStrings.passwordHint,
          onChanged: (value) => notifier().updatePassword(value),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.stack),
        FormMessage(
          text: AuthStrings.passwordRule,
          isError: form.password.isNotEmpty && !form.isPasswordValid,
        ),
        const SizedBox(height: AppSpacing.stack),
        PasswordField(
          label: AuthStrings.passwordConfirmLabel,
          hintText: AuthStrings.passwordConfirmHint,
          onChanged: (value) => notifier().updatePasswordConfirm(value),
          textInputAction: TextInputAction.done,
        ),
        if (form.hasPasswordMismatch) ...[
          const SizedBox(height: AppSpacing.stack),
          const FormMessage(text: AuthStrings.passwordMismatch, isError: true),
        ],
        if (failure != null) ...[
          const SizedBox(height: AppSpacing.stack),
          FormMessage(text: AuthStrings.failure(failure), isError: true),
        ],
      ],
    );
  }
}
