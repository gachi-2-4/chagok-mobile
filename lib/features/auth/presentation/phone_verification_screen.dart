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
import 'package:chagok_mobile/features/auth/presentation/verification_purpose.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/form_message.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/verification_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A02·L04 · 문자로 받은 인증번호를 입력하는 화면.
class PhoneVerificationScreen extends ConsumerWidget {
  const PhoneVerificationScreen({required this.purpose, super.key});

  /// 회원가입 중인지, 비밀번호 찾기 중인지. 인증한 뒤 갈 화면이 달라집니다.
  final VerificationPurpose purpose;

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

    Future<void> verify() async {
      final isVerified = await ref.read(provider.notifier).verify();
      if (!isVerified || !context.mounted) return;
      final next = switch (purpose) {
        VerificationPurpose.signUp => AppRoute.signUpTerms,
        VerificationPurpose.passwordReset => AppRoute.resetPassword,
      };
      unawaited(context.push(next));
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
        const SizedBox(height: AppSpacing.sectionGapLarge),
        _CodeInput(phoneNumber: phoneNumber, verification: verification),
        const SizedBox(height: AppSpacing.sectionGapLarge),
        switch (purpose) {
          VerificationPurpose.signUp => const FormMessage(
            text: AuthStrings.noCodeReceived,
          ),
          VerificationPurpose.passwordReset => const AppBanner.neutral(
            child: Text(AuthStrings.passwordResetCodeSent),
          ),
        },
      ],
      actions: [
        AppButton.primary(
          label: AuthStrings.verifyAndContinue,
          onPressed: verification.canVerify ? () => unawaited(verify()) : null,
        ),
      ],
    );
  }
}

/// 인증번호 칸, 남은 시간·다시 받기 줄, 만료·실패 안내.
class _CodeInput extends ConsumerWidget {
  const _CodeInput({required this.phoneNumber, required this.verification});

  final String phoneNumber;
  final PhoneVerificationState verification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = phoneVerificationProvider(phoneNumber);
    final failure = verification.failure;
    final message = verification.isExpired
        ? AuthStrings.codeExpired
        : (failure == null ? null : AuthStrings.failure(failure));

    Future<void> resend() async {
      final isSent = await ref.read(provider.notifier).resend();
      if (!isSent || !context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AuthStrings.codeResent)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VerificationCodeField(
          length: PhoneVerificationState.codeLength,
          code: verification.code,
          onChanged: (value) => ref.read(provider.notifier).updateCode(value),
          hasError: failure != null,
          semanticLabel: AuthStrings.codeFieldLabel,
        ),
        const SizedBox(height: AppSpacing.md),
        _TimerRow(
          remainingSeconds: verification.remainingSeconds,
          onResend: () => unawaited(resend()),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.sm),
          FormMessage(text: message, isError: true),
        ],
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
