import 'package:chagok_mobile/features/chat/data/chat_message.dart';
import 'package:chagok_mobile/features/chat/data/chat_role.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:chagok_mobile/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final at = DateTime(2026, 11, 19, 10);

  /// 말풍선 글에서 굵게 그린 부분만 모읍니다.
  List<String> boldParts(WidgetTester tester) {
    final text = tester.widget<Text>(
      find
          .descendant(of: find.byType(ChatBubble), matching: find.byType(Text))
          .first,
    );
    final span = text.textSpan;
    final spans = span is TextSpan
        ? span.children ?? const <InlineSpan>[]
        : const <InlineSpan>[];
    return [
      for (final span in spans.whereType<TextSpan>())
        if (span.style?.fontWeight == FontWeight.w700) span.text ?? '',
    ];
  }

  group('ChatBubble', () {
    testWidgets('내 질문에 **가 있으면 별표를 지우지 않고 글자 그대로 보여 준다', (tester) async {
      await tester.pumpApp(
        ChatBubble(
          message: ChatMessage(
            role: ChatRole.user,
            text: '**원문** 그대로인가요?',
            sentAt: at,
          ),
        ),
      );

      expect(find.text('**원문** 그대로인가요?'), findsOneWidget);
      expect(boldParts(tester), isEmpty);
    });

    testWidgets('차곡의 답에 **가 있으면 그 부분을 굵게 보여 준다', (tester) async {
      await tester.pumpApp(
        ChatBubble(
          message: ChatMessage(
            role: ChatRole.assistant,
            text: '매월 **25일**까지 내면 돼요.',
            sentAt: at,
          ),
        ),
      );

      expect(find.text('매월 25일까지 내면 돼요.'), findsOneWidget);
      expect(boldParts(tester), ['25일']);
    });

    testWidgets('원본을 열 서류가 없으면 근거만 보여 주고 원본 보기는 두지 않는다', (tester) async {
      await tester.pumpApp(
        ChatBubble(
          message: ChatMessage(
            role: ChatRole.assistant,
            text: '매월 25일까지 내면 돼요.',
            sentAt: at,
            source: '계약서 1페이지',
          ),
        ),
      );

      expect(find.text(ChatStrings.source('계약서 1페이지')), findsOneWidget);
      expect(find.text(ChatStrings.viewOriginal), findsNothing);
    });

    testWidgets('원본을 열 수 있으면 원본 보기를 누를 때 알린다', (tester) async {
      var openCount = 0;
      await tester.pumpApp(
        ChatBubble(
          message: ChatMessage(
            role: ChatRole.assistant,
            text: '매월 25일까지 내면 돼요.',
            sentAt: at,
            source: '계약서 1페이지',
          ),
          onViewOriginal: () => openCount++,
        ),
      );

      await tester.tap(find.text(ChatStrings.viewOriginal));

      expect(openCount, 1);
    });
  });
}
