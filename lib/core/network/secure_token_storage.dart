import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 기기 보안 저장소(iOS 키체인, Android Keystore)에 토큰을 두는 저장소.
///
/// 앱을 껐다 켜도 로그인이 유지됩니다(자동 로그인). "자동 로그인"을 끄고 로그인하면
/// 메모리에만 두어 앱을 끄면 사라집니다.
///
/// 기기 저장소는 읽고 쓰기를 기다려야 하므로, [replaceIf]의 비교와 바꾸기 사이에
/// 다른 저장·삭제가 끼어들지 않도록 모든 작업을 차례로 처리합니다.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({this._storage = const FlutterSecureStorage()});

  final FlutterSecureStorage _storage;

  /// 지금 토큰. 처음 읽을 때 기기 저장소에서 불러옵니다.
  AuthTokens? _tokens;
  var _isLoaded = false;

  /// 지금 토큰을 기기에 남기는지. "자동 로그인"을 끄고 로그인하면 false입니다.
  var _isRemembered = true;

  /// 앞선 작업이 끝나야 다음 작업을 시작하도록 잇는 줄.
  Future<void> _queue = Future.value();

  static const _accessTokenKey = 'chagok.accessToken';
  static const _refreshTokenKey = 'chagok.refreshToken';

  @override
  Future<AuthTokens?> read() => _locked(_load);

  @override
  Future<void> save(AuthTokens tokens, {bool remember = true}) {
    return _locked(() async {
      _tokens = tokens;
      _isLoaded = true;
      _isRemembered = remember;
      await (remember ? _write(tokens) : _delete());
    });
  }

  @override
  Future<void> clear() {
    return _locked(() async {
      _tokens = null;
      _isLoaded = true;
      await _delete();
    });
  }

  @override
  Future<bool> replaceIf({required AuthTokens expected, AuthTokens? next}) {
    return _locked(() async {
      final current = await _load();
      if (current?.refreshToken != expected.refreshToken) return false;
      _tokens = next;
      if (next == null) {
        await _delete();
      } else if (_isRemembered) {
        await _write(next);
      }
      return true;
    });
  }

  Future<T> _locked<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    // 한 작업이 실패해도 다음 작업은 이어서 처리합니다.
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<AuthTokens?> _load() async {
    if (_isLoaded) return _tokens;
    try {
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      _tokens = accessToken == null || refreshToken == null
          ? null
          : AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
    } catch (error, stackTrace) {
      // 기기 저장소가 깨졌거나 읽을 수 없으면 로그인하지 않은 것으로 봅니다.
      debugPrint('저장한 토큰을 읽지 못했습니다: $error\n$stackTrace');
      _tokens = null;
    }
    _isLoaded = true;
    return _tokens;
  }

  Future<void> _write(AuthTokens tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
  }

  Future<void> _delete() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
