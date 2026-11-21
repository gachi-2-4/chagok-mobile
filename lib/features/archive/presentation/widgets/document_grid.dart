import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/features/archive/application/box_document_item.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/box_document_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 서류를 두 개씩 한 줄에 늘어놓습니다. 보관함 상세와 서류 검색에서 함께 씁니다.
///
/// 서류를 누르면 서류 상세의 원본 탭으로, 초록 버튼을 누르면 AI 정리본 탭으로 갑니다.
class DocumentGrid extends StatelessWidget {
  const DocumentGrid({required this.items, super.key});

  final List<BoxDocumentItem> items;

  @override
  Widget build(BuildContext context) {
    Widget card(BoxDocumentItem item) {
      final id = item.document.id;
      return BoxDocumentCard(
        item: item,
        onTap: () => unawaited(context.push(AppRoute.document(id))),
        onOpenSummary: () =>
            unawaited(context.push(AppRoute.document(id, showSummary: true))),
      );
    }

    return Column(
      children: [
        for (var start = 0; start < items.length; start += 2) ...[
          if (start > 0) const SizedBox(height: AppSpacing.gridRowGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: card(items[start])),
              const SizedBox(width: AppSpacing.gridColumnGap),
              Expanded(
                child: start + 1 < items.length
                    ? card(items[start + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
