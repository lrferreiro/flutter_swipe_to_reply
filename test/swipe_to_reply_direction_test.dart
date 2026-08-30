import 'package:flutter_swipe_to_reply/flutter_swipe_to_reply.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SwipeToReplyDirection.fromValue maps known values', () {
    expect(SwipeToReplyDirection.fromValue('left'), SwipeToReplyDirection.left);
    expect(
      SwipeToReplyDirection.fromValue('right'),
      SwipeToReplyDirection.right,
    );
  });

  test('SwipeToReplyDirection.fromValue falls back safely', () {
    expect(SwipeToReplyDirection.fromValue(null), SwipeToReplyDirection.right);
    expect(
      SwipeToReplyDirection.fromValue('unknown'),
      SwipeToReplyDirection.right,
    );
  });

  testWidgets('SwipeToReply renders a custom indicator icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwipeToReply(
            indicatorIcon: const Icon(Icons.reply_all),
            onReply: () {},
            child: const Text('Message'),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.reply_all), findsOneWidget);
    expect(find.byIcon(Icons.reply), findsNothing);
  });

  testWidgets('haptic feedback rearms at the origin during the same drag', (
    tester,
  ) async {
    final hapticCalls = <MethodCall>[];
    var replyCount = 0;

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') hapticCalls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SwipeToReply(
              triggerDistance: 50,
              maxDragDistance: 80,
              onReply: () => replyCount++,
              child: const SizedBox(
                key: Key('message'),
                width: 200,
                height: 80,
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('message'))),
    );
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();

    expect(hapticCalls, hasLength(1));
    expect(replyCount, 0);

    await gesture.moveBy(const Offset(-60, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();

    expect(hapticCalls, hasLength(2));
    expect(replyCount, 0);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(replyCount, 1);
  });

  testWidgets('haptic feedback does not rearm near the trigger threshold', (
    tester,
  ) async {
    final hapticCalls = <MethodCall>[];

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') hapticCalls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SwipeToReply(
              triggerDistance: 50,
              maxDragDistance: 80,
              onReply: () {},
              child: const SizedBox(
                key: Key('message'),
                width: 200,
                height: 80,
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('message'))),
    );
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(-20, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();

    expect(hapticCalls, hasLength(1));

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
