import 'package:flutter/foundation.dart';

/// 상단 바 오른쪽에 두는 아이콘 버튼.
///
/// 예: 알림 화면의 설정(톱니바퀴) 버튼.
class AppTopBarAction {
  const AppTopBarAction({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.hasBadge = false,
  });

  /// [AppIcons]의 24x24 SVG 경로.
  final String icon;

  /// 화면 읽기 프로그램이 읽어 줄 버튼 이름. 예: "알림 설정"
  final String semanticLabel;

  final VoidCallback onTap;

  /// 아이콘 오른쪽 위에 작은 점을 찍을지 여부. 예: 읽지 않은 알림이 있을 때
  ///
  /// 점은 화면 읽기 프로그램이 읽지 않으므로, 점을 찍을 때는 [semanticLabel]에도
  /// 그 상태를 담아 주세요. 예: "알림, 읽지 않은 알림 있음"
  final bool hasBadge;
}
