import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서류 검색창에 적은 글자. 검색 화면을 벗어나면 비웁니다.
final documentSearchQueryProvider =
    NotifierProvider.autoDispose<DocumentSearchQueryNotifier, String>(
      DocumentSearchQueryNotifier.new,
    );

/// 서류 검색어를 들고 있습니다.
class DocumentSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  /// 검색어를 바꿉니다.
  void update(String query) => state = query;
}
