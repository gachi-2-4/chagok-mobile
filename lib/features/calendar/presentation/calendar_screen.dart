import 'dart:async';

import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_option_sheet.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_clock.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_dates.dart';
import 'package:chagok_mobile/features/calendar/application/calendar_view_notifier.dart';
import 'package:chagok_mobile/features/calendar/application/deadline_list_notifier.dart';
import 'package:chagok_mobile/features/calendar/data/deadline.dart';
import 'package:chagok_mobile/features/calendar/presentation/calendar_strings.dart';
import 'package:chagok_mobile/features/calendar/presentation/widgets/deadline_tile.dart';
import 'package:chagok_mobile/features/calendar/presentation/widgets/month_calendar_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// C01·C02 · 캘린더 탭 첫 화면.
///
/// 한 달 달력에 서류 기한을 점으로 보여 주고, 아래에 다가오는 기한을 늘어놓습니다.
/// 날짜를 고르면 그날 기한만 보여 줍니다.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.xl,
            AppSpacing.screenHorizontal,
            AppSpacing.xl,
          ),
          children: [
            const Text(CalendarStrings.title, style: AppTypography.pageTitle),
            const SizedBox(height: AppSpacing.block),
            ref
                .watch(deadlineListProvider)
                .when(
                  data: (deadlines) => _CalendarContent(deadlines: deadlines),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => Column(
                    children: [
                      const Text(
                        CalendarStrings.loadFailed,
                        style: AppTypography.body,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton.secondary(
                        label: CalendarStrings.retry,
                        onPressed: () => ref.invalidate(deadlineListProvider),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// 불러온 [deadlines]로 그린 달력 카드와 기한 목록.
class _CalendarContent extends ConsumerWidget {
  const _CalendarContent({required this.deadlines});

  final List<Deadline> deadlines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(calendarViewProvider);
    final today = CalendarDates.dateOnly(ref.watch(calendarClockProvider)());
    CalendarViewNotifier viewNotifier() =>
        ref.read(calendarViewProvider.notifier);

    Future<void> pickYear() async {
      final year = await showAppOptionSheet(
        context,
        options: CalendarDates.selectableYears(today),
        labelOf: CalendarStrings.year,
        selected: view.month.year,
      );
      if (year == null || !context.mounted) return;
      viewNotifier().showMonth(year: year, month: view.month.month);
    }

    Future<void> pickMonth() async {
      final month = await showAppOptionSheet(
        context,
        options: CalendarDates.selectableMonths,
        labelOf: CalendarStrings.month,
        selected: view.month.month,
      );
      if (month == null || !context.mounted) return;
      viewNotifier().showMonth(year: view.month.year, month: month);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonthCalendarCard(
          month: view.month,
          today: today,
          selectedDate: view.selectedDate,
          marks: CalendarDates.markedDaysOf(deadlines, view.month),
          onSelect: (date) => viewNotifier().select(date),
          onPrevious: () => viewNotifier().showPreviousMonth(),
          onNext: () => viewNotifier().showNextMonth(),
          onPickYear: () => unawaited(pickYear()),
          onPickMonth: () => unawaited(pickMonth()),
        ),
        const SizedBox(height: AppSpacing.xl),
        _DeadlineSection(
          deadlines: deadlines,
          today: today,
          selectedDate: view.selectedDate,
        ),
      ],
    );
  }
}

/// "다가오는 기한" 또는 고른 날짜의 기한 목록.
class _DeadlineSection extends ConsumerWidget {
  const _DeadlineSection({
    required this.deadlines,
    required this.today,
    required this.selectedDate,
  });

  final List<Deadline> deadlines;
  final DateTime today;
  final DateTime? selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = this.selectedDate;
    final shown = selectedDate == null
        ? CalendarDates.upcoming(deadlines, today)
        : CalendarDates.on(deadlines, selectedDate);

    Future<void> toggle(Deadline deadline) async {
      final isSaved = await ref
          .read(deadlineListProvider.notifier)
          .setRegistered(deadline.id, isRegistered: !deadline.isRegistered);
      if (isSaved || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(CalendarStrings.updateFailed)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          selectedDate: selectedDate,
          onViewAll: () =>
              ref.read(calendarViewProvider.notifier).clearSelection(),
        ),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              selectedDate == null
                  ? CalendarStrings.noUpcoming
                  : CalendarStrings.noDeadlineOnDate,
              style: AppTypography.listSubtitle,
            ),
          ),
        for (final deadline in shown)
          DeadlineTile(
            deadline: deadline,
            daysLeft: CalendarDates.daysUntil(today, deadline.dueDate),
            onToggleRegistered: () => unawaited(toggle(deadline)),
          ),
      ],
    );
  }
}

/// 목록 제목. 날짜를 골랐으면 그 날짜와 "전체 보기"를 보여 줍니다.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.selectedDate, required this.onViewAll});

  final DateTime? selectedDate;
  final VoidCallback onViewAll;

  static const _linkMinHeight = 32.0;

  @override
  Widget build(BuildContext context) {
    final selectedDate = this.selectedDate;
    if (selectedDate == null) {
      return const Text(
        CalendarStrings.upcoming,
        style: AppTypography.sectionTitle,
      );
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            CalendarStrings.date(selectedDate),
            style: AppTypography.sectionTitle,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.logo,
            textStyle: AppTypography.fieldLabel,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, _linkMinHeight),
          ),
          child: const Text(CalendarStrings.viewAll),
        ),
      ],
    );
  }
}
