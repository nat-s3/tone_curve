import 'dart:math';
import 'dart:ui';

import 'anchor.dart';
import 'interpolate_model_values.dart';
import 'interpolate_result.dart';
import 'options.dart';

/// The InterpolateModel class provides methods for calculating control points for linear interpolation and Bezier curves.
class InterpolateModel {
  static const double piHalf = pi / 2;

  InterpolateModelValues value;

  InterpolateModel(Options option, List<Anchor> anchors)
      : value = InterpolateModelValues(option, anchors);

  /// Direct interpolation y = ax + b
  Map<String, List<double>> lineInterpolate({
    required List<double> nx,
    required List<double> ny,
    required int countX,
    required double rangeX,
    required double rangeY,
    required double toCanvasX,
    required double toCanvasY,
  }) {
    var ni = nx.length - 2;
    var toX = 1 / (countX - 1);
    var d = ab(nx, ny, ni);
    var outCX = List.filled(countX, 0.0); // <double>[];
    var outCY = List.filled(countX, 0.0); // <double>[];
    var outputY = List.filled(countX, 0.0); //<double>[];
    for (var i = countX; i-- > 0;) {
      var x = i * toX;
      if (x < nx[ni]) {
        while (x < nx[ni]) {
          ni--;
        }
        d = ab(nx, ny, ni);
      }
      var y = d['a']! * x + d['b']!;
      var rx = n2realX(x, rangeX);
      var ry = n2realY(y, rangeY);
      outCX[i] = canvasX(rx, toCanvasX);
      outCY[i] = canvasY(ry, toCanvasY);
      outputY[i] = ry;
    }
    return {
      'outputY': outputY,
      'outCX': outCX,
      'outCY': outCY,
    };
  }

  Map<String, double> ab(List<double> nx, List<double> ny, int ni) {
    var dx = nx[ni + 1] - nx[ni];
    if (dx != 0) {
      var a = (ny[ni + 1] - ny[ni]) / dx;
      return {
        'a': a,
        'b': ny[ni] - a * nx[ni],
      };
    }
    return {
      'a': 0,
      'b': ny[ni],
    };
  }

  // Normalized coordinate values are converted back
  double n2realX(double x, double rangeX) => x * rangeX + value.option.x[0];
  double n2realY(double y, double rangeY) => y * rangeY + value.option.y[0];

  // Converts actual XY values to canvas coordinates
  double canvasX(double x, double toCanvasX) =>
      (x - value.option.x[0]) * toCanvasX;
  double canvasY(double y, double toCanvasY) =>
      (value.option.y[1] - y) * toCanvasY;

  // Math.cos(90 degrees) not becoming zero due to rounding error
  double mathCos(double x) {
    if (x != 0) {
      if (x % piHalf != 0) {
        return cos(x);
      }
      return 0;
    }
    return 1;
  }

