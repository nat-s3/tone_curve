import 'anchor.dart';
import 'options.dart';

/// InterpolateModelValues is a class that holds options and anchor lists.
class InterpolateModelValues {
  /// Options
  final Options option;

  /// Anchor list
  final List<Anchor> anchors;

  /// Normalized anchor X coordinate
  List<double> anchorNX = [];

  /// Normalized anchor Y coordinate
  List<double> anchorNY = [];

  /// Bezier control point length factor
  List<double> lengths = [];

  /// Slope of Bezier control point
  List<double> angles = [];

  /// Normalized interpolated curve X coordinate
  List<double> outNX = [];

  /// Normalized interpolated curve Y coordinate
  List<double> outNY = [];

  /// Constructor
  InterpolateModelValues(this.option, this.anchors);

  /// Anchor max index
  int get aniMax => anchors.length - 1;

  /// Line only flag
  bool get isLineOnly => anchors.length < 3 || option.curvature <= 0;

  /// Copy with
  InterpolateModelValues copyWith({
    List<double>? anchorNX,
    List<double>? anchorNY,
    List<double>? lengths,
    List<double>? angles,
    List<double>? outNX,
    List<double>? outNY,
  }) {
    var value = InterpolateModelValues(option, anchors);
    value.anchorNX = anchorNX ?? this.anchorNX;
    value.anchorNY = anchorNY ?? this.anchorNY;
    value.lengths = lengths ?? this.lengths;
    value.angles = angles ?? this.angles;
    value.outNX = outNX ?? this.outNX;
    value.outNY = outNY ?? this.outNY;
    return value;
  }
}
