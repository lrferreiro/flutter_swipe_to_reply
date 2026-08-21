import 'package:flutter_swipe_to_reply/flutter_swipe_to_reply.dart';
import 'package:flutter/material.dart';
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
}
