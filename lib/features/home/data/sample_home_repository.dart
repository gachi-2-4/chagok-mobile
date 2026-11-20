import 'package:chagok_mobile/features/home/data/box_category.dart';
import 'package:chagok_mobile/features/home/data/home_repository.dart';
import 'package:chagok_mobile/features/home/data/home_summary.dart';
import 'package:chagok_mobile/features/home/data/recent_alert.dart';
import 'package:chagok_mobile/features/home/data/recent_box.dart';
import 'package:chagok_mobile/features/home/data/schedule_item.dart';

/// 백엔드가 정해지기 전까지 화면을 확인하려고 쓰는 예시 데이터.
///
/// 날짜는 [now] 기준으로 만들어, 언제 열어도 비슷하게 보입니다.
class SampleHomeRepository implements HomeRepository {
  @override
  Future<HomeSummary> fetchSummary(DateTime now) async {
    // 일정 날짜는 달력 날짜로 셉니다. Duration으로 더하면 서머타임 경계에서
    // 하루 어긋납니다. 실제로 흐른 시간인 열어 본 시각·알림 시각은 그대로 둡니다.
    DateTime day(int offset) => DateTime(now.year, now.month, now.day + offset);

    return HomeSummary(
      schedules: [
        ScheduleItem(date: day(2), title: '통신 서비스 요금 납부일'),
        ScheduleItem(date: day(13), title: '관리비 납부일'),
        ScheduleItem(date: day(-3), title: '자동차 보험료 납부일'),
      ],
      recentBoxes: [
        RecentBox(
          id: 'housing',
          name: '집 · 임대',
          category: BoxCategory.housing,
          documentCount: 3,
          lastOpenedAt: now.subtract(const Duration(hours: 1)),
          nextDueDate: day(13),
        ),
        RecentBox(
          id: 'telecom',
          name: '통신 · 구독',
          category: BoxCategory.telecom,
          documentCount: 1,
          lastOpenedAt: now.subtract(const Duration(days: 1)),
        ),
      ],
      recentAlerts: [
        RecentAlert(
          id: 'lease-expiry',
          title: '임대차계약서 만기가 30일 남았어요',
          boxName: '집 · 임대',
          createdAt: now,
          isRead: false,
        ),
        RecentAlert(
          id: 'telecom-payment',
          title: '통신 서비스 요금이 이번 주에 납부돼요',
          boxName: '통신 · 구독',
          createdAt: now.subtract(const Duration(hours: 2)),
          isRead: false,
        ),
        RecentAlert(
          id: 'car-compare',
          title: '자동차 보험 계약서 비교가 완료됐어요',
          boxName: '자동차',
          createdAt: now.subtract(const Duration(days: 1)),
          isRead: true,
        ),
      ],
    );
  }
}
