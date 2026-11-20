import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_card.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_strings.dart';
import 'package:chagok_mobile/features/upload/presentation/widgets/source_option_tone.dart';
import 'package:flutter/material.dart';

/// 서류를 가져올 방법 하나를 보여 주는 큰 카드. 예: "사진 촬영"
class SourceOptionCard extends StatelessWidget {
  const SourceOptionCard({
    required this.tone,
    required this.title,
    required this.description,
    required this.onTap,
    super.key,
  });

  /// 카드 색.
  final SourceOptionTone tone;

  /// 방법 이름. 예: "사진 촬영"
  final String title;

  /// 제목 아래 설명. 끝에 화살표를 붙여 보여 줍니다.
  final String description;

  /// null이면 누를 수 없습니다.
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
          const SizedBox(height: AppSpacing.cardTitleGap),
          Text(
            UploadStrings.optionDescription(description),
            style: AppTypography.pageDescription,
          ),
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
