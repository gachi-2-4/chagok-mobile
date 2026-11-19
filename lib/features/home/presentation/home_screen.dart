import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';

/// 앱을 열면 처음 보이는 홈 화면.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar.logo(),
      body: Center(
        child: Text(
          '문서를 차곡차곡 정리해 보세요',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
