import 'package:flutter/widgets.dart';

/// 앱이 백그라운드에서 다시 앞으로 오면 [onResume]을 부릅니다.
///
/// 앱이 멈춰 있는 동안 자정이 지났을 수 있어, 날짜를 기준으로 하는 화면이
/// 돌아왔을 때 날짜를 다시 확인하는 데 씁니다. 예: 홈, 보관함의 D-n
/// [AppLifecycleListener]를 위젯 생명주기에 묶어 두려고 StatefulWidget으로 둡니다.
class AppResumeListener extends StatefulWidget {
  const AppResumeListener({
    required this.onResume,
    required this.child,
    super.key,
  });

  /// 앱이 다시 앞으로 왔을 때 부를 동작.
  final VoidCallback onResume;

  final Widget child;

  @override
  State<AppResumeListener> createState() => _AppResumeListenerState();
}

class _AppResumeListenerState extends State<AppResumeListener> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    // 위젯이 다시 그려지며 onResume이 바뀌어도 마지막 것을 부르도록 widget에서 읽습니다.
    _listener = AppLifecycleListener(onResume: () => widget.onResume());
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
