# flutter_swipe_to_reply

A lightweight Flutter widget that adds a familiar swipe-to-reply gesture to any child.
It works well for chat bubbles, message rows, comments, cards, files, and any UI where a horizontal drag should trigger a reply-like action.

The package only handles the gesture and visual feedback. Your app decides what “reply” means.

## Features

- Swipe any widget left or right.
- Trigger a callback after a configurable distance.
- Theme-aware default reply indicator using `Icons.reply`.
- Configurable indicator icon as a `Widget`.
- Optional custom indicator builder.
- Optional haptic feedback when the gesture crosses the trigger threshold.
- No app-specific dependencies.

## Basic usage

```dart
SwipeToReply(
  direction: SwipeToReplyDirection.right,
  onReply: () {
    // Select the item as the reply target.
  },
  child: messageBubble,
)
```

## Outgoing and incoming messages

For chat UIs, outgoing messages usually swipe left and incoming messages swipe right.

```dart
SwipeToReply(
  direction: isMine
      ? SwipeToReplyDirection.left
      : SwipeToReplyDirection.right,
  onReply: () => setReplyTarget(message),
  child: messageBubble,
)
```

## Custom indicator

Use `indicatorIcon` when you only need to replace the icon.

```dart
SwipeToReply(
  indicatorIcon: const Icon(Icons.reply_all),
  onReply: () {},
  child: child,
)
```

Use `indicatorBuilder` when you want to provide your own animation, color, size, or layout.

```dart
SwipeToReply(
  direction: SwipeToReplyDirection.left,
  indicatorBuilder: (context, progress, direction) {
    return Opacity(
      opacity: progress,
      child: const Icon(Icons.reply),
    );
  },
  onReply: () {},
  child: child,
)
```

## Tuning the gesture

```dart
SwipeToReply(
  triggerDistance: 56,
  maxDragDistance: 84,
  resetDuration: const Duration(milliseconds: 180),
  resetCurve: Curves.easeOutCubic,
  enableHapticFeedback: true,
  onReply: () {},
  child: child,
)
```

## Notes

This package does not mutate messages, send network requests, or manage reply state.
Keep those side effects in your app and use `onReply` to connect the gesture to your own flow.
