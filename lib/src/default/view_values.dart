/// View values
class ViewValues {
  /// en: Coefficient for converting normalized X value to canvas X value
  double toCanvasX;

  /// en: Coefficient for converting normalized Y value to canvas Y value
  double toCanvasY;

  /// en: Width of the canvas
  double viewWidth;

  /// en: Height of the canvas
  double viewHeight;

  ViewValues({
    required this.viewWidth,
    required this.viewHeight,
    required this.toCanvasX,
    required this.toCanvasY,
  });
}
