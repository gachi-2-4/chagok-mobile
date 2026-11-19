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
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';
import 'package:chagok_mobile/features/document/presentation/document_strings.dart';
import 'package:chagok_mobile/features/document/presentation/widgets/option_sheet.dart';
import 'package:chagok_mobile/features/document/presentation/widgets/picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// D02 · 서류의 납부일 알림을 거는 화면.
class PaymentReminderScreen extends ConsumerWidget {
  const PaymentReminderScreen({required this.documentId, super.key});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = reminderEditProvider(documentId);
    final value = ref.watch(provider);

    return value.when(
      data: (state) =>
          _ReminderBody(state: state, notifier: ref.read(provider.notifier)),
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

class _ReminderBody extends StatelessWidget {
  const _ReminderBody({required this.state, required this.notifier});

  final ReminderEditState state;
  final ReminderEditNotifier notifier;

  static const _gap = 18.0;

  @override
  Widget build(BuildContext context) {
    final reminder = state.reminder;
    final detail = state.detail;
    final nextAlert = ReminderSchedule.nextAlert(reminder, DateTime.now());

    Future<void> pickPaymentDay() async {
      final day = await showOptionSheet(
        context,
        options: [for (var day = 1; day <= 31; day++) day],
        labelOf: DocumentStrings.monthlyDay,
        selected: reminder.paymentDay,
      );
      if (day != null) notifier.setPaymentDay(day);
    }

    Future<void> pickTime() async {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: reminder.minuteOfDay ~/ 60,
          minute: reminder.minuteOfDay % 60,
        ),
      );
      if (time != null) notifier.setTime(hour: time.hour, minute: time.minute);
    }

    Future<void> save() async {
      final isSaved = await notifier.save();
      if (!isSaved || !context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(DocumentStrings.registered)));
      Navigator.maybePop(context);
    }

    return AppDocumentLayout(
      body: [
        const Text(
          DocumentStrings.reminderTitle,
          style: AppTypography.pageTitle,
        ),
        const SizedBox(height: _gap),
        AppCard.green(
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
              const SizedBox(height: 10),
              Text(
                DocumentStrings.documentPath(
                  detail.boxName,
                  detail.documentType,
                ),
                style: AppTypography.pageDescription,
              ),
            ],
          ),
        ),
        const SizedBox(height: _gap),
        PickerField(
          label: DocumentStrings.paymentDay,
          value: DocumentStrings.monthlyDay(reminder.paymentDay),
          onTap: pickPaymentDay,
        ),
        const SizedBox(height: _gap),
        PickerField(
          label: DocumentStrings.reminderTime,
          value: DocumentStrings.time(reminder.minuteOfDay),
          onTap: pickTime,
        ),
        const SizedBox(height: _gap),
        const Text(DocumentStrings.advance, style: AppTypography.fieldLabel),
        const SizedBox(height: 9),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final days in PaymentReminder.advanceDayOptions)
              AppChip(
                label: DocumentStrings.advanceDay(days),
                isSelected: reminder.advanceDays.contains(days),
                onTap: () => notifier.toggleAdvanceDay(days),
              ),
          ],
        ),
        const SizedBox(height: _gap),
        Row(
          children: [
            const Expanded(
              child: Text(
                DocumentStrings.monthlyRepeat,
                style: AppTypography.body,
              ),
            ),
            AppToggle(
              value: reminder.isMonthly,
              onChanged: (isOn) => notifier.setMonthly(isMonthly: isOn),
            ),
          ],
        ),
        const SizedBox(height: _gap),
        AppBanner(
          child: Text(
            nextAlert == null
                ? DocumentStrings.noAdvanceSelected
                : '${DocumentStrings.nextAlert(nextAlert)}\n'
                      '${DocumentStrings.deviceNotice}',
          ),
        ),
      ],
      actions: [
        AppButton.primary(
          label: DocumentStrings.register,
          onPressed: state.canSave ? save : null,
        ),
      ],
    );
  }
}
