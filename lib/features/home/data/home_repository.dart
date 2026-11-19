import 'package:chagok_mobile/features/home/data/box_category.dart';
import 'package:chagok_mobile/features/home/data/home_summary.dart';
import 'package:chagok_mobile/features/home/data/recent_alert.dart';
import 'package:chagok_mobile/features/home/data/recent_box.dart';
import 'package:chagok_mobile/features/home/data/schedule_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈 화면에 필요한 내용을 모아 가져오는 창구.
abstract interface class HomeRepository {
  /// [now] 기준의 일정, 최근 보관함, 최근 알림을 가져옵니다.
  Future<HomeSummary> fetchSummary(DateTime now);
}

/// 백엔드가 정해지기 전까지 화면을 확인하려고 쓰는 예시 데이터.
///
/// 날짜는 [now] 기준으로 만들어, 언제 열어도 비슷하게 보입니다.
class SampleHomeRepository implements HomeRepository {
  @override
  Future<HomeSummary> fetchSummary(DateTime now) async {
    final today = DateTime(now.year, now.month, now.day);

    return HomeSummary(
      schedules: [
        ScheduleItem(
          date: today.add(const Duration(days: 2)),
          title: '통신 서비스 요금 납부일',
        ),
        ScheduleItem(
          date: today.add(const Duration(days: 13)),
          title: '관리비 납부일',
        ),
        ScheduleItem(
          date: today.subtract(const Duration(days: 3)),
          title: '자동차 보험료 납부일',
        ),
      ],
      recentBoxes: [
        RecentBox(
          id: 'housing',
          name: '집 · 임대',
          category: BoxCategory.housing,
          documentCount: 3,
          lastOpenedAt: now.subtract(const Duration(hours: 1)),
          nextDueDate: today.add(const Duration(days: 13)),
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

/// 앱 전역 [HomeRepository].
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  // TODO: 보관함·알림·캘린더 기능이 생기면 그 Provider를 모아 만듭니다.
  return SampleHomeRepository();
});
