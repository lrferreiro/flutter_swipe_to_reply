import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../enums/swipe_to_reply_direction.dart';

/// Builds the indicator displayed behind the swiped child.
///
/// [progress] is clamped between `0` and `1`, while [direction] identifies the
/// edge from which the indicator is revealed.
typedef SwipeToReplyIndicatorBuilder =
    Widget Function(
      BuildContext context,
      double progress,
      SwipeToReplyDirection direction,
    );

/// Adds a horizontal swipe-to-reply gesture to any child widget.
///
/// The widget is intentionally generic: it does not know about chats,
/// conversations, messages, or backends. It only exposes the gesture, animates
/// the child, shows an indicator, and calls [onReply] when the gesture is
/// released after crossing [triggerDistance].
class SwipeToReply extends StatefulWidget {
  /// The widget that responds to the horizontal swipe gesture.
  final Widget child;

  /// The horizontal direction in which [child] can be swiped.
  final SwipeToReplyDirection direction;

  /// Whether the swipe gesture is enabled.
  final bool enabled;

  /// The distance that must be reached before a release triggers [onReply].
  final double triggerDistance;

  /// The maximum distance through which [child] can be dragged.
  final double maxDragDistance;

  /// Called after the pointer is released beyond [triggerDistance].
  final VoidCallback onReply;

  /// Whether to emit light haptic feedback on each armed threshold crossing.
  final bool enableHapticFeedback;

  /// Distance from the origin at which haptic feedback is armed again.
  ///
  /// After feedback has fired, moving back to this distance and crossing
  /// [triggerDistance] again emits another haptic pulse without ending the
  /// gesture. The default requires returning completely to the origin.
  final double hapticRearmDistance;

  /// Duration of the animation that returns [child] to its resting position.
  final Duration resetDuration;

  /// Curve of the animation that returns [child] to its resting position.
  final Curve resetCurve;

  /// Diameter of the default circular indicator.
  final double indicatorSize;

  /// Margin around the default indicator.
  final EdgeInsetsGeometry indicatorMargin;

  /// Background color of the default indicator.
  ///
  /// When omitted, the current theme's surface container color is used.
  final Color? indicatorBackgroundColor;

  /// Icon displayed by the default indicator.
  final Widget indicatorIcon;

  /// Optional builder that replaces the default indicator.
  final SwipeToReplyIndicatorBuilder? indicatorBuilder;

  /// Creates a horizontal swipe-to-reply interaction around [child].
  const SwipeToReply({
    super.key,
    required this.child,
    required this.onReply,
    this.direction = SwipeToReplyDirection.right,
    this.enabled = true,
    this.triggerDistance = 54,
    this.maxDragDistance = 78,
    this.enableHapticFeedback = true,
    this.hapticRearmDistance = 0,
    this.resetDuration = const Duration(milliseconds: 170),
    this.resetCurve = Curves.easeOutCubic,
    this.indicatorSize = 34,
    this.indicatorMargin = const EdgeInsets.symmetric(horizontal: 22),
    this.indicatorBackgroundColor,
    this.indicatorIcon = const Icon(Icons.reply),
    this.indicatorBuilder,
  }) : assert(triggerDistance > 0),
       assert(maxDragDistance >= triggerDistance),
       assert(hapticRearmDistance >= 0),
       assert(hapticRearmDistance < triggerDistance),
       assert(indicatorSize > 0);

  @override
  State<SwipeToReply> createState() => SwipeToReplyState();
}

/// State maintained by [SwipeToReply] while a pointer gesture is active.
class SwipeToReplyState extends State<SwipeToReply> {
  double _dragDistance = 0;
  bool _didTriggerHaptic = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final offset = _dragDistance * widget.direction.multiplier;
    final progress = (_dragDistance / widget.triggerDistance).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: widget.enabled ? _handleDragStart : null,
      onHorizontalDragUpdate: widget.enabled ? _handleDragUpdate : null,
      onHorizontalDragEnd: widget.enabled ? _handleDragEnd : null,
      onHorizontalDragCancel: widget.enabled ? _resetDrag : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: widget.direction == SwipeToReplyDirection.left
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child:
                    widget.indicatorBuilder?.call(
                      context,
                      progress,
                      widget.direction,
                    ) ??
                    SwipeToReplyIndicator(
                      progress: progress,
                      size: widget.indicatorSize,
                      margin: widget.indicatorMargin,
                      backgroundColor: widget.indicatorBackgroundColor,
                      icon: widget.indicatorIcon,
                    ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: _dragging ? Duration.zero : widget.resetDuration,
            curve: widget.resetCurve,
            transform: Matrix4.translationValues(offset, 0, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  void _handleDragStart(DragStartDetails details) {
    _dragging = true;
    _didTriggerHaptic = false;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final directionalDelta = delta * widget.direction.multiplier;
    final nextDistance = (_dragDistance + directionalDelta).clamp(
      0.0,
      widget.maxDragDistance,
    );

    if (nextDistance == _dragDistance) return;

    setState(() => _dragDistance = nextDistance);

    if (_didTriggerHaptic && _dragDistance <= widget.hapticRearmDistance) {
      _didTriggerHaptic = false;
    }

    if (!_didTriggerHaptic && _dragDistance >= widget.triggerDistance) {
      _didTriggerHaptic = true;
      if (widget.enableHapticFeedback) HapticFeedback.lightImpact();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    final shouldReply = _dragDistance >= widget.triggerDistance;
    _resetDrag();

    if (shouldReply) widget.onReply();
  }

  void _resetDrag() {
    if (!mounted) return;

    setState(() {
      _dragging = false;
      _dragDistance = 0;
      _didTriggerHaptic = false;
    });
  }
}

/// The default circular, theme-aware indicator used by [SwipeToReply].
class SwipeToReplyIndicator extends StatelessWidget {
  /// Reveal progress between `0` and `1`.
  final double progress;

  /// Diameter of the circular indicator.
  final double size;

  /// Space around the indicator.
  final EdgeInsetsGeometry margin;

  /// Fill color, or `null` to use the current theme.
  final Color? backgroundColor;

  /// Widget displayed in the center of the indicator.
  final Widget icon;

  /// Default theme-aware reply indicator used by [SwipeToReply].
  ///
  /// The icon is a widget so apps can use their own icon system, SVGs, colors,
  /// inherited [IconTheme], or custom animations without the package knowing
  /// about those decisions.
  const SwipeToReplyIndicator({
    super.key,
    required this.progress,
    required this.size,
    required this.margin,
    required this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackground =
        backgroundColor ?? colorScheme.surfaceContainerHighest;

    return Opacity(
      opacity: progress,
      child: Transform.scale(
        scale: lerpDouble(0.82, 1, progress) ?? 1,
        child: Container(
          width: size,
          height: size,
          margin: margin,
          decoration: BoxDecoration(
            color: effectiveBackground,
            shape: BoxShape.circle,
          ),
          child: IconTheme.merge(
            data: IconThemeData(size: size * 0.55),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}
