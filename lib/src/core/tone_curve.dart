import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'normalized_point.dart';
import 'tone_curve_model.dart';
import 'tone_curve_painter.dart';
import 'tone_curve_style.dart';

/// This class represents a tone curve widget that can be used to display and interact with a tone curve.
///
/// Example:
/// ```dart
/// ToneCurve(
///   model: myToneCurveModel,
///   style: ToneCurveStyle(),
///   onUpdated: (values) {
///     // Handle updated tone curve values
///   },
/// )
/// ```
class ToneCurve extends StatefulWidget {
  const ToneCurve({
    super.key,
    required this.model,
    this.style = const ToneCurveStyle(),
    this.onUpdated,
    this.scheme,
  });

  /// The style of the tone curve.
  final ToneCurveStyle style;

  /// The model of the tone curve.
  final ToneCurveModel model;

  /// A callback that is called when the tone curve is updated.
  final void Function(List<double>)? onUpdated;

  /// The color scheme of the tone curve.
  final ColorScheme? scheme;

  @override
  State<ToneCurve> createState() => _ToneCurveState();
}

/// The state of the tone curve widget.
class _ToneCurveState extends State<ToneCurve> {
  /// The index of the anchor that is being moved.
  final moveTarget = ValueNotifier<int?>(null);

  void notifyUpdate() {
    widget.onUpdated?.call(
      widget.model.samplings.yList(),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.model.addListener(notifyUpdate);
  }

  @override
  void dispose() {
    widget.model.removeListener(notifyUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.scheme ?? Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, layout) {
        // Calculate layout sizes
        final paddingSize =
            widget.style.anchorRadius + widget.style.anchorRadius / 6;
        final layoutSize = min(layout.maxWidth, layout.maxHeight);
        final size = layoutSize - paddingSize * 2;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanEnd: (d) => moveTarget.value = null,
          onPanCancel: () => moveTarget.value = null,
          onPanDown: (detail) => onPanDown(detail, paddingSize, size),
          onPanUpdate: (detail) => onPanUpdate(detail, paddingSize, size),
          child: RepaintBoundary(
            child: Padding(
              padding: EdgeInsets.all(paddingSize),
              child: ValueListenableBuilder(
                valueListenable: moveTarget,
                builder: (context, value, child) {
                  return ListenableBuilder(
                    listenable: widget.model,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ToneCurvePainter(
                          model: widget.model,
                          style: widget.style,
                          scheme: colorScheme,
                          holdAnchorIndex: value,
                        ),
                        size: Size.square(size),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Handle the pan down event.
  void onPanDown(DragDownDetails detail, double paddingSize, double size) {
    /// Get the anchor that was tapped.
    final anchors = widget.model.anchors;
    final vectors = <int, double>{};
    final current = NormalizedPoint.clamp(
      x: (detail.localPosition.dx - paddingSize) / size,
      y: 1 - ((detail.localPosition.dy - paddingSize) / size),
    );
    final normalizedAnchorSize = widget.style.anchorRadius / size;
    for (final (idx, target) in anchors.indexed) {
      final distance = (current - target).distance;

      if (distance < normalizedAnchorSize) {
        moveTarget.value = idx;
      }
      vectors[idx] = target.x;
    }

    // Add data if the anchor is not being moved.
    if (moveTarget.value == null) {
      int key = 0;
      for (final kv in vectors.entries) {
        if (kv.value < min(current.x, 1.0)) {
          key = kv.key;
        } else {
          break;
        }
      }

      final newAnchors = [...widget.model.anchors]..insert(
          key + 1,
          current,
        );
      moveTarget.value = key + 1;
      widget.model.update(anchors: newAnchors);
      widget.onUpdated?.call(
        widget.model.samplings.yList(),
      );
    }
  }

  /// Handle the pan up event.
  void onPanUpdate(DragUpdateDetails detail, double paddingSize, double size) {
    {
      // Get the current position of the anchor.
      final current = NormalizedPoint.clamp(
        x: (detail.localPosition.dx - paddingSize) / size,
        y: 1.0 - ((detail.localPosition.dy - paddingSize) / size),
      );
      var currentTarget = moveTarget.value;

      if (currentTarget == null) {
        return;
      }

      // Synthesize values
      final minList = max(0, currentTarget - 1);
      final anchors = [...widget.model.anchors];
      final normalizedRadius = widget.style.anchorRadius / size;
      if (2 < anchors.length && minList != currentTarget) {
        final distance = (current - anchors[minList]).distance;
        if (distance <= normalizedRadius) {
          moveTarget.value = minList;
          anchors.removeAt(currentTarget);
          currentTarget = minList;
        }
      }
      final maxList = min(currentTarget + 1, anchors.length - 1);
      if (2 < anchors.length && maxList != currentTarget) {
        final distance = (anchors[maxList] - current).distance;
        if (distance <= normalizedRadius) {
          anchors.removeAt(currentTarget);
        }
      }

      // Update the value
      if (currentTarget == 0) {
        anchors[currentTarget] = NormalizedPoint(x: 0, y: current.y);
      } else if (currentTarget + 1 == anchors.length) {
        anchors[currentTarget] = NormalizedPoint(x: 1, y: current.y);
      } else {
        anchors[currentTarget] = NormalizedPoint(
          x: clampDouble(
            current.x,
            anchors[max(currentTarget - 1, 0)].x,
            anchors[min(currentTarget + 1, anchors.length - 1)].x,
          ),
          y: current.y,
        );
      }
      widget.model.update(anchors: anchors);
    }
  }
}
