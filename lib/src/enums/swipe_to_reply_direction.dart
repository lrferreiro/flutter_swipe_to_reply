/// Horizontal direction used by [SwipeToReply].
///
/// `right` is commonly used for incoming chat messages, while `left` is
/// commonly used for outgoing chat messages.
enum SwipeToReplyDirection {
  right('right', 1),
  left('left', -1);

  final String value;
  final int multiplier;

  const SwipeToReplyDirection(this.value, this.multiplier);

  factory SwipeToReplyDirection.fromValue(String? value) {
    return SwipeToReplyDirection.values.firstWhere(
      (direction) => direction.value == value,
      orElse: () => right,
    );
  }
}
