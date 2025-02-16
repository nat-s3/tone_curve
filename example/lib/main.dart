import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tone_curve/tone_curve.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LastValueProcessor<List<double>> processor;
  final streamController = StreamController<List<double>>.broadcast();
  final model = DefaultToneCurveModel();
  final seedColorNotifier = ValueNotifier<Color>(Colors.primaries[0]);
  final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  final toneCurveStyleNotifier = ValueNotifier<ToneCurveStyle>(
    const ToneCurveStyle(
      anchorRadius: 20,
      subGridSplits: 4,
      drawGrid: true,
      drawSubGrid: true,
      drawFillCurve: true,
      drawLineCurve: true,
    ),
  );
  final seedColorIndexNotifier = ValueNotifier<int>(0);
  final appliedImage = ValueNotifier<Uint8List?>(null);

  @override
  void initState() {
    processor = LastValueProcessor(
      inputStream: streamController.stream,
      processValue: computeImage,
    )..listen();
    super.initState();
  }

  @override
  void dispose() {
    processor.close();
    streamController.close();
    model.dispose();
    seedColorNotifier.dispose();
    themeModeNotifier.dispose();
    toneCurveStyleNotifier.dispose();
    seedColorIndexNotifier.dispose();
    appliedImage.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const useYear2023Theme = false;

    return ListenableBuilder(
      listenable: Listenable.merge([themeModeNotifier, seedColorNotifier]),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColorNotifier.value,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColorNotifier.value,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: themeModeNotifier.value,
          home: child!,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tone Curve Sample'),
          actions: [
            IconButton.outlined(
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                themeModeNotifier.value =
                    ThemeMode.values[(themeModeNotifier.value.index + 1) %
                        ThemeMode.values.length];
              },
              icon: ValueListenableBuilder(
                valueListenable: themeModeNotifier,
                builder: (context, value, child) {
                  return Icon(switch (value) {
                    ThemeMode.system => Icons.auto_awesome,
                    ThemeMode.light => Icons.light_mode,
                    ThemeMode.dark => Icons.dark_mode,
                  }, color: Theme.of(context).colorScheme.primary);
                },
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder(
              valueListenable: seedColorIndexNotifier,
              builder: (context, value, child) {
                final scheme = Theme.of(context).colorScheme;
                return IconButton.outlined(
                  color: scheme.primary,
                  onPressed: () {
                    final nextIndex = (value + 1) % Colors.primaries.length;
                    seedColorIndexNotifier.value = nextIndex;
                    seedColorNotifier.value = Colors.primaries[nextIndex];
                  },
                  icon: Icon(Icons.color_lens, color: Colors.primaries[value]),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // ToneCurve Widget
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: CardDesignFrame(
                        child: LayoutSwitch(
                          horizontalChildren: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.asset(
                                  'assets/sample.jpg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Center(
                              child: ListenableBuilder(
                                listenable: seedColorIndexNotifier,
                                builder: (context, child) {
                                  return Icon(
                                    Icons.arrow_forward,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: CardDesignFrame(
                                  useOutline: false,
                                  child: ToneCurveCardContent(
                                    model: model,
                                    streamController: streamController,
                                    toneCurveStyleNotifier:
                                        toneCurveStyleNotifier,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: ListenableBuilder(
                                listenable: seedColorIndexNotifier,
                                builder: (context, child) {
                                  return Icon(
                                    Icons.arrow_forward,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: ValueListenableBuilder(
                                  valueListenable: appliedImage,
                                  builder: (context, value, child) {
                                    if (value == null) {
                                      return Center(
                                        child: Icon(Icons.image_not_supported),
                                      );
                                    }
                                    return Image.memory(
                                      value,
                                      fit: BoxFit.contain,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                          verticalChildren: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Image.asset(
                                        'assets/sample.jpg',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: ListenableBuilder(
                                      listenable: seedColorIndexNotifier,
                                      builder: (context, child) {
                                        return Icon(
                                          Icons.arrow_forward,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        );
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: ValueListenableBuilder(
                                        valueListenable: appliedImage,
                                        builder: (context, value, child) {
                                          if (value == null) {
                                            return Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                              ),
                                            );
                                          }
                                          return Image.memory(
                                            value,
                                            fit: BoxFit.contain,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: CardDesignFrame(
                                  useOutline: false,
                                  child: ToneCurveCardContent(
                                    model: model,
                                    streamController: streamController,
                                    toneCurveStyleNotifier:
                                        toneCurveStyleNotifier,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Control Widgets
            ControlCardFrame(
              title: Text('Curvature'),
              child: ListenableBuilder(
                listenable: model,
                builder: (context, child) {
                  return Slider(
                    year2023: useYear2023Theme,
                    label: model.curvature.toString(),
                    value: model.curvature,
                    onChanged: (value) {
                      model.update(curvature: value);
                    },
                    min: 0,
                    max: 1,
                    divisions: 10,
                  );
                },
              ),
            ),
            ControlCardFrame(
              padding: EdgeInsets.only(left: 4, top: 4, bottom: 4),
              title: ValueListenableBuilder(
                valueListenable: toneCurveStyleNotifier,
                builder: (context, value, child) {
                  void toggle() {
                    toneCurveStyleNotifier.value = value.copyWith(
                      useAnchorOutline: !value.useAnchorOutline,
                    );
                  }

                  const shape = RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  );
                  const padding = EdgeInsets.all(4);

                  if (value.useAnchorOutline) {
                    return OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: shape,
                        padding: padding,
                      ),
                      onPressed: toggle,
                      child: Text('Anchor Radius'),
                    );
                  } else {
                    return FilledButton(
                      style: FilledButton.styleFrom(
                        shape: shape,
                        padding: padding,
                      ),
                      onPressed: toggle,
                      child: Text('Anchor Radius'),
                    );
                  }
                },
              ),
              child: ValueListenableBuilder(
                valueListenable: toneCurveStyleNotifier,
                builder: (context, value, child) {
                  return Slider(
                    year2023: useYear2023Theme,
                    label: value.anchorRadius.toString(),
                    value: value.anchorRadius,
                    onChanged: (value) {
                      toneCurveStyleNotifier.value = toneCurveStyleNotifier
                          .value
                          .copyWith(anchorRadius: value);
                    },
                    min: 10,
                    max: 50,
                    divisions: 8,
                  );
                },
              ),
            ),
            ControlCardFrame(
              title: Text('Sub Grid Splits'),
              child: ValueListenableBuilder(
                valueListenable: toneCurveStyleNotifier,
                builder: (context, value, child) {
                  return Slider(
                    year2023: useYear2023Theme,
                    label: value.subGridSplits.toString(),
                    value: value.subGridSplits.toDouble(),
                    onChanged: (value) {
                      toneCurveStyleNotifier.value = toneCurveStyleNotifier
                          .value
                          .copyWith(subGridSplits: value.toInt());
                    },
                    min: 2,
                    max: 20,
                    divisions: 9,
                  );
                },
              ),
            ),
            ControlCardFrame(
              title: Text('Grid Style'),
              child: Center(
                child: Wrap(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: toneCurveStyleNotifier,
                      builder: (context, value, child) {
                        return SegmentedButton<int>(
                          showSelectedIcon: false,
                          multiSelectionEnabled: false,
                          emptySelectionAllowed: true,
                          segments: const [
                            ButtonSegment(label: Text('None'), value: 0),
                            ButtonSegment(label: Text('Grid'), value: 1),
                            ButtonSegment(label: Text('Sub Grid'), value: 2),
                          ],
                          selected: {
                            if (!value.drawGrid && !value.drawSubGrid) 0,
                            if (value.drawGrid && !value.drawSubGrid) 1,
                            if (value.drawGrid && value.drawSubGrid) 2,
                          },
                          onSelectionChanged: (v) {
                            toneCurveStyleNotifier
                                .value = toneCurveStyleNotifier.value.copyWith(
                              drawGrid: v.contains(1) || v.contains(2),
                              drawSubGrid: v.contains(2),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            ControlCardFrame(
              title: Text('Curve Style'),
              child: Center(
                child: Wrap(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: toneCurveStyleNotifier,
                      builder: (context, value, child) {
                        return SegmentedButton<int>(
                          showSelectedIcon: false,
                          multiSelectionEnabled: true,
                          emptySelectionAllowed: true,
                          segments: const [
                            ButtonSegment(label: Text('Fill Curve'), value: 1),
                            ButtonSegment(label: Text('Line Curve'), value: 2),
                          ],
                          selected: {
                            if (value.drawFillCurve) 1,
                            if (value.drawLineCurve) 2,
                          },
                          onSelectionChanged: (v) {
                            toneCurveStyleNotifier
                                .value = toneCurveStyleNotifier.value.copyWith(
                              drawFillCurve: v.contains(1),
                              drawLineCurve: v.contains(2),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Compute the image
  Future<void> computeImage(List<double> samplings) async {
    // Convert the tone curve output to a map
    final toneCurveOutputMap = samplings.map((v) => v * 255).toList();

    // Load the image
    final rawImage = await rootBundle.load('assets/sample.jpg');
    final resultImage = await compute((message) {
      final image = img.decodeImage(message.$1);
      final toneCurveOutputMap = message.$2;
      if (image == null) {
        return null;
      }
      // Apply the tone curve
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final r = pixel.r.toInt();
          final g = pixel.g.toInt();
          final b = pixel.b.toInt();
          pixel.setRgb(
            toneCurveOutputMap[r],
            toneCurveOutputMap[g],
            toneCurveOutputMap[b],
          );
          image.setPixel(x, y, pixel);
        }
      }
      return img.encodeJpg(image);
    }, (rawImage.buffer.asUint8List(), toneCurveOutputMap));

    if (resultImage != null) {
      appliedImage.value = resultImage;
    }
    print('completed image processing');
  }
}

/// Implementation of a widget containing tone curves
class ToneCurveCardContent extends StatelessWidget {
  const ToneCurveCardContent({
    super.key,
    required this.model,
    required this.streamController,
    required this.toneCurveStyleNotifier,
  });

  final ToneCurveModel model;
  final StreamController<List<double>> streamController;
  final ValueNotifier<ToneCurveStyle> toneCurveStyleNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: toneCurveStyleNotifier,
      builder: (context, value, child) {
        final scheme = Theme.of(context).colorScheme;
        return ToneCurve(
          model: model,
          onUpdated: streamController.add,
          style: value.copyWith(
            backgroundColor: scheme.surface,
            gridColor: scheme.outline,
            curveFillColor: scheme.secondaryContainer,
            curveLineColor: scheme.primary,
            anchorColor: scheme.primary,
            anchorHoldColor: scheme.primary,
          ),
        );
      },
    );
  }
}

/// Card design frames
class CardDesignFrame extends StatelessWidget {
  const CardDesignFrame({
    super.key,
    required this.child,
    this.useOutline = true,
  });

  final Widget child;
  final bool useOutline;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.all(8);
    if (useOutline) {
      return Card.outlined(child: Padding(padding: padding, child: child));
    }
    return Card.filled(child: Padding(padding: padding, child: child));
  }
}

/// Design Widget to control
class ControlCardFrame extends StatelessWidget {
  const ControlCardFrame({
    super.key,
    this.padding = const EdgeInsets.only(left: 8, top: 8, bottom: 8),
    required this.title,
    required this.child,
  });

  final EdgeInsetsGeometry padding;
  final Widget title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(padding: padding, child: Center(child: title)),
          ),
          Expanded(flex: 4, child: child),
        ],
      ),
    );
  }
}

/// Holds a raw instance
class RawInstance<T> {
  const RawInstance(this.value);
  final T value;
}

/// A class That processes the last value of a stream
class LastValueProcessor<T> {
  LastValueProcessor({required this.inputStream, required this.processValue});

  /// Stream to process
  final Stream<T> inputStream;

  /// Function to process the value
  final Future<void> Function(T value) processValue;

  /// Start processing the last value
  RawInstance<T>? _lastValue;

  /// Flag to manage whether asynchronous processing is in progress
  bool _isProcessing = false;

  /// Stream subscription to manage the stream
  StreamSubscription<T>? _subscription;

  /// Start listening to the stream
  void listen() {
    _subscription = inputStream.listen((newValue) {
      _lastValue = RawInstance(newValue);

      if (!_isProcessing) {
        // If asynchronous processing is not in progress, start processing
        _processLastValue();
      }
    });
  }

  /// Stop listening to the stream
  void close() => _subscription?.cancel();

  /// Process the last value
  Future<void> _processLastValue() async {
    _isProcessing = true; // Processing started

    if (_lastValue == null) {
      _isProcessing =
          false; // If there is no value to process, processing is complete
      return;
    }

    final valueToProcess = _lastValue!;
    _lastValue = null; // Clear the value to process

    await processValue(valueToProcess.value); // Process the value

    _isProcessing = false; // Processing completed

    if (_lastValue != null) {
      _processLastValue(); // If there is a value to process, process it
    }
  }
}

/// A class that switches between vertical and horizontal layouts based on layoutable ratios
class LayoutSwitch extends StatelessWidget {
  const LayoutSwitch({
    super.key,
    required this.horizontalChildren,
    required this.verticalChildren,
  });

  final List<Widget> horizontalChildren;
  final List<Widget> verticalChildren;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, layout) {
        if (layout.maxWidth > layout.maxHeight) {
          return Row(children: horizontalChildren);
        } else {
          return Column(children: verticalChildren);
        }
      },
    );
  }
}
