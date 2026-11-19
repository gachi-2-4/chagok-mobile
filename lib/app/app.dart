import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/app/theme.dart';
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
            textScaler: _MultipliedTextScaler(
              mediaQuery.textScaler,
              textScale ?? 1,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// 기기 글자 크기 설정에 앱 설정 배율을 한 번 더 곱하는 [TextScaler].
class _MultipliedTextScaler extends TextScaler {
  const _MultipliedTextScaler(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  // ignore: deprecated_member_use - TextScaler를 구현하려면 재정의해야 합니다.
  double get textScaleFactor => base.textScaleFactor * factor;

  @override
  bool operator ==(Object other) =>
      other is _MultipliedTextScaler &&
      other.base == base &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
