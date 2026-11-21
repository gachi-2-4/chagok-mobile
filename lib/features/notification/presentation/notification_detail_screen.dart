import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/notification/application/notification_done_notifier.dart';
import 'package:chagok_mobile/features/notification/application/notification_filter_notifier.dart';
import 'package:chagok_mobile/features/notification/application/notification_list_notifier.dart';
import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/notification_kind.dart';
import 'package:chagok_mobile/features/notification/presentation/notification_strings.dart';
import 'package:chagok_mobile/features/notification/presentation/widgets/notification_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// N02 · 알림 하나의 자세한 내용. 납부 알림은 완료로 표시할 수 있습니다.
///
/// 위에 목록과 같은 탭을 두고, 탭을 누르면 그 탭으로 목록에 돌아갑니다.
class NotificationDetailScreen extends ConsumerWidget {
  const NotificationDetailScreen({required this.notificationId, super.key});

  /// 보여 줄 알림 id.
  final String notificationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppTopBar.plain(
        title: NotificationStrings.title,
        action: AppTopBarAction(
          icon: AppIcons.settings,
          semanticLabel: NotificationStrings.settings,
          onTap: () => context.go(AppRoute.notificationSettings),
        ),
      ),
      body: Column(
        children: [
          NotificationTabs(
            selected: ref.watch(notificationFilterProvider),
            onSelect: (filter) {
              ref.read(notificationFilterProvider.notifier).select(filter);
              context.pop();
            },
          ),
          Expanded(
            child: ref
                .watch(notificationListProvider)
                .when(
                  data: (notifications) {
                    final notification = notifications
                        .where((item) => item.id == notificationId)
                        .firstOrNull;
                    if (notification == null) {
                      return const Center(
                        child: Text(
                          NotificationStrings.notFound,
                          style: AppTypography.body,
                        ),
                      );
                    }
                    return _DetailContent(notification: notification);
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => const Center(
                    child: Text(
                      NotificationStrings.loadFailed,
                      style: AppTypography.body,
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

/// 머리(날짜·제목), 본문, 아래 버튼.
class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canMarkDone =
        notification.kind == NotificationKind.payment && !notification.isDone;
    final isSavingDone = ref
        .watch(notificationDoneProvider)
        .contains(notification.id);

    final documentId = notification.documentId;
    final openDocument = documentId == null
        ? null
        : () => unawaited(context.push(AppRoute.document(documentId)));

    Future<void> markDone() async {
      final isSaved = await ref
          .read(notificationDoneProvider.notifier)
          .markDone(notification.id);
      // null이면 이미 저장하고 있는 중이라, 먼저 누른 쪽이 안내와 복귀를 맡습니다.
      if (isSaved == null || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSaved
                ? NotificationStrings.markedDone
                : NotificationStrings.saveFailed,
          ),
        ),
      );
      if (isSaved) context.pop();
    }

    return Column(
      children: [
        Expanded(
          child: _DetailScroll(
            notification: notification,
            showsPaymentGuide: canMarkDone,
            onDocumentTap: openDocument,
          ),
        ),
        _DetailActions(
          canMarkDone: canMarkDone,
          onMarkDone: isSavingDone ? null : () => unawaited(markDone()),
          onViewDocument: openDocument,
        ),
      ],
    );
  }
}

/// 머리와 본문. 본문 바탕을 화면 아래까지 채우고, 길면 함께 스크롤합니다.
class _DetailScroll extends StatelessWidget {
  const _DetailScroll({
    required this.notification,
    required this.showsPaymentGuide,
    required this.onDocumentTap,
  });

  final AppNotification notification;
  final bool showsPaymentGuide;

  /// 연결된 서류를 여는 동작. 서류 id가 없으면 null이고 눌리지 않습니다.
  final VoidCallback? onDocumentTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _DetailHeader(notification: notification)),
        SliverFillRemaining(
          hasScrollBody: false,
          child: _DetailBody(
            notification: notification,
            showsPaymentGuide: showsPaymentGuide,
            onDocumentTap: onDocumentTap,
          ),
        ),
      ],
    );
  }
}

/// "2026-11-18 · 오전 9:00 · 집 · 임대"와 제목.
class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.notification});

  final AppNotification notification;

  static const _dividerThickness = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                NotificationStrings.detailMeta(notification),
                style: AppTypography.noticeMeta,
              ),
              const SizedBox(height: AppSpacing.sectionTitleGap),
              Text(
                NotificationStrings.detailTitle(notification),
                style: AppTypography.noticeTitle,
              ),
            ],
          ),
        ),
        const Divider(
          height: _dividerThickness,
          thickness: _dividerThickness,
          color: AppColors.noticeDivider,
        ),
      ],
    );
  }
}

