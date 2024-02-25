import 'dart:math';
import 'dart:ui';

/// This class represents a normalized point
class NormalizedPoint {
  const NormalizedPoint({
    required this.x,
    required this.y,
  }) : assert(0 <= x && x <= 1 && 0 <= y && y <= 1);

  /// Create a new NormalizedPoint with the given x and y values, clamped to the range [0, 1].
  factory NormalizedPoint.clamp({
    required double x,
    required double y,
  }) =>
      NormalizedPoint(
        x: clampDouble(x, 0, 1),
        y: clampDouble(y, 0, 1),
      );

  /// The x-coordinate of the point, in the range [0, 1].
  final double x;

  /// The y-coordinate of the point, in the range [0, 1].
  final double y;

  /// The distance from the origin to the point.
  double get distance => sqrt(x * x + y * y);

  /// The difference between two points.
  Offset operator -(NormalizedPoint other) => Offset(
        x - other.x,
        y - other.y,
      );
}

/// This class represents a normalized point
extension ListNormalizedPoint on List<NormalizedPoint> {
  /// Returns a list of x-coordinates of the points.
  List<double> xList() => map((e) => e.x).toList();

  /// Returns a list of y-coordinates of the points.
  List<double> yList() => map((e) => e.y).toList();
}
