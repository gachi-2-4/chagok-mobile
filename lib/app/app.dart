import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/app/theme.dart';
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

    return MaterialApp.router(
      title: '차곡',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
