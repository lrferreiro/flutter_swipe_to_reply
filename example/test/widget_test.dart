import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_swipe_to_reply_example/main.dart' as example;

void main() {
  testWidgets('selects an incoming message as the reply target', (
    tester,
  ) async {
    example.main();
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('message-1')),
      const Offset(100, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Replying to Avery'), findsOneWidget);
    expect(find.byKey(const ValueKey('reply-target-label')), findsOneWidget);
  });
}