  InterpolateResult interpolate({
    required OptionValues optionValue,
    required double toCanvasX,
    required double toCanvasY,
  }) {
    var anchorX = <double>[];
    var anchorY = <double>[];
    var cp1NX = <double>[];
    var cp1NY = <double>[];
    var cp2NX = <double>[];
    var cp2NY = <double>[];
    if (value.angles.length != value.aniMax) {
      for (var i = 0; i < value.anchors.length; i++) {
        value.angles.add(0);
        value.anchorNY.add(0);
        value.anchorNX.add(0);
        value.outNX.add(0);
        value.outNY.add(0);
        value.lengths.add(0);
        anchorX.add(0);
        anchorY.add(0);
        cp1NX.add(0);
        cp1NY.add(0);
        cp2NX.add(0);
        cp2NY.add(0);
      }
    }

    // Anchor coordinate acquisition + normalization (0 to 1)
    for (int i = 0; i < value.anchors.length; i++) {
      var p = value.anchors[i].p;
      var x = p[0];
      var y = p[1];
      var nx = (x - value.option.x[0]) / optionValue.rangeX;
      var ny = (y - value.option.y[0]) / optionValue.rangeY;
      anchorX[i] = x;
      anchorY[i] = y;
      value.anchorNX[i] = nx;
      value.anchorNY[i] = ny;
      if (i != 0) {
        var dx = nx - value.anchorNX[i - 1];
        var dy = ny - value.anchorNY[i - 1];
        double len = sqrt(dx * dx + dy * dy);
        value.lengths[i - 1] = len * value.option.curvature;
      }
    }

    if (value.isLineOnly) {
      var result = lineInterpolate(
        nx: value.anchorNX,
        ny: value.anchorNY,
        countX: optionValue.countX,
        rangeX: optionValue.rangeX.toDouble(),
        rangeY: optionValue.rangeY.toDouble(),
        toCanvasX: toCanvasX,
        toCanvasY: toCanvasY,
      );
      return InterpolateResult(
        outCX: result['outCX']!,
        outCY: result['outCY']!,
        outputY: result['outputY']!,
        anchorX: anchorX,
        anchorY: anchorY,
      );
    }

    // Tangent slope and Bezier control point of the second anchor point - before the tail
    // ・When the anchor is exactly in the middle of the front/rear anchor, the slope is simply the slope of the line passing through the front/rear anchor.
    // ・If he is close to either the front or back anchor, the closer he is, the closer he is to the slope of the line passing through that anchor and himself.
    // For example, if the anchor is very close to the previous anchor, the slope will be very close to the slope of a straight line passing through itself and the previous anchor.
    for (var i = 1; i < value.aniMax; i++) {
      // Tangent slope
      value.angles[i] = anchorTangentAngle(
        value.anchorNX[i + 1] - value.anchorNX[i - 1],
        value.anchorNY[i + 1] - value.anchorNY[i - 1],
        value.anchorNX[i] - value.anchorNX[i - 1],
        value.anchorNY[i] - value.anchorNY[i - 1],
        value.anchorNX[i + 1] - value.anchorNX[i],
        value.anchorNY[i + 1] - value.anchorNY[i],
      );
      // Bezier control point
      var cp = anchorControlPoint(
        i,
        value.anchorNX[i],
        value.anchorNY[i],
        value.lengths[i - 1],
        value.lengths[i],
        value.angles[i],
      );
      cp1NX[i] = cp['cp1NX']!;
      cp1NY[i] = cp['cp1NY']!;
      cp2NX[i] = cp['cp2NX']!;
      cp2NY[i] = cp['cp2NY']!;
    }

    // Tangent slope of the leading anchor and one Bezier control point
    var firstCps = firstAnchorControlPoint();
    cp2NX[0] = firstCps['cp2NX']!;
    cp2NY[0] = firstCps['cp2NY']!;

    // Tangent slope of the trailing anchor and one Bezier control point
    final aniMax = value.aniMax;
    var lastCps = lastAnchorControlPoint();
    cp1NX[aniMax] = lastCps['cp1NX']!;
    cp1NY[aniMax] = lastCps['cp1NY']!;

    // Calculate the points on the Bezier curve finely by two anchors from the top, and finally linearly interpolate
    value.outNX.add(value.anchorNX[0]);
    value.outNY.add(value.anchorNY[0]);
    for (var i = 0; i < aniMax; i++) {
      final pt = canvasBezierPoint(
        value.anchorNX[i],
        value.anchorNY[i],
        value.anchorNX[i + 1],
        value.anchorNY[i + 1],
        cp2NX[i],
        cp2NY[i],
        cp1NX[i + 1],
        cp1NY[i + 1],
        i,
        optionValue.curveDx,
      );
      if (pt != null) {
        cp2NX[i] = pt['cp2NX_i']!;
        cp2NY[i] = pt['cp2NY_i']!;
        cp1NX[i + 1] = pt['cp1NX_ip1']!;
        cp1NY[i + 1] = pt['cp1NY_ip1']!;
      }
    }

    final result = lineInterpolate(
      nx: value.outNX,
      ny: value.outNY,
      countX: optionValue.countX,
      rangeX: optionValue.rangeX.toDouble(),
      rangeY: optionValue.rangeY.toDouble(),
      toCanvasX: toCanvasX,
      toCanvasY: toCanvasY,
    );
    return InterpolateResult(
      outCX: result['outCX']!,
      outCY: result['outCY']!,
      outputY: result['outputY']!,
      anchorX: anchorX,
      anchorY: anchorY,
      cp1NX: cp1NX,
      cp1NY: cp1NY,
      cp2NX: cp2NX,
      cp2NY: cp2NY,
    );
  }

  double anchorTangentAngle(
      double dx, double dy, double dx1, double dy1, double dx2, double dy2) {
    // Distance from previous/next point
    var l1 = dx1 * dx1 + dy1 * dy1;
    var l2 = dx2 * dx2 + dy2 * dy2;
    // Close to the previous anchor
    if (l1 < l2) {
      var ratio = l1 / l2;
      return ratio * atan2(dy, dx) + (1 - ratio) * atan2(dy1, dx1);
    }
    // Close to the later anchor
    if (l2 < l1) {
      var ratio = l2 / l1;
      return ratio * atan2(dy, dx) + (1 - ratio) * atan2(dy2, dx2);
    }
    // right in the center
    return atan2(dy, dx);
  }

