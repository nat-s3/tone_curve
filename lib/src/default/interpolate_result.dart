/// Interpolation result
class InterpolateResult {
  /// Output result;
  List<double> outputY;

  /// Interpolated curve X coordinate
  List<double> outCX;

  /// Normalized interpolated curve Y coordinate
  List<double> outCY;

  /// Normalized anchor X coordinate
  List<double> anchorX;

  /// Normalized anchor Y coordinate
  List<double> anchorY;

  /// Normalized control point 1 X coordinate
  List<double> cp1NX;

  /// Normalized control point 1 Y coordinate
  List<double> cp1NY;

  /// Normalized control point 2 X coordinate
  List<double> cp2NX;

  /// Normalized control point 2 Y coordinate
  List<double> cp2NY;

  InterpolateResult({
    this.outputY = const [],
    this.outCX = const [],
    this.outCY = const [],
    this.anchorX = const [],
    this.anchorY = const [],
    this.cp1NX = const [],
    this.cp1NY = const [],
    this.cp2NX = const [],
    this.cp2NY = const [],
  });
}
