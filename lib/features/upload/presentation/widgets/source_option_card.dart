import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// [SourceOptionCard]의 색.
enum SourceOptionTone { peach, green, plain }

/// 서류를 가져올 방법 하나를 보여 주는 큰 카드. 예: "사진 촬영"
class SourceOptionCard extends StatelessWidget {
  const SourceOptionCard({
    required this.tone,
    required this.title,
    required this.description,
    required this.onTap,
    super.key,
  });

  final SourceOptionTone tone;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Semantics(
      button: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(title, style: AppTypography.cardTitle),
          ),
          const SizedBox(height: 10),
          Text('$description　›', style: AppTypography.pageDescription),
        ],
      ),
    );

    return switch (tone) {
      SourceOptionTone.peach => AppCard.peach(onTap: onTap, child: content),
      SourceOptionTone.green => AppCard.green(onTap: onTap, child: content),
      SourceOptionTone.plain => AppCard(onTap: onTap, child: content),
    };
  }
}
