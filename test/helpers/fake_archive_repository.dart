import 'dart:async';

import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_document.dart';
import 'package:chagok_mobile/features/archive/data/box_document_not_found_exception.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/data/box_not_found_exception.dart';
import 'package:chagok_mobile/features/archive/data/document_overview.dart';
import 'package:chagok_mobile/features/archive/data/document_search_result.dart';

/// 정해 둔 보관함·서류를 돌려주고, 만들기 요청을 기록하는 가짜 [ArchiveRepository].
class FakeArchiveRepository implements ArchiveRepository {
  FakeArchiveRepository({
    List<ArchiveBox>? boxes,
    Map<String, List<BoxDocument>>? documents,
    Map<String, DocumentOverview>? overviews,
  }) : boxes = boxes ?? [],
       documents = documents ?? {},
       overviews = overviews ?? {};

  /// [fetchBoxes]·[fetchBox]가 돌려줄 보관함.
  List<ArchiveBox> boxes;

  /// 보관함 id별로 [fetchDocuments]가 돌려줄 서류.
  Map<String, List<BoxDocument>> documents;

  /// 서류 id별로 [fetchDocumentOverview]가 돌려줄 서류 상세.
  Map<String, DocumentOverview> overviews;

  /// 값을 넣으면 가져오는 메서드가 이 예외를 던집니다.
  Exception? fetchError;

  /// 값을 넣으면 [searchDocuments]가 이 예외를 던집니다.
  Exception? searchError;

  /// 값을 넣으면 [fetchDocumentOverview]가 이 예외를 던집니다.
  Exception? overviewError;

  /// [searchDocuments]로 받은 검색어.
  final searchQueries = <String>[];

  /// 값을 넣으면 [createBox]가 이 예외를 던집니다.
  Exception? createError;

  /// 값을 넣으면 [createBox]가 이것이 끝날 때까지 기다립니다.
  Completer<void>? createGate;

  /// [createBox]로 받은 (이름, 색, 아이콘).
  final created = <(String, BoxColor, BoxIcon)>[];

  @override
  Future<List<ArchiveBox>> fetchBoxes(DateTime today) async {
    if (fetchError case final error?) throw error;
    return boxes;
  }

  @override
  Future<ArchiveBox> fetchBox(String boxId, DateTime today) async {
    if (fetchError case final error?) throw error;
    for (final box in boxes) {
      if (box.id == boxId) return box;
    }
    throw BoxNotFoundException(boxId);
  }

  @override
  Future<List<BoxDocument>> fetchDocuments(String boxId, DateTime today) async {
    if (fetchError case final error?) throw error;
    if (!boxes.any((box) => box.id == boxId)) {
      throw BoxNotFoundException(boxId);
    }
    return documents[boxId] ?? [];
  }

  /// 서류 이름에 [query]가 들어간 서류를 보관함 순서대로 돌려줍니다.
  ///
  /// 실제 저장소처럼 띄어쓰기·대소문자를 가리지 않고, 검색어가 비면 빈 목록입니다.
  @override
  Future<List<DocumentSearchResult>> searchDocuments(
    String query,
    DateTime today,
  ) async {
    searchQueries.add(query);
    if (searchError case final error?) throw error;
    final keyword = _normalize(query);
    if (keyword.isEmpty) return [];
    return [
      for (final box in boxes)
        for (final document in documents[box.id] ?? const <BoxDocument>[])
          if (_normalize(document.title).contains(keyword))
            DocumentSearchResult(document: document, boxName: box.name),
    ];
  }

  static String _normalize(String text) =>
      text.replaceAll(RegExp(r'\s+'), '').toLowerCase();

  @override
  Future<DocumentOverview> fetchDocumentOverview(
    String documentId,
    DateTime today,
  ) async {
    if (overviewError case final error?) throw error;
    if (overviews[documentId] case final overview?) return overview;
    throw BoxDocumentNotFoundException(documentId);
  }

  @override
  Future<ArchiveBox> createBox({
    required String name,
    required BoxColor color,
    required BoxIcon icon,
  }) async {
    await createGate?.future;
    if (createError case final error?) throw error;
    created.add((name, color, icon));
    final box = ArchiveBox(
      id: 'created-${created.length}',
      name: name,
      color: color,
      icon: icon,
      documentCount: 0,
    );
    boxes = [...boxes, box];
    return box;
  }
}
