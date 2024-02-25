# tone_curve

This package provides components that can be used with Flutter to add tone curve functionality.


## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  tone_curve: ^0.0.1
```

Then, run the following command:

```sh
$ flutter pub get
```


## Usage

First, import the `tone_curve` package:

```dart
import 'package:tone_curve/tone_curve.dart';
```

Next, add the `ToneCurve` widget to your widget tree:


```dart
ToneCurve(
  data: myCurveData,
  onCurveChanged: (curveData) {
    // Do something with the new curve data
  },
)
```


## License

This package is published under the MIT license. For more details, please see the [LICENSE](LICENSE) file.
