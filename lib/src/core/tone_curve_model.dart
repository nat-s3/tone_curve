import 'package:flutter/material.dart';

import 'normalized_point.dart';

/// This class represents a tone curve model
abstract interface class ToneCurveModel implements Listenable {
  /// update sampling model
  void update({
    double? curvature,
    List<NormalizedPoint>? anchors,
    int? outputPoints,
  });

  /// Returns a list of normalized points that represent the tone curve.
  List<NormalizedPoint> get samplings;

  /// Returns a list of normalized points that represent the anchors.
  List<NormalizedPoint> get anchors;

  /// The number of output points.
  int get outputPoints;

  /// The curvature of the tone curve.
  double get curvature;
}
