import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_banner.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_page_header.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/auth/application/auth_validators.dart';
import 'package:chagok_mobile/features/auth/application/password_reset_notifier.dart';
import 'package:chagok_mobile/features/auth/application/phone_verification_notifier.dart';
import 'package:chagok_mobile/features/auth/application/phone_verification_state.dart';
import 'package:chagok_mobile/features/auth/application/sign_up_notifier.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/form_message.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/verification_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 전화번호 인증을 어떤 흐름에서 하는지.
enum VerificationPurpose {
  /// 회원가입(A02). 인증하면 약관 동의로 갑니다.
  signUp,

  /// 비밀번호 찾기(L04). 인증하면 새 비밀번호 만들기로 갑니다.
  passwordReset,
}

/// A02·L04 · 문자로 받은 인증번호를 입력하는 화면.
class PhoneVerificationScreen extends ConsumerWidget {
  const PhoneVerificationScreen({required this.purpose, super.key});

  final VerificationPurpose purpose;

  /// 제목 묶음, 입력 묶음, 안내 사이 간격.
  static const _sectionGap = 28.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneNumber = switch (purpose) {
      VerificationPurpose.signUp => ref.watch(
        signUpProvider.select((form) => form.normalizedPhoneNumber),
      ),
      VerificationPurpose.passwordReset => ref.watch(
        passwordResetProvider.select((form) => form.normalizedPhoneNumber),
      ),
    };
    final provider = phoneVerificationProvider(phoneNumber);
    final verification = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final errorMessage = verification.isExpired
        ? AuthStrings.codeExpired
        : verification.errorMessage;

    Future<void> verify() async {
      final isVerified = await notifier.verify();
      if (!isVerified || !context.mounted) return;
      final next = switch (purpose) {
        VerificationPurpose.signUp => AppRoute.signUpTerms,
        VerificationPurpose.passwordReset => AppRoute.resetPassword,
      };
      unawaited(context.push(next));
    }

    Future<void> resend() async {
      await notifier.resend();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AuthStrings.codeResent)));
    }

    return AuthFormLayout(
      appBar: const AppTopBar(title: AuthStrings.verificationBarTitle),
      body: [
        AppPageHeader(
          title: AuthStrings.verificationTitle,
          description: AuthStrings.verificationDescription(
            AuthValidators.maskPhoneNumber(phoneNumber),
          ),
        ),
        const SizedBox(height: _sectionGap),
        VerificationCodeField(
          length: PhoneVerificationState.codeLength,
          code: verification.code,
          onChanged: notifier.updateCode,
          hasError: verification.errorMessage != null,
          semanticLabel: AuthStrings.codeFieldLabel,
        ),
        const SizedBox(height: AppSpacing.md),
        _TimerRow(
          remainingSeconds: verification.remainingSeconds,
          onResend: resend,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          FormMessage(errorMessage, isError: true),
        ],
        const SizedBox(height: _sectionGap),
        switch (purpose) {
          VerificationPurpose.signUp => const FormMessage(
            AuthStrings.noCodeReceived,
          ),
          VerificationPurpose.passwordReset => const AppBanner.neutral(
            child: Text(AuthStrings.passwordResetCodeSent),
          ),
        },
      ],
      actions: [
        AppButton.primary(
          label: AuthStrings.verifyAndContinue,
          onPressed: verification.canVerify ? verify : null,
        ),
      ],
    );
  }
}

/// "남은 시간 02:59" 와 "인증번호 다시 받기" 한 줄.
class _TimerRow extends StatelessWidget {
  const _TimerRow({required this.remainingSeconds, required this.onResend});

  final int remainingSeconds;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Row(
      children: [
        const Text(AuthStrings.remainingTime, style: AppTypography.body),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$minutes:$seconds',
          style: AppTypography.body.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onResend,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondaryButtonText,
            textStyle: AppTypography.button,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, kMinInteractiveDimension),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(AuthStrings.resendCode),
        ),
      ],
    );
  }
}
