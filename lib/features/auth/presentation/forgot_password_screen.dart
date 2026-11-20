import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_page_header.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/auth/application/password_reset_notifier.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/form_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// L02 · 비밀번호를 잊었을 때 전화번호로 인증번호를 받는 화면.
class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(passwordResetProvider);
    final failure = form.failure;

    Future<void> sendCode() async {
      final isSent = await ref
          .read(passwordResetProvider.notifier)
          .requestVerificationCode();
      if (!isSent || !context.mounted) return;
      await context.push(AppRoute.passwordResetVerification);
    }

    return AuthFormLayout(
      appBar: const AppTopBar(title: ''),
      body: [
        const AppPageHeader(
          title: AuthStrings.forgotPasswordTitle,
          description: AuthStrings.forgotPasswordDescription,
        ),
        const SizedBox(height: AppSpacing.pageHeaderBottom),
        AppTextField(
          label: AuthStrings.phoneLabel,
          hintText: AuthStrings.phoneHint,
          onChanged: (value) =>
              ref.read(passwordResetProvider.notifier).updatePhoneNumber(value),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          // 요청하는 사이 번호를 바꾸면 보낸 번호와 입력이 달라지므로 잠급니다.
          readOnly: form.isSubmitting,
        ),
        if (failure != null) ...[
          const SizedBox(height: AppSpacing.stack),
          FormMessage(text: AuthStrings.failure(failure), isError: true),
        ],
      ],
      actions: [
        AppButton.primary(
          label: AuthStrings.sendCode,
          onPressed: form.canRequestCode ? () => unawaited(sendCode()) : null,
        ),
      ],
    );
  }
}
