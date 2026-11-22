import 'dart:async';

import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/in_memory_token_storage.dart';
import 'package:chagok_mobile/core/network/session_notifier.dart';
import 'package:chagok_mobile/core/network/token_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// [read]를 [gate]가 끝날 때까지 기다리게 하거나 실패하게 하는 저장소.
class _SlowTokenStorage extends InMemoryTokenStorage {
  final gate = Completer<void>();
  Exception? readError;

  @override
  Future<AuthTokens?> read() async {
    await gate.future;
    if (readError case final error?) throw error;
    return super.read();
  }
}

void main() {
  const tokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');

  ProviderContainer createContainer(TokenStorage store) {
    final container = ProviderContainer(
      overrides: [tokenStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    container.listen(sessionProvider, (_, _) {});
    return container;
  }

  /// 저장한 토큰을 확인하는 일이 끝날 때까지 기다립니다.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('SessionNotifier', () {
    test('앱을 열면 저장한 토큰을 확인하는 동안 확인 중이다', () {
      final container = createContainer(_SlowTokenStorage());

      expect(container.read(sessionProvider), SessionStatus.checking);
    });

    test('기기에 토큰이 남아 있으면 로그인 상태로 시작한다', () async {
      final store = InMemoryTokenStorage();
      await store.save(tokens);
      final container = createContainer(store);

      await settle();

      expect(container.read(sessionProvider), SessionStatus.signedIn);
    });

    test('기기에 토큰이 없으면 로그아웃 상태로 시작한다', () async {
      final container = createContainer(InMemoryTokenStorage());

      await settle();

      expect(container.read(sessionProvider), SessionStatus.signedOut);
    });

    test('저장한 토큰을 읽지 못하면 로그아웃 상태로 본다', () async {
      final store = _SlowTokenStorage()..readError = Exception('키체인 오류');
      final container = createContainer(store);

      store.gate.complete();
      await settle();

      expect(container.read(sessionProvider), SessionStatus.signedOut);
    });

    test('확인하는 사이 로그인하면 확인 결과로 덮어쓰지 않는다', () async {
      final store = _SlowTokenStorage();
      final container = createContainer(store);

      await container.read(tokenStorageProvider).save(tokens);
      store.gate.complete();
      await settle();

      expect(container.read(sessionProvider), SessionStatus.signedIn);
    });

    test('토큰을 저장하거나 지우면 로그인 상태도 바뀐다', () async {
      final container = createContainer(InMemoryTokenStorage());
      await settle();
      final storage = container.read(tokenStorageProvider);

      await storage.save(tokens);
      expect(container.read(sessionProvider), SessionStatus.signedIn);

      await storage.clear();
      expect(container.read(sessionProvider), SessionStatus.signedOut);
    });
  });

  group('isSignedInProvider', () {
    test('확인 중이면 로그인하지 않은 것으로 본다', () {
      final container = createContainer(_SlowTokenStorage());

      expect(container.read(isSignedInProvider), isFalse);
    });

    test('토큰을 저장하면 로그인한 것으로 보고 지우면 다시 아니라고 본다', () async {
      final container = createContainer(InMemoryTokenStorage());
      await settle();
      final storage = container.read(tokenStorageProvider);

      await storage.save(tokens);
      expect(container.read(isSignedInProvider), isTrue);

      await storage.clear();
      expect(container.read(isSignedInProvider), isFalse);
    });
  });
}
