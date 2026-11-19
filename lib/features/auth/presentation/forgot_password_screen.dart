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

  /// 제목 묶음과 입력창 사이 간격.
  static const _headerGap = 24.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(passwordResetProvider);
    final notifier = ref.read(passwordResetProvider.notifier);
    final errorMessage = form.errorMessage;

    Future<void> sendCode() async {
      final isSent = await notifier.requestVerificationCode();
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
        const SizedBox(height: _headerGap),
        AppTextField(
          label: AuthStrings.phoneLabel,
          hintText: AuthStrings.phoneHint,
          onChanged: notifier.updatePhoneNumber,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.stack),
          FormMessage(errorMessage, isError: true),
        ],
      ],
      actions: [
        AppButton.primary(
          label: AuthStrings.sendCode,
          onPressed: form.canRequestCode ? sendCode : null,
        ),
      ],
    );
  }
}
