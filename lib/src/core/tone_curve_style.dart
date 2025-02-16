import 'dart:ui';

/// This class represents the style of the tone curve.
class ToneCurveStyle {
  const ToneCurveStyle({
    this.backgroundColor = const Color(0x00000000),
    this.gridColor = const Color(0xFF878787),
    this.curveLineColor = const Color(0xFF787878),
    this.curveFillColor = const Color(0xFF787878),
    this.anchorColor = const Color(0xFF878787),
    this.anchorHoldColor = const Color(0xFF878787),
    this.anchorRadius = 5,
    this.subGridSplits = 4,
    this.drawGrid = true,
    this.drawSubGrid = true,
    this.drawFillCurve = true,
    this.drawLineCurve = true,
    this.drawBackground = true,
    this.useAnchorOutline = true,
  });

  /// The background color of the tone curve.
  final Color backgroundColor;

  /// The color of the grid.
  final Color gridColor;

  /// The color of the line of the curve.
  final Color curveLineColor;

  /// The color of the fill of the curve.
  final Color curveFillColor;

  /// The color of the anchor.
  final Color anchorColor;

  /// The color of the anchor when it is being held.
  final Color anchorHoldColor;

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

  /// Whether to use anchor outline.
  final bool useAnchorOutline;

  /// Creates a copy of this object but with the given fields replaced with the new values.
  ToneCurveStyle copyWith({
    Color? backgroundColor,
    Color? gridColor,
    Color? curveLineColor,
    Color? curveFillColor,
    Color? anchorColor,
    Color? anchorHoldColor,
    double? anchorRadius,
    int? subGridSplits,
    bool? drawGrid,
    bool? drawSubGrid,
    bool? drawFillCurve,
    bool? drawLineCurve,
    bool? drawBackground,
    bool? useAnchorOutline,
  }) {
    return ToneCurveStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gridColor: gridColor ?? this.gridColor,
      curveLineColor: curveLineColor ?? this.curveLineColor,
      curveFillColor: curveFillColor ?? this.curveFillColor,
      anchorColor: anchorColor ?? this.anchorColor,
      anchorHoldColor: anchorHoldColor ?? this.anchorHoldColor,
      anchorRadius: anchorRadius ?? this.anchorRadius,
      subGridSplits: subGridSplits ?? this.subGridSplits,
      drawGrid: drawGrid ?? this.drawGrid,
      drawSubGrid: drawSubGrid ?? this.drawSubGrid,
      drawFillCurve: drawFillCurve ?? this.drawFillCurve,
      drawLineCurve: drawLineCurve ?? this.drawLineCurve,
      drawBackground: drawBackground ?? this.drawBackground,
      useAnchorOutline: useAnchorOutline ?? this.useAnchorOutline,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ToneCurveStyle &&
            backgroundColor == other.backgroundColor &&
            gridColor == other.gridColor &&
            curveLineColor == other.curveLineColor &&
            curveFillColor == other.curveFillColor &&
            anchorColor == other.anchorColor &&
            anchorHoldColor == other.anchorHoldColor &&
            anchorRadius == other.anchorRadius &&
            subGridSplits == other.subGridSplits &&
            drawGrid == other.drawGrid &&
            drawSubGrid == other.drawSubGrid &&
            drawFillCurve == other.drawFillCurve &&
            drawLineCurve == other.drawLineCurve &&
            drawBackground == other.drawBackground &&
            useAnchorOutline == other.useAnchorOutline;
  }

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    gridColor,
    curveLineColor,
    curveFillColor,
    anchorColor,
    anchorHoldColor,
    anchorRadius,
    subGridSplits,
    drawGrid,
    drawSubGrid,
    drawFillCurve,
    drawLineCurve,
    drawBackground,
    useAnchorOutline,
  );
}
