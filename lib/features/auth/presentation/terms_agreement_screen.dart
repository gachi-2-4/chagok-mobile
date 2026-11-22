import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/features/auth/application/sign_up_notifier.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/terms_agreement_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A03 · 약관에 동의하고 가입을 마치는 화면.
class TermsAgreementScreen extends ConsumerWidget {
  const TermsAgreementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(signUpProvider);
    SignUpNotifier notifier() => ref.read(signUpProvider.notifier);

    Future<void> complete() async {
      final isCompleted = await notifier().complete();
      if (!isCompleted || !context.mounted) return;
      ref.invalidate(signUpProvider);
      // 가입을 마치면 첫 설문(O01~O04)을 거쳐 홈으로 갑니다.
      context.go(AppRoute.onboarding);
    }

    return TermsAgreementForm(
      agreedTerms: form.agreedTerms,
      hasAgreedToAll: form.hasAgreedToAll,
      canComplete: form.canComplete,
      failure: form.failure,
      onToggleAll: () => notifier().toggleAllTerms(),
      onToggleTerm: (term) => notifier().toggleTerm(term),
      onComplete: () => unawaited(complete()),
    );
  }
}
