import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_toggle.dart';
import 'package:flutter/material.dart';

/// 제목 · 설명 · 스위치로 이루어진 목록 한 줄.
///
/// Figma `Setting/ToggleRow` 컴포넌트에 해당합니다. 예: "납부일 알림"
class AppToggleRow extends StatelessWidget {
  const AppToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final onChanged = this.onChanged;

    // 스크린 리더가 제목과 스위치를 따로 읽지 않고 하나의 스위치로 읽도록 합칩니다.
    return MergeSemantics(
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.toggleRowPaddingVertical,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.listTitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(subtitle, style: AppTypography.listSubtitle),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // 행 전체(InkWell)가 이미 포커스를 받으므로 스위치는 포커스에서 뺍니다.
              ExcludeFocus(
                child: AppToggle(value: value, onChanged: onChanged),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
