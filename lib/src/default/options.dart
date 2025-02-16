/// Options for the interpolation
class Options {
  // Member variables with types
  List<int> x, y;
  int dx, y0;
  double curvature;

  // Constructor with initializations
  Options() : x = [0, 255], y = [0, 255], dx = 1, y0 = 0, curvature = 0.3;

  // Getters to compute properties
  int get rangeX => x[1] - x[0];
  int get rangeY => y[1] - y[0];
  int get countX => rangeX ~/ dx + 1; // Integer division
  double get curveDx {
    final rangeX = this.rangeX.toDouble();
    return (dx * 100 < rangeX) ? dx / rangeX : 0.01;
  }
}

/// Option values
class OptionValues {
  int rangeX, rangeY, countX;
  double curveDx;

  OptionValues(Options options)
    : rangeX = options.rangeX,
      rangeY = options.rangeY,
      countX = options.countX,
      curveDx = options.curveDx;
}