  Map<String, double> anchorControlPoint(
      int i, double nx, double ny, double f1, double f2, double rd) {
    var cp1x = nx - mathCos(rd) * f1;
    var cp1y = ny - sin(rd) * f1;
    var cp2x = nx + mathCos(rd) * f2;
    var cp2y = ny + sin(rd) * f2;

    // Adjust control points if they go outside the frame in Y direction
    if (cp1y < 0 || 1 < cp1y) {
      cp1x = clampDouble(cp1x, 0, 1);
      cp1y = clampDouble(cp1y, 0, 1);
      value.angles[i] = atan2(ny - cp1y, nx - cp1x);
      rd = value.angles[i];
      cp2x = nx + mathCos(rd) * f2;
      cp2y = ny + sin(rd) * f2;
    }
    if (cp2y < 0 || 1 < cp2y) {
      cp2x = clampDouble(cp2x, 0, 1);
      cp2y = clampDouble(cp2y, 0, 1);
      value.angles[i] = atan2(cp2y - ny, cp2x - nx);
      rd = value.angles[i];
      cp1x = nx - mathCos(rd) * f1;
      cp1y = ny - sin(rd) * f1;
    }

    return {
      'cp1NX': cp1x,
      'cp1NY': cp1y,
      'cp2NX': cp2x,
      'cp2NY': cp2y,
    };
  }

  Map<String, double>? canvasBezierPoint(
    double p1x,
    double p1y,
    double p2x,
    double p2y,
    double cp1x,
    double cp1y,
    double cp2x,
    double cp2y,
    int i,
    double curveDx,
  ) {
    Map<String, double>? fixed;
    if (cp2x < cp1x) {
      fixed = cpxReverseFix(p1x, p1y, p2x, p2y, cp1x, cp1y, cp2x, cp2y, i);
    }
    var dN = ((p2x - p1x) / curveDx).floor();
    for (var j = 1; j < dN; j++) {
      var po = cubicBezierPoint2D(
          p1x, p1y, p2x, p2y, cp1x, cp1y, cp2x, cp2y, j / dN);
      var px = clampDouble(po[0], 0, 1);
      var py = clampDouble(po[1], 0, 1);
      value.outNX.add(px);
      value.outNY.add(py);
    }
    value.outNX.add(p2x);
    value.outNY.add(p2y);
    return fixed;
  }

  Map<String, double> cpxReverseFix(double p1x, double p1y, double p2x,
      double p2y, double cp1x, double cp1y, double cp2x, double cp2y, int i) {
    // Center of anchor X coordinate
    var center = (p1x + p2x) / 2;
    // Cut the left side because the right side is shorter
    if (center <= cp2x) {
      cp1y = yForXonLinePoints(cp2x, p1x, p1y, cp1x, cp1y) ?? cp1y;
      cp1x = cp2x;
      return {
        'cp2NX_i': cp1x,
        'cp2NY_i': cp1y,
        'cp1NX_ip1': cp2x,
        'cp1NY_ip1': cp2y,
      };
    }
    // Cut the right side because the left side is shorter
    if (cp1x <= center) {
      cp2y = yForXonLinePoints(cp1x, p2x, p2y, cp2x, cp2y) ?? cp2y;
      cp2x = cp1x;
      return {
        'cp2NX_i': cp1x,
        'cp2NY_i': cp1y,
        'cp1NX_ip1': cp2x,
        'cp1NY_ip1': cp2y,
      };
    }
    // They're both over the center, so they're in the center.
    cp1y = yForXonLinePoints(center, p1x, p1y, cp1x, cp1y) ?? cp1y;
    cp2y = yForXonLinePoints(center, p2x, p2y, cp2x, cp2y) ?? cp2y;
    cp2x = center;
    cp1x = cp2x;
    return {
      'cp2NX_i': cp1x,
      'cp2NY_i': cp1y,
      'cp1NX_ip1': cp2x,
      'cp1NY_ip1': cp2y,
    };
  }

// Function to get a point on a cubic Bezier curve in 2D
  List<double> cubicBezierPoint2D(
    double p1x,
    double p1y,
    double p2x,
    double p2y,
    double cp1x,
    double cp1y,
    double cp2x,
    double cp2y,
    double t,
  ) {
    double u = 1 - t;
    double tt = t * t;
    double uu = u * u;
    double ttt = tt * t;
    double uuu = uu * u;
    double uut3 = 3 * uu * t;
    double utt3 = 3 * u * tt;
    double x = uuu * p1x + uut3 * cp1x + utt3 * cp2x + ttt * p2x;
    double y = uuu * p1y + uut3 * cp1y + utt3 * cp2y + ttt * p2y;

    return [x, y];
  }

