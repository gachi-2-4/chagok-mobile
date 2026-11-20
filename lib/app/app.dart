import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/core/utils/app_text_scaler.dart';
import 'package:chagok_mobile/features/settings/application/settings_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 차곡 앱의 루트 위젯.
///
/// 라우터와 테마를 연결하는 역할만 담당합니다.
class ChagokApp extends ConsumerWidget {
  const ChagokApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final textScale = ref.watch(
      settingsProvider.select((settings) => settings.value?.textSize.scale),
    );

    return MaterialApp.router(
      title: '차곡',
      theme: AppTheme.light,
      routerConfig: router,
      // 설정의 글자 크기를 기기 글자 크기 위에 곱해 앱 전체에 적용합니다.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: AppTextScaler(mediaQuery.textScaler, textScale ?? 1),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
