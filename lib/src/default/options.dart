/// Options for the interpolation
class Options {
  // Member variables with types
  List<int> x, y;
  int dx, y0;
  double curvature;
  String className;
  Map<String, dynamic> css,
      canvas,
      grid,
      anchor,
      bar,
      plot,
      histogram,
      controlPoint;

  // Constructor with initializations
  Options()
      : x = [0, 255],
        y = [0, 255],
        dx = 1,
        y0 = 0,
        curvature = 0.3,
        className = '',
        css = {
          'position': 'relative',
          'margin': '20px',
        },
        canvas = {
          'height': '100%',
          'fillStyle': '#fff',
          'css': {
            'display': 'block',
            'boxShadow': '0 0 3px #000',
          },
        },
        grid = {
          'visible': true,
          'strokeStyle': 'rgba(0, 0, 0, 0.2)',
        },
        anchor = {
          'points': [
            [0.0, 0.0],
            [255.0, 255.0]
          ],
          'tagName': 'a',
          'className': 'anchor',
          'css': {
            'position': 'absolute',
            'display': 'block',
            'width': 18,
            'height': 18,
            'borderRadius': '50%',
            'border': '1px solid rgba(0, 0, 0, 0.5)',
            'background': 'rgba(255, 255, 255, 0.5)',
            'boxSizing': 'border-box',
            'cursor': 'move',
            'transform': 'translate(-50%, -50%)',
          },
        },
        bar = {
          'visible': true,
          'fillStyle': {
            'positive': 'rgba(0, 100, 70, 0.2)',
            'negative': 'rgba(150, 30, 70, 0.2)',
          },
        },
        plot = {
          'visible': false,
          'strokeStyle': '#f00',
        },
        histogram = {
          'data': null,
          'fillStyle': '#ddd',
        },
        controlPoint = {
          'visible': false,
          'strokeStyle': '#00f',
        };

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
