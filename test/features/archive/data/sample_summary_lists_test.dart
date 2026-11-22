import 'package:chagok_mobile/features/archive/data/sample_summary_lists.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sampleSummaryListsOf', () {
    test('임대차계약서면 예시 특약과 체크 목록을 돌려준다', () {
      final lists = sampleSummaryListsOf('LEASE_CONTRACT');

      expect(lists.map((list) => list.title), [specialTermsTitle, checksTitle]);
      expect(lists.first.items, isNotEmpty);
    });

    test('고지서면 특약 없이 체크 목록만 돌려준다', () {
      final lists = sampleSummaryListsOf('BILL');

      expect(lists.single.title, checksTitle);
      expect(lists.single.items, contains('납부 기한 확인'));
    });

    test('모르는 서류 종류면 기타의 체크 목록을 돌려준다', () {
      final unknown = sampleSummaryListsOf('UNKNOWN');
      final etc = sampleSummaryListsOf('ETC');

      expect(unknown.single.items, etc.single.items);
    });

    test('예시 특약 구역 이름을 보면 예시 표시가 붙어 있다', () {
      expect(specialTermsTitle, contains('예시'));
    });
  });
}
