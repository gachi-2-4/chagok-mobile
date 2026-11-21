import 'package:chagok_mobile/features/archive/data/document_overview.dart';

/// 서류 상세 화면(07·08)에 보여 줄 서류 내용과 기한까지 남은 날.
class DocumentOverviewItem {
  const DocumentOverviewItem({required this.overview, required this.daysLeft});

  final DocumentOverview overview;

  /// 기한까지 남은 날. 기한이 없거나 지났으면 null이고 D-day를 그리지 않습니다.
  final int? daysLeft;
}
