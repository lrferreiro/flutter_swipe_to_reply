/// Horizontal direction used by [SwipeToReply].
///
/// `right` is commonly used for incoming chat messages, while `left` is
/// commonly used for outgoing chat messages.
enum SwipeToReplyDirection {
  /// Allows the child to be dragged toward the right.
  right('right', 1),

  /// Allows the child to be dragged toward the left.
  left('left', -1);

  /// Stable string representation of the direction.
  final String value;

  /// Multiplier used to normalize horizontal drag deltas.
  final int multiplier;

  /// Creates a direction with its serialized [value] and drag [multiplier].
  const SwipeToReplyDirection(this.value, this.multiplier);

  /// Parses [value], falling back to [right] when it is unknown or `null`.
  factory SwipeToReplyDirection.fromValue(String? value) {
    return SwipeToReplyDirection.values.firstWhere(
      (direction) => direction.value == value,
      orElse: () => right,
    );
  }
}
