## 0.2.0

- Rearmed haptic feedback when an active swipe returns to the origin, allowing
  another pulse on a later threshold crossing without lifting the pointer.
- Added `hapticRearmDistance` to customize where feedback becomes armed again.
- Kept reply confirmation release-based, even when the haptic threshold is
  crossed multiple times during one gesture.
- Added focused gesture and haptic channel tests.
- Added a complete runnable conversation example.
- Expanded Dart API documentation and enabled the `public_member_api_docs` lint.
- Added repository, issue tracker, and pub.dev topics metadata.

## 0.1.0

- Initial release.
- Added a reusable `SwipeToReply` widget for horizontal reply gestures.
- Added configurable swipe direction, distances, curve, duration, haptic feedback, and indicator.
- Added a default Material reply indicator with configurable widget icon.
- Added tests for swipe direction value mapping.
