import 'package:flutter/material.dart';
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
  final model = DefaultToneCurveModel();
  var seedColor = Colors.green;
  late var schema = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );
  var anchorRadius = 20.0;
  var subGridSplits = 4;
  var drawGrid = true;
  var drawSubGrid = true;
  var drawFillCurve = true;
  var drawLineCurve = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(colorScheme: schema, useMaterial3: true),
      darkTheme: ThemeData.from(colorScheme: schema, useMaterial3: true),
      themeMode: schema.brightness == Brightness.light
          ? ThemeMode.light
          : ThemeMode.dark,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tone Curve Sample'),
        ),
        body: Column(
          children: [
            // ToneCurve Widget
            Expanded(
              child: Center(
                child: ToneCurve(
                  model: model,
                  style: ToneCurveStyle(
                    anchorRadius: anchorRadius,
                    subGridSplits: subGridSplits,
                    drawGrid: drawGrid,
                    drawSubGrid: drawSubGrid,
                    drawFillCurve: drawFillCurve,
                    drawLineCurve: drawLineCurve,
                  ),
                  scheme: schema,
                ),
              ),
            ),
            // Control Widgets
            Card(
              child: Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('Curvature'),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Slider(
                      value: model.curvature,
                      onChanged: (value) {
                        setState(() {
                          model.update(curvature: value);
                        });
                      },
                      min: 0,
                      max: 1,
                      divisions: 10,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('Theme'),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        schema = ColorScheme.fromSeed(
                          seedColor: seedColor,
                          brightness: schema.brightness == Brightness.light
                              ? Brightness.dark
                              : Brightness.light,
                        );
                      });
                    },
                    icon: Icon(
                      schema.brightness == Brightness.light
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Wrap(
                        children: <MaterialColor>[
                          Colors.purple,
                          Colors.red,
                          Colors.pink,
                          Colors.orange,
                          Colors.yellow,
                          Colors.green,
                          Colors.teal,
                          Colors.cyan,
                          Colors.blue,
                          Colors.indigo,
                          Colors.blueGrey,
                          Colors.brown,
                          Colors.grey,
                        ]
                            .map(
                              (e) => IconButton(
                                onPressed: () => setState(
                                  () {
                                    seedColor = e;
                                    schema = ColorScheme.fromSeed(
                                      seedColor: seedColor,
                                      brightness: schema.brightness,
                                    );
                                  },
                                ),
                                icon: const Icon(Icons.color_lens),
                                color: e,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('AnchorRadius'),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Slider(
                      value: anchorRadius,
                      onChanged: (value) {
                        setState(() {
                          anchorRadius = value;
                        });
                      },
                      min: 1,
                      max: 50,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('SubGridSplits'),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Slider(
                      value: subGridSplits.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          subGridSplits = value.toInt();
                        });
                      },
                      min: 2,
                      max: 20,
                      divisions: 9,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Center(
                      child: Text('styles'),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Wrap(
                        children: [
                          SegmentedButton<int>(
                            multiSelectionEnabled: true,
                            emptySelectionAllowed: true,
                            segments: const [
                              ButtonSegment(label: Text('Grid'), value: 0),
                              ButtonSegment(label: Text('Sub Grid'), value: 1),
                              ButtonSegment(
                                  label: Text('Fill Curve'), value: 2),
                              ButtonSegment(
                                  label: Text('Line Curve'), value: 3),
                            ],
                            selected: {
                              if (drawGrid) 0,
                              if (drawSubGrid) 1,
                              if (drawFillCurve) 2,
                              if (drawLineCurve) 3,
                            },
                            onSelectionChanged: (v) {
                              setState(() {
                                drawGrid = v.contains(0);
                                drawSubGrid = v.contains(1);
                                drawFillCurve = v.contains(2);
                                drawLineCurve = v.contains(3);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
