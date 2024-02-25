import 'dart:ui';

/// This class represents the style of the tone curve.
class ToneCurveStyle {
  const ToneCurveStyle({
    this.backgroundColor,
    this.gridColor,
    this.curveLineColor,
    this.curveFillColor,
    this.anchorColor,
    this.anchorHoldColor,
    this.anchorRadius = 5,
    this.subGridSplits = 4,
    this.drawGrid = true,
    this.drawSubGrid = true,
    this.drawFillCurve = true,
    this.drawLineCurve = true,
    this.drawBackground = true,
  });

  /// The background color of the tone curve.
  final Color? backgroundColor;

  /// The color of the grid.
  final Color? gridColor;

  /// The color of the line of the curve.
  final Color? curveLineColor;

  /// The color of the fill of the curve.
  final Color? curveFillColor;

  /// The color of the anchor.
  final Color? anchorColor;

  /// The color of the anchor when it is being held.
  final Color? anchorHoldColor;

  /// The radius of the anchor.
  final double anchorRadius;

  /// The number of splits in the sub grid.
  final int subGridSplits;

  /// Whether to draw the grid.
  final bool drawGrid;

  /// Whether to draw the sub grid.
  final bool drawSubGrid;

  /// Whether to draw the fill of the curve.
  final bool drawFillCurve;

  /// Whether to draw the line of the curve.
  final bool drawLineCurve;

  /// Whether to draw the background.
  final bool drawBackground;
}
