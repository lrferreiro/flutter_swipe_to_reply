import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../enums/swipe_to_reply_direction.dart';

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
/// the child, shows an indicator, and calls [onReply] once the gesture crosses
/// [triggerDistance].
class SwipeToReply extends StatefulWidget {
  final Widget child;
  final SwipeToReplyDirection direction;
  final bool enabled;
  final double triggerDistance;
  final double maxDragDistance;
  final VoidCallback onReply;
  final bool enableHapticFeedback;
  final Duration resetDuration;
  final Curve resetCurve;
  final double indicatorSize;
  final EdgeInsetsGeometry indicatorMargin;
  final Color? indicatorBackgroundColor;
  final Widget indicatorIcon;
  final SwipeToReplyIndicatorBuilder? indicatorBuilder;

  const SwipeToReply({
    super.key,
    required this.child,
    required this.onReply,
    this.direction = SwipeToReplyDirection.right,
    this.enabled = true,
    this.triggerDistance = 54,
    this.maxDragDistance = 78,
    this.enableHapticFeedback = true,
    this.resetDuration = const Duration(milliseconds: 170),
    this.resetCurve = Curves.easeOutCubic,
    this.indicatorSize = 34,
    this.indicatorMargin = const EdgeInsets.symmetric(horizontal: 22),
    this.indicatorBackgroundColor,
    this.indicatorIcon = const Icon(Icons.reply),
    this.indicatorBuilder,
  });

  @override
  State<SwipeToReply> createState() => SwipeToReplyState();
}

class SwipeToReplyState extends State<SwipeToReply> {
  double dragDistance = 0;
  bool didTriggerHaptic = false;
  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    final offset = dragDistance * widget.direction.multiplier;
    final progress = (dragDistance / widget.triggerDistance).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: widget.enabled ? handleDragStart : null,
      onHorizontalDragUpdate: widget.enabled ? handleDragUpdate : null,
      onHorizontalDragEnd: widget.enabled ? handleDragEnd : null,
      onHorizontalDragCancel: widget.enabled ? resetDrag : null,
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
            duration: dragging ? Duration.zero : widget.resetDuration,
            curve: widget.resetCurve,
            transform: Matrix4.translationValues(offset, 0, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  void handleDragStart(DragStartDetails details) {
    dragging = true;
    didTriggerHaptic = false;
  }

  void handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final directionalDelta = delta * widget.direction.multiplier;
    final nextDistance = (dragDistance + directionalDelta).clamp(
      0.0,
      widget.maxDragDistance,
    );

    if (nextDistance == dragDistance) return;

    setState(() => dragDistance = nextDistance);

    if (!didTriggerHaptic && dragDistance >= widget.triggerDistance) {
      didTriggerHaptic = true;
      if (widget.enableHapticFeedback) HapticFeedback.lightImpact();
    }
  }

  void handleDragEnd(DragEndDetails details) {
    final shouldReply = dragDistance >= widget.triggerDistance;
    resetDrag();

    if (shouldReply) widget.onReply();
  }

  void resetDrag() {
    if (!mounted) return;

    setState(() {
      dragging = false;
      dragDistance = 0;
      didTriggerHaptic = false;
    });
  }
}

class SwipeToReplyIndicator extends StatelessWidget {
  final double progress;
  final double size;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
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
