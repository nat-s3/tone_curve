import 'options.dart';
import 'view_values.dart';

// Anchor is a class that represents an anchor point.
// This class is used only in the interpolate model.
class Anchor {
  final Options option;
  final double left;
  final double top;
  final ViewValues viewValues;
  final OptionValues optionValues;

  Anchor(this.option, this.left, this.top, this.viewValues, this.optionValues);

  List<double> get p => offset2real(
        left,
        top,
        viewValues.viewWidth,
        viewValues.viewHeight,
        optionValues.rangeX.toDouble(),
        optionValues.rangeY.toDouble(),
      );

  // Utility
  List<double> offset2real(
    double left,
    double top,
    double VW,
    double VH,
    double rangeX,
    double rangeY,
  ) {
    return [
      option.x[0] + left * rangeX / VW,
      option.y[0] + (VH - top) * rangeY / VH,
    ];
  }

  // Utility
  Map<String, double> real2offset(
    List<double> p,
    double VW,
    double VH,
    double rangeX,
    double rangeY,
  ) {
    return {
      'left': (p[0] - option.x[0]) * VW / rangeX,
      'top': (rangeY - (p[1] - option.y[0])) * VH / rangeY,
    };
  }
}
