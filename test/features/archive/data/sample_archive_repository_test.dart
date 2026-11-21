import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_document_not_found_exception.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/data/box_not_found_exception.dart';
import 'package:chagok_mobile/features/archive/data/sample_archive_repository.dart';
import 'package:chagok_mobile/features/document/data/in_memory_document_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 11, 20, 9);
  late SampleArchiveRepository repository;

  setUp(() => repository = SampleArchiveRepository());

  group('SampleArchiveRepository', () {
    test('보관함을 가져오면 서류 수와 가장 가까운 기한을 함께 돌려준다', () async {
      final boxes = await repository.fetchBoxes(today);

      final housing = boxes.firstWhere((box) => box.id == 'housing');
      expect(housing.documentCount, 3);
      expect(housing.nextDueDate, DateTime(2026, 12, 3));
    });

    test('다음 날 다시 가져오면 기한 날짜는 처음 가져온 날 기준 그대로다', () async {
      await repository.fetchBoxes(today);

      final boxes = await repository.fetchBoxes(DateTime(2026, 11, 21, 9));
      final documents = await repository.fetchDocuments(
        'housing',
        DateTime(2026, 11, 21, 9),
      );

      final housing = boxes.firstWhere((box) => box.id == 'housing');
      expect(housing.nextDueDate, DateTime(2026, 12, 3));
      expect(documents.first.dueDate, DateTime(2027, 1, 5));
    });

    test('기한이 있는 서류가 없으면 가장 가까운 기한은 null이다', () async {
      final boxes = await repository.fetchBoxes(today);

      final car = boxes.firstWhere((box) => box.id == 'car');
      expect(car.nextDueDate, isNull);
    });

    test('서류를 가져오면 기한을 오늘부터 센 날짜로 돌려준다', () async {
      final documents = await repository.fetchDocuments('housing', today);

      expect(documents.map((document) => document.title), [
        '전세 임대차 계약서',
        '11월 관리비 고지서',
        '전입신고 확인서',
      ]);
      expect(documents.first.dueDate, DateTime(2027, 1, 5));
      expect(documents.last.dueDate, isNull);
    });

    test('없는 보관함을 가져오면 BoxNotFoundException을 던진다', () {
      expect(
        repository.fetchBox('missing', today),
        throwsA(isA<BoxNotFoundException>()),
      );
      expect(
        repository.fetchDocuments('missing', today),
        throwsA(isA<BoxNotFoundException>()),
      );
    });

    test('서류 이름으로 찾으면 맞는 서류와 담긴 보관함 이름을 돌려준다', () async {
      final results = await repository.searchDocuments('관리비', today);

      expect(results.map((result) => result.document.title), ['11월 관리비 고지서']);
      expect(results.single.boxName, '집 · 임대');
    });

    test('본문에만 있는 말로 찾으면 그 서류를 돌려준다', () async {
      final results = await repository.searchDocuments('확정일자', today);

      expect(results.map((result) => result.document.id), ['move-in-report']);
    });

    test('띄어쓰기를 다르게 적으면 공백을 무시하고 같은 서류를 찾는다', () async {
      final results = await repository.searchDocuments('임대차계약서', today);

      expect(results.map((result) => result.document.id), ['lease']);
    });

    test('검색어가 공백뿐이면 빈 목록을 돌려준다', () async {
      expect(await repository.searchDocuments('  ', today), isEmpty);
    });

    test('맞는 서류가 없으면 빈 목록을 돌려준다', () async {
      expect(await repository.searchDocuments('비행기표', today), isEmpty);
    });

    test('서류를 쉬운 말로 바꾸면 미리 적어 둔 설명을 돌려준다', () async {
      final text = await repository.translateToPlainLanguage('lease');

      expect(text, contains('보증금'));
    });

    test('없는 서류를 쉬운 말로 바꾸면 BoxDocumentNotFoundException을 던진다', () {
      expect(
        repository.translateToPlainLanguage('missing'),
        throwsA(isA<BoxDocumentNotFoundException>()),
      );
    });

    // 서류를 누르면 서류 화면이 서류 저장소에서 같은 id로 불러오므로,
    // 두 예시 저장소의 서류가 어긋나면 오류 화면이 뜹니다.
    test('예시 서류를 서류 저장소에서 열면 모두 같은 보관함·고를 수 있는 종류로 열린다', () async {
      final documentRepository = InMemoryDocumentRepository();
      final boxes = await repository.fetchBoxes(today);

      for (final box in boxes) {
        for (final document in await repository.fetchDocuments(box.id, today)) {
          final detail = await documentRepository.fetchDetail(document.id);
          expect(detail.boxName, box.name, reason: document.id);
          expect(
            documentRepository.documentTypes,
            contains(detail.documentType),
            reason: document.id,
          );
        }
      }
    });

    test('보관함을 만들면 서류 없이 목록 끝에 더한다', () async {
      final created = await repository.createBox(
        name: '반려동물',
        color: BoxColor.green,
        icon: BoxIcon.pet,
      );

      final boxes = await repository.fetchBoxes(today);
      expect(boxes.last.id, created.id);
      expect(boxes.last.name, '반려동물');
      expect(boxes.last.documentCount, 0);
      expect(await repository.fetchDocuments(created.id, today), isEmpty);
    });

    test('보관함을 두 번 만들면 서로 다른 id를 준다', () async {
      final first = await repository.createBox(
        name: '하나',
        color: BoxColor.peach,
        icon: BoxIcon.home,
      );
      final second = await repository.createBox(
        name: '둘',
        color: BoxColor.gray,
        icon: BoxIcon.bank,
      );

      expect(first.id, isNot(second.id));
    });
  });
}