  // Function to find y coordinate for a given x on the line defined by two points
  double? yForXonLinePoints(
    double x,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    double dx = x2 - x1;
    double dy = y2 - y1;
    if (dx == 0) {
      // Ensure dx is not zero to avoid division by zero error
      return null;
    }
    double a = dy / dx;
    double b = y1 - a * x1;
    return a * x + b;
  }

  Map<String, double> firstAnchorControlPoint() {
    double n1x = value.anchorNX[0];
    double n1y = value.anchorNY[0];
    double n2x = value.anchorNX[1];
    double n2y = value.anchorNY[1];
    double n2a = value.angles[1];
    late double x, y, x_, y_;

    if (n1y == n2y) {
      x_ = n2x - mathCos(n2a);
      x = (n1x + n2x) / 2;
      x = x - (x_ - x);
      y = n2y - sin(n2a);
    } else {
      // The midpoint and its orthogonal line
      double a = (n1x - n2x) / (n2y - n1y);
      double b = ((n1y + n2y) / 2) - a * ((n1x + n2x) / 2);
      double theta = atan(a) * 2;
      double sin2t = sin(theta);
      double cos2t = mathCos(theta);
      x_ = n2x - mathCos(n2a);
      y_ = n2y - sin(n2a) - b;
      x = cos2t * x_ + sin2t * y_;
      y = sin2t * x_ - cos2t * y_ + b;
    }

    double dx = x - n1x;
    double dy = y - n1y;
    double n1a = atan2(dy, dx);
    if (n1a < -piHalf || piHalf < n1a) {
      n1a = (n1y < n2y) ? piHalf : -piHalf;
    }
    value.angles[0] = n1a;

    double len = value.lengths[0];
    double cpx = n1x + mathCos(n1a) * len;
    double cpy = n1y + sin(n1a) * len;

    cpx = clampDouble(cpx, 0, 1);
    cpy = clampDouble(cpy, 0, 1);

    return {
      'cp2NX': cpx,
      'cp2NY': cpy,
    };
  }

  Map<String, double> lastAnchorControlPoint() {
    int aniMax = value.aniMax;
    double n1x = value.anchorNX[aniMax - 1];
    double n1y = value.anchorNY[aniMax - 1];
    double n1a = value.angles[aniMax - 1];
    double n2x = value.anchorNX[aniMax];
    double n2y = value.anchorNY[aniMax];
    double x, y, x_, y_;
    // Tangent slope
    if (n1y == n2y) {
      x_ = n1x + mathCos(n1a);
      x = (n1x + n2x) / 2;
      x = x + (x - x_);
      y = n1y + sin(n1a);
    } else {
      // A straight line orthogonal through the midpoint of the end and the one before it, y = ax + b and its angle θ
      double a = (n1x - n2x) / (n2y - n1y);
      double b = ((n1y + n2y) / 2) - a * ((n1x + n2x) / 2);
      double t = atan(a) * 2;
      // The symmetric point of an appropriate point on the tangent line before the end on this straight line
      double sin2t = sin(t);
      double cos2t = mathCos(t);
      x_ = n1x + mathCos(n1a);
      y_ = n1y + sin(n1a) - b;
      x = cos2t * x_ + sin2t * y_;
      y = sin2t * x_ - cos2t * y_ + b;
    }
    // A straight line connecting the end point from point ② is the tangent at the first point
    var dx = n2x - x;
    var dy = n2y - y;
    var n2a = atan2(dy, dx);
    if (n2a < -piHalf || piHalf < n2a) {
      n2a = (n1y < n2y) ? piHalf : -piHalf;
    }
    value.angles[aniMax] = n2a;
    // Bezier control point
    var len = value.lengths[aniMax - 1];
    var cpx = n2x - mathCos(n2a) * len;
    var cpy = n2y - sin(n2a) * len;
    // Keep control points that are out of the frame within the frame
    cpx = clampDouble(cpx, 0, 1);
    cpy = clampDouble(cpy, 0, 1);
    return {
      'cp1NX': cpx,
      'cp1NY': cpy,
    };
  }
}