/// 본문 문장과 정보 묶음(납부 정보·연결 서류·안내).
class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.notification,
    required this.showsPaymentGuide,
    required this.onDocumentTap,
  });

  final AppNotification notification;
  final bool showsPaymentGuide;

  /// 연결된 서류를 여는 동작. 서류 id가 없으면 null이고 눌리지 않습니다.
  final VoidCallback? onDocumentTap;

  @override
  Widget build(BuildContext context) {
    final message = notification.message;
    final blocks = <Widget>[
      if (message != null)
        Text(
          message,
          style: AppTypography.pageDescription.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      if (notification.amount != null || notification.dueDate != null)
        _DueInfoBlock(notification: notification),
      if (notification.documentName case final documentName?)
        _InfoBlock(
          title: NotificationStrings.linkedDocument,
          children: [
            _InfoRow(
              label: notification.boxName ?? '',
              value: NotificationStrings.documentLink(documentName),
              onValueTap: onDocumentTap,
            ),
          ],
        ),
      if (showsPaymentGuide) const _PaymentGuideBlock(),
    ];

    return ColoredBox(
      color: AppColors.noticeBody,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.noticeBodyPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, block) in blocks.indexed) ...[
              if (index > 0) const SizedBox(height: AppSpacing.noticeBlockGap),
              block,
            ],
          ],
        ),
      ),
    );
  }
}

/// "납부 정보"(금액·납부일) 또는 "만기 일정" 묶음.
class _DueInfoBlock extends StatelessWidget {
  const _DueInfoBlock({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final amount = notification.amount;
    final dueDate = notification.dueDate;
    final kind = notification.kind;

    return _InfoBlock(
      title: NotificationStrings.infoTitle(kind),
      children: [
        if (amount != null)
          _InfoRow(
            label: NotificationStrings.amount,
            value: NotificationStrings.won(amount),
            isValueBold: true,
          ),
        if (dueDate != null)
          _InfoRow(
            label: NotificationStrings.dueDateLabel(kind),
            value: NotificationStrings.fullDate(dueDate),
          ),
      ],
    );
  }
}

/// 납부 알림의 "안내" 묶음. 완료로 표시하면 완료 탭에서 볼 수 있다고 알려 줍니다.
class _PaymentGuideBlock extends StatelessWidget {
  const _PaymentGuideBlock();

  @override
  Widget build(BuildContext context) {
    return _InfoBlock(
      title: NotificationStrings.guide,
      children: [
        Text(
          NotificationStrings.paymentGuide,
          style: AppTypography.listSubtitle.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 굵은 제목 아래에 정보 줄을 쌓은 묶음. 예: "납부 정보"
class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTypography.fieldInput.copyWith(fontWeight: FontWeight.w700),
        ),
        for (final child in children) ...[
          const SizedBox(height: AppSpacing.sectionTitleGap),
          child,
        ],
      ],
    );
  }
}

/// 왼쪽 이름, 오른쪽 값 한 줄. 값을 누를 수 있으면 강조색 링크로 보여 줍니다.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isValueBold = false,
    this.onValueTap,
  });

  final String label;
  final String value;
  final bool isValueBold;
  final VoidCallback? onValueTap;

  @override
  Widget build(BuildContext context) {
    final onValueTap = this.onValueTap;
    final valueStyle = AppTypography.fieldInput.copyWith(
      fontWeight: isValueBold || onValueTap != null ? FontWeight.w700 : null,
      color: onValueTap != null ? AppColors.navActive : null,
    );
    final valueText = Text(
      value,
      textAlign: TextAlign.right,
      style: valueStyle,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이름이 길면 줄을 바꿔 오른쪽 값 자리를 남깁니다.
        Flexible(
          child: Text(
            label,
            style: AppTypography.fieldInput.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: onValueTap == null
                ? valueText
                : Semantics(
                    button: true,
                    child: InkWell(onTap: onValueTap, child: valueText),
                  ),
          ),
        ),
      ],
    );
  }
}

/// 아래 버튼 묶음. 누를 수 없는 버튼은 숨깁니다.
class _DetailActions extends StatelessWidget {
  const _DetailActions({
    required this.canMarkDone,
    required this.onMarkDone,
    required this.onViewDocument,
  });

  /// 완료 버튼을 보여 줄지 여부.
  final bool canMarkDone;

  /// 완료 버튼을 눌렀을 때. 저장하는 동안은 null이라 버튼이 꺼집니다.
  final VoidCallback? onMarkDone;
  final VoidCallback? onViewDocument;

  @override
  Widget build(BuildContext context) {
    final onViewDocument = this.onViewDocument;
    if (!canMarkDone && onViewDocument == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.noticePaddingVertical,
          AppSpacing.screenHorizontal,
          AppSpacing.actionsBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canMarkDone)
              AppButton.primary(
                label: NotificationStrings.markDone,
                onPressed: onMarkDone,
              ),
            if (canMarkDone && onViewDocument != null)
              const SizedBox(height: AppSpacing.buttonGap),
            if (onViewDocument != null)
              AppButton.secondary(
                label: NotificationStrings.viewDocument,
                onPressed: onViewDocument,
              ),
          ],
        ),
      ),
    );
  }
}
