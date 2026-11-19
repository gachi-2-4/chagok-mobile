import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 대화 목록 검색어.
final chatSearchQueryProvider =
    NotifierProvider<ChatSearchQueryNotifier, String>(
      ChatSearchQueryNotifier.new,
    );

/// 검색어를 바꿉니다.
class ChatSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}
