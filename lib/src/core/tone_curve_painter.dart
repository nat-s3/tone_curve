import 'package:flutter/material.dart';

import 'tone_curve_model.dart';
import 'tone_curve_style.dart';

/// This class is a custom painter for the tone curve.
class ToneCurvePainter extends CustomPainter {
  ToneCurvePainter({
    required this.model,
    required this.style,
    required this.scheme,
    this.holdAnchorIndex,
  });

  /// The model of the tone curve.
  final ToneCurveModel model;

  /// The style of the tone curve.
  final ToneCurveStyle style;

  /// The color scheme of the tone curve.
  final ColorScheme scheme;

  /// The index of the anchor that is being held.
  final int? holdAnchorIndex;

  @override
  void paint(Canvas canvas, Size size) {
    // init painters
    final backgroundPainter = Paint()
      ..color = style.backgroundColor ?? scheme.surface
      ..blendMode = BlendMode.srcOver;
    final linePainter = Paint()
      ..color = (style.gridColor ?? scheme.outline)
      ..blendMode = BlendMode.srcOver
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fillPainter = Paint()
      ..color = (style.curveFillColor ?? scheme.secondaryContainer)
      ..blendMode = BlendMode.srcOver
      ..style = PaintingStyle.fill;
    final curvePainter = Paint()
      ..color = (style.curveLineColor ?? scheme.primary)
      ..blendMode = BlendMode.srcOver
      ..strokeWidth = style.anchorRadius / 5
      ..style = PaintingStyle.stroke;
    final anchorPainter = Paint()
      ..color = (style.anchorColor ?? scheme.primary)
      ..blendMode = BlendMode.srcOver
      ..strokeWidth = style.anchorRadius / 3
      ..style = PaintingStyle.stroke;

    // Draw the background
    if (style.drawBackground) {
      canvas.drawRect(Offset.zero & size, backgroundPainter);
    }

    // Draw the Outer Frame
    canvas.drawRect(Offset.zero & size, linePainter);

    // Draw the sampled values
    final samplings = model.samplings
        .map(
          (e) => Offset(size.width * e.x, size.height * (1 - e.y)),
        )
        .toList();
    if (samplings.isNotEmpty) {
      final path = Path();
      final linePath = Path();
      for (var i = 0; i < samplings.length; i++) {
        if (i == 0) {
          path.moveTo(samplings[i].dx, samplings[i].dy);
          linePath.moveTo(samplings[i].dx, samplings[i].dy);
        } else {
          path.lineTo(samplings[i].dx, samplings[i].dy);
          linePath.lineTo(samplings[i].dx, samplings[i].dy);
        }
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      if (style.drawFillCurve) {
        canvas.drawPath(path, fillPainter);
      } else if (!style.drawLineCurve) {
        canvas.drawPath(linePath, curvePainter);
      }
      if (style.drawLineCurve) {
        canvas.drawPath(linePath, curvePainter);
      }
    }

    // Draw the grid lines
    if (style.drawGrid) {
      final loopCount = (style.subGridSplits % 2 == 0)
          ? style.subGridSplits + 1
          : style.subGridSplits;
      final halfCount = (loopCount - 1) ~/ 2;
      for (var i = 1; i < loopCount; i++) {
        final percent = i / (loopCount - 1);
        if (style.drawSubGrid || halfCount == i) {
          canvas
            ..drawLine(
              Offset(size.width * percent, 0),
              Offset(size.width * percent, size.height),
              linePainter,
            )
            ..drawLine(
              Offset(0, size.height * percent),
              Offset(size.width, size.height * percent),
              linePainter,
            );
        }
      }
    }

    // Draw the anchors
    for (final value in [...model.anchors].indexed) {
      if (value.$1 == holdAnchorIndex) {
        anchorPainter.color = (style.anchorHoldColor ?? scheme.inversePrimary);
      } else {
        anchorPainter.color = (style.anchorColor ?? scheme.primary);
      }

      canvas
        ..drawCircle(
          Offset(value.$2.x * size.width, (1 - value.$2.y) * size.height),
          style.anchorRadius,
          anchorPainter..style = PaintingStyle.stroke,
        )
        ..drawCircle(
          Offset(value.$2.x * size.width, (1 - value.$2.y) * size.height),
          style.anchorRadius / 5,
          anchorPainter..style = PaintingStyle.fill,
        );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
