import 'package:chagok_mobile/app/theme.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_chat_repository.dart';

extension PumpChatScreen on WidgetTester {
  /// [repository]를 저장소로 쓰는 채팅 화면 [screen]을 앱 테마로 띄웁니다.
  ///
  /// 에러 상태를 바로 확인할 수 있도록 Riverpod 자동 재시도는 끕니다.
  Future<void> pumpChatScreen(Widget screen, FakeChatRepository repository) {
    return pumpWidget(
      ProviderScope(
        overrides: [chatRepositoryProvider.overrideWithValue(repository)],
        retry: (_, _) => null,
        child: MaterialApp(theme: AppTheme.light, home: screen),
      ),
    );
  }
}
