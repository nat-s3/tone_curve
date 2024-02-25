import 'dart:ui';

import 'anchor.dart';
import 'interpolate_model.dart';
import 'options.dart';
import 'view_values.dart';
import '../core/normalized_point.dart';
import '../core/tone_curve_model.dart';

/// DefaultToneCurveModel is a class that implements ToneCurveModel.
/// Represents the default tone curve model.
class DefaultToneCurveModel implements ToneCurveModel {
  DefaultToneCurveModel({
    double curvature = 0.3,
    int outputPoints = 256,
    List<NormalizedPoint>? samplings,
  })  : _curvature = curvature,
        _outputPoints = outputPoints,
        _samplings = samplings ?? [];

  final List<NormalizedPoint> _anchors = [
    const NormalizedPoint(x: 0, y: 0),
    const NormalizedPoint(x: 1, y: 1),
  ];

  final List<NormalizedPoint> _samplings;
  double _curvature;
  int _outputPoints;

  @override
  List<NormalizedPoint> get anchors => [..._anchors];

  @override
  double get curvature => _curvature;

  @override
  int get outputPoints => _outputPoints;

  @override
  List<NormalizedPoint> get samplings {
    if (_samplings.isEmpty) {
      return List.generate(
        outputPoints + 1,
        (index) =>
            NormalizedPoint(x: index / _outputPoints, y: index / _outputPoints),
      );
    }

    return [..._samplings];
  }

  @override
  void update({
    double? curvature,
    List<NormalizedPoint>? anchors,
    int? outputPoints,
  }) {
    // update curvature, anchor points, and output point count
    final curvatureValue = curvature ?? _curvature;
    final anchorsValue = anchors ?? _anchors;
    final outputPointsValue = outputPoints ?? _outputPoints;

    // calculate samples using calculation model
    const double baseSize = 300;
    final options = Options();
    options.dx = options.rangeX ~/ (outputPointsValue - 1);
    options.curvature = curvatureValue;
    final optionValues = OptionValues(options);
    final viewValues = ViewValues(
      viewWidth: baseSize,
      viewHeight: baseSize,
      toCanvasX: baseSize / optionValues.rangeX,
      toCanvasY: baseSize / optionValues.rangeY,
    );
    final offsetAnchors = anchorsValue
        .map((e) => Anchor(options, baseSize * e.x, baseSize * (1 - e.y),
            viewValues, optionValues))
        .toList();
    final model = InterpolateModel(options, offsetAnchors);
    final modelResult = model.interpolate(
      optionValue: optionValues,
      toCanvasX: viewValues.toCanvasX,
      toCanvasY: viewValues.toCanvasY,
    );
    final valueCounts = modelResult.outputY.length - 1;
    final points = modelResult.outputY.indexed
        .map(
          (e) => NormalizedPoint(
            x: clampDouble(e.$1 / valueCounts, 0, 1),
            y: clampDouble(e.$2 / options.rangeY, 0, 1),
          ),
        )
        .toList();

    // update
    if (anchors != null) {
      _anchors.replaceRange(0, _anchors.length, anchorsValue);
    }
    if (outputPoints != null) {
      _outputPoints = points.length;
    }
    if (curvature != null) {
      _curvature = curvatureValue;
    }
    _samplings
      ..clear()
      ..addAll(points);
  }
}
