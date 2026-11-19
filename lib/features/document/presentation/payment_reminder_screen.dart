import 'dart:async';

import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_banner.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_card.dart';
import 'package:chagok_mobile/core/widgets/app_chip.dart';
import 'package:chagok_mobile/core/widgets/app_document_layout.dart';
import 'package:chagok_mobile/core/widgets/app_toggle.dart';
import 'package:chagok_mobile/features/document/application/reminder_edit_notifier.dart';
import 'package:chagok_mobile/features/document/application/reminder_edit_state.dart';
import 'package:chagok_mobile/features/document/application/reminder_schedule.dart';
import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';
import 'package:chagok_mobile/features/document/presentation/document_strings.dart';
import 'package:chagok_mobile/features/document/presentation/widgets/option_sheet.dart';
import 'package:chagok_mobile/features/document/presentation/widgets/picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// D02 · 서류의 납부일 알림을 거는 화면.
class PaymentReminderScreen extends ConsumerWidget {
  const PaymentReminderScreen({required this.documentId, super.key});

  /// 알림을 걸 서류 id.
  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = reminderEditProvider(documentId);

    return ref
        .watch(provider)
        .when(
          data: (state) => _ReminderBody(documentId: documentId, state: state),
          loading: () => const AppDocumentLayout(
            body: [Center(child: CircularProgressIndicator())],
            actions: [],
          ),
          error: (error, stackTrace) => AppDocumentLayout(
            body: const [
              Text(DocumentStrings.loadFailed, style: AppTypography.body),
            ],
            actions: [
              AppButton.secondary(
                label: DocumentStrings.retry,
                onPressed: () => ref.invalidate(provider),
              ),
            ],
          ),
        );
  }
}

/// 불러온 [state]로 그린 알림 설정과 "알림 등록하기" 버튼.
class _ReminderBody extends ConsumerWidget {
  const _ReminderBody({required this.documentId, required this.state});

  final String documentId;
  final ReminderEditState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = state.reminder;

    Future<void> save() async {
      final isSaved = await ref
          .read(reminderEditProvider(documentId).notifier)
          .save();
      if (!isSaved || !context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(DocumentStrings.registered)));
      await Navigator.maybePop(context);
    }

    return AppDocumentLayout(
      body: [
        const Text(
          DocumentStrings.reminderTitle,
          style: AppTypography.pageTitle,
        ),
        const SizedBox(height: AppSpacing.block),
        _DocumentSummaryCard(detail: state.detail),
        const SizedBox(height: AppSpacing.block),
        _ReminderPickers(documentId: documentId, reminder: reminder),
        const SizedBox(height: AppSpacing.block),
        _AdvanceDayChips(documentId: documentId, reminder: reminder),
        const SizedBox(height: AppSpacing.block),
        _MonthlyRepeatRow(
          documentId: documentId,
          isMonthly: reminder.isMonthly,
        ),
        const SizedBox(height: AppSpacing.block),
        AppBanner(
          child: Text(switch (ReminderSchedule.nextAlert(
            reminder,
            DateTime.now(),
          )) {
            final next? => DocumentStrings.nextAlertNotice(next),
            null => DocumentStrings.noAdvanceSelected,
          }),
        ),
        if (state.hasSaveFailed) ...[
          const SizedBox(height: AppSpacing.stack),
          Text(
            DocumentStrings.registerFailed,
            style: AppTypography.caption.copyWith(color: AppColors.danger),
          ),
        ],
      ],
      actions: [
        AppButton.primary(
          label: DocumentStrings.register,
          onPressed: state.canSave ? () => unawaited(save()) : null,
        ),
      ],
    );
  }
}

/// "월 50만 원 · 집 · 임대 › 임대차계약서" 초록 카드.
class _DocumentSummaryCard extends StatelessWidget {
  const _DocumentSummaryCard({required this.detail});

  final DocumentDetail detail;

  @override
  Widget build(BuildContext context) {
    return AppCard.green(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              DocumentStrings.rentSummary(detail.monthlyRent),
              style: AppTypography.cardTitle,
            ),
          ),
          const SizedBox(height: AppSpacing.cardTitleGap),
          Text(
            DocumentStrings.documentPath(detail.boxName, detail.documentType),
            style: AppTypography.pageDescription,
          ),
        ],
      ),
    );
  }
}

/// 납부일과 알림 시간 고르기 입력창.
class _ReminderPickers extends ConsumerWidget {
  const _ReminderPickers({required this.documentId, required this.reminder});

  final String documentId;
  final PaymentReminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ReminderEditNotifier notifier() =>
        ref.read(reminderEditProvider(documentId).notifier);

    Future<void> pickPaymentDay() async {
      final day = await showOptionSheet(
        context,
        options: [for (var day = 1; day <= 31; day++) day],
        labelOf: DocumentStrings.monthlyDay,
        selected: reminder.paymentDay,
      );
      if (day != null) notifier().setPaymentDay(day);
    }

    Future<void> pickTime() async {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: reminder.minuteOfDay ~/ 60,
          minute: reminder.minuteOfDay % 60,
        ),
      );
      if (time != null) {
        notifier().setTime(hour: time.hour, minute: time.minute);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PickerField(
          label: DocumentStrings.paymentDay,
          value: DocumentStrings.monthlyDay(reminder.paymentDay),
          onTap: () => unawaited(pickPaymentDay()),
        ),
        const SizedBox(height: AppSpacing.block),
        PickerField(
          label: DocumentStrings.reminderTime,
          value: DocumentStrings.time(reminder.minuteOfDay),
          onTap: () => unawaited(pickTime()),
        ),
      ],
    );
  }
}

/// "미리 알림" 라벨과 당일·1·3·7일 전 칩.
class _AdvanceDayChips extends ConsumerWidget {
  const _AdvanceDayChips({required this.documentId, required this.reminder});

  final String documentId;
  final PaymentReminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(DocumentStrings.advance, style: AppTypography.fieldLabel),
        const SizedBox(height: AppSpacing.fieldLabelGap),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final days in PaymentReminder.advanceDayOptions)
              AppChip(
                label: DocumentStrings.advanceDay(days),
                isSelected: reminder.advanceDays.contains(days),
                onTap: () => ref
                    .read(reminderEditProvider(documentId).notifier)
                    .toggleAdvanceDay(days),
              ),
          ],
        ),
      ],
    );
  }
}

/// "매월 반복" 줄과 스위치.
class _MonthlyRepeatRow extends ConsumerWidget {
  const _MonthlyRepeatRow({required this.documentId, required this.isMonthly});

  final String documentId;
  final bool isMonthly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const Expanded(
          child: Text(DocumentStrings.monthlyRepeat, style: AppTypography.body),
        ),
        AppToggle(
          value: isMonthly,
          onChanged: (isOn) => ref
              .read(reminderEditProvider(documentId).notifier)
              .setMonthly(isMonthly: isOn),
        ),
      ],
    );
  }
}
