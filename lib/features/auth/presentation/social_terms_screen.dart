import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/features/auth/application/terms_consent_notifier.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/terms_agreement_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A03 · 간편 로그인으로 처음 들어온 사용자가 약관에 동의하는 화면.
///
/// 계정은 이미 만들어졌으므로 동의만 기록하고 첫 설문으로 갑니다.
class SocialTermsScreen extends ConsumerWidget {
  const SocialTermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(termsConsentProvider);
    TermsConsentNotifier notifier() => ref.read(termsConsentProvider.notifier);

    Future<void> complete() async {
      final isCompleted = await notifier().complete();
      if (!isCompleted || !context.mounted) return;
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
