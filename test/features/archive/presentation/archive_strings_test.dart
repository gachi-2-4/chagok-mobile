import 'package:chagok_mobile/features/archive/data/document_importance.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArchiveStrings.cost', () {
    test('금액을 넣으면 세 자리마다 쉼표를 넣어 이름과 함께 돌려준다', () {
      expect(ArchiveStrings.cost('보증금', 230000000), '보증금 230,000,000원');
    });

    test('세 자리 이하 금액이면 쉼표 없이 돌려준다', () {
      expect(ArchiveStrings.cost('수수료', 900), '수수료 900원');
    });
  });

  group('ArchiveStrings.dueLine', () {
    test('기간 끝과 기한 이름이 있으면 둘 다 적는다', () {
      expect(
        ArchiveStrings.dueLine(
          dueDate: DateTime(2026, 12, 28),
          dueLabel: '갱신 통보',
          periodEnd: DateTime(2027, 2, 28),
        ),
        '~2027.02.28 · 갱신 통보 12.28까지',
      );
    });

    test('기간 끝이 없으면 기한만 적는다', () {
      expect(
        ArchiveStrings.dueLine(dueDate: DateTime(2026, 12, 3), dueLabel: '납부'),
        '납부 12.3까지',
      );
    });

    test('기한 이름이 없으면 날짜만 적는다', () {
      expect(ArchiveStrings.dueLine(dueDate: DateTime(2026, 12, 3)), '12.3까지');
    });
  });

  group('ArchiveStrings.importanceLevel', () {
    test('중요도를 넣으면 높음·보통·낮음으로 돌려준다', () {
      expect(DocumentImportance.values.map(ArchiveStrings.importanceLevel), [
        '높음',
        '보통',
        '낮음',
      ]);
    });
  });
}
