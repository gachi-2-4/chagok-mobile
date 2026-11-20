import 'package:chagok_mobile/features/calendar/data/calendar_repository.dart';
import 'package:chagok_mobile/features/calendar/data/deadline.dart';

/// 백엔드가 정해지기 전까지 화면을 확인하려고 쓰는 예시 기한.
///
/// 날짜는 [fetchDeadlines]의 today 기준으로 만들어, 언제 열어도 비슷하게
/// 보입니다. 등록 여부는 메모리에만 남습니다.
class SampleCalendarRepository implements CalendarRepository {
  final _registered = <String>{'jeonse'};

  @override
  Future<List<Deadline>> fetchDeadlines(DateTime today) async {
    // 기한은 달력 날짜로 셉니다. Duration으로 더하면 서머타임 경계에서 하루 어긋납니다.
    DateTime day(int offset) =>
        DateTime(today.year, today.month, today.day + offset);
    Deadline deadline(String id, String title, int offset, List<String> tags) {
      return Deadline(
        id: id,
        title: title,
        dueDate: day(offset),
        tags: tags,
        isRegistered: _registered.contains(id),
      );
    }

    return [
      deadline('insurance-claim', '실손보험 청구 안내', 8, ['병원', '보험']),
      deadline('maintenance', '관리비 고지서', 13, ['집', '임대']),
      deadline('income-tax', '종합소득세 중간예납', 18, ['세금']),
      deadline('checkup', '건강검진 결과지', 33, ['병원', '보험']),
      deadline('jeonse', '전세 임대차 계약서', 46, ['집', '임대']),
      deadline('car-tax', '자동차세 고지서 (2기)', 49, ['자동차']),
      deadline('car-insurance', '자동차보험 증권', 63, ['자동차']),
      deadline('internet', '인터넷 약정 안내', 200, ['통신', '구독']),
    ];
  }

  @override
  Future<void> setRegistered({
    required String id,
    required bool isRegistered,
  }) async {
    if (isRegistered) {
      _registered.add(id);
    } else {
      _registered.remove(id);
    }
  }
}
