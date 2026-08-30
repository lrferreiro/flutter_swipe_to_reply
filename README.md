# flutter_swipe_to_reply

A lightweight Flutter widget that adds a familiar swipe-to-reply gesture to
any child. It works well for chat bubbles, message rows, comments, files, and
other horizontal reply interactions.

The package handles the gesture, movement, indicator, and haptic feedback. Your
app decides what replying means.

## Features

- Swipe any widget left or right.
- Trigger a callback after a configurable distance.
- Theme-aware default reply indicator using `Icons.reply`.
- Configurable indicator icon as a `Widget`.
- Optional custom indicator builder.
- Optional haptic feedback when the gesture crosses the trigger threshold.
- Haptic rearming after returning to the origin during the same drag.
- Release-based confirmation: crossing the threshold never invokes the action
  before the pointer is released.
- No app-specific dependencies.

## Installation

```yaml
dependencies:
  flutter_swipe_to_reply: ^0.2.0
```

Then import the package:

```dart
import 'package:flutter_swipe_to_reply/flutter_swipe_to_reply.dart';
```

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

For chat UIs, outgoing messages usually swipe left and incoming messages swipe
right.

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

Use `indicatorBuilder` when you want to provide your own animation, color,
size, or layout.

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
  hapticRearmDistance: 0,
  resetDuration: const Duration(milliseconds: 180),
  resetCurve: Curves.easeOutCubic,
  enableHapticFeedback: true,
  onReply: () {},
  child: child,
)
```

`triggerDistance` is the point at which the gesture becomes eligible. The
callback still runs only if the pointer is released while the drag remains at
or beyond that distance.

## Haptic rearming

Haptic feedback fires once when the active drag first reaches
`triggerDistance`. If the pointer returns to `hapticRearmDistance`, feedback is
armed again and a later threshold crossing produces another pulse without
ending the gesture.

The default `hapticRearmDistance` is `0`, so the user must return completely to
the starting point. A small positive value can provide additional tolerance:

```dart
SwipeToReply(
  triggerDistance: 56,
  hapticRearmDistance: 8,
  onReply: selectReplyTarget,
  child: messageBubble,
)
```

The rearm distance must be non-negative and smaller than
`triggerDistance`. Moving slightly below the trigger threshold does not rearm
feedback, which prevents repeated pulses caused by small pointer movements.

## Configuration

| Property | Default | Purpose |
| --- | --- | --- |
| `direction` | `right` | Allowed horizontal swipe direction. |
| `enabled` | `true` | Enables or disables gesture recognition. |
| `triggerDistance` | `54` | Distance required before release can reply. |
| `maxDragDistance` | `78` | Maximum visual displacement. |
| `enableHapticFeedback` | `true` | Emits a light pulse on armed crossings. |
| `hapticRearmDistance` | `0` | Distance that rearms haptic feedback. |
| `resetDuration` | `170ms` | Return animation duration. |
| `resetCurve` | `easeOutCubic` | Return animation curve. |
| `indicatorIcon` | `Icons.reply` | Widget used by the default indicator. |
| `indicatorBuilder` | `null` | Replaces the complete indicator. |

## Example

The repository includes a runnable conversation that demonstrates incoming
and outgoing directions, reply selection, a composer, and repeated haptic
threshold crossings:

```sh
cd example
flutter run
```

## Notes

This package does not mutate messages, send network requests, or manage reply
state. Keep those side effects in your app and use `onReply` to connect the
gesture to your own flow.
