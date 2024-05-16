import 'package:flutter/material.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

enum ImageLabel {
  apple("Apple", "apple.png"),
  bird("Bird", "bird.png"),
  bridge("Bridge", "bridge.png"),
  cat("Cat", "cat.png"),
  cello("Cello", "cello.png"),
  cheetah("Cheetah", "cheetah.png"),
  coffee("Coffee", "coffee.png"),
  dog("Dog", "dog.png"),
  flower("Flower", "flower.png"),
  lighthouse("Lighthouse", "lighthouse.png"),
  mushroom("Mushroom", "mushroom.png"),
  piano("Piano", "piano.png"),
  sailboat("Sailboat", "sailboat.png"),
  whale("Whale", "whale.png"),
  bluetit("Bluetit", "bluetit.jpg");

  const ImageLabel(this.label, this.path);
  final String label;
  final String path;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? selectedImagePath;
  List<(Future<String>, double)> inferenceResult = List.empty();
  Duration? inferenceTime;

  void _inference() {
    _inferenceResnet50();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownMenu<ImageLabel>(
              initialSelection: ImageLabel.cat,
              onSelected: (value) {
                if (value == null) {
                  return;
                }
                final path = value.path;
                setState(() {
                  selectedImagePath = 'assets/$path';
                });
              },
              dropdownMenuEntries: ImageLabel.values
                  .map<DropdownMenuEntry<ImageLabel>>((ImageLabel image) {
                return DropdownMenuEntry<ImageLabel>(
                  value: image,
                  label: image.label,
                );
              }).toList(),
            ),
            if (selectedImagePath != null) Image.asset(selectedImagePath!),
            for (var inference in inferenceResult)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder(
                    future: inference.$1,
                    builder: (context, snapshot) => Text(snapshot.data!),
                  ),
                  Slider(
                    onChanged: null,
                    value: inference.$2,
                  ),
                  Text("${(inference.$2 * 100).toStringAsFixed(2)}%"),
                ],
              ),
            if (inferenceTime != null)
              Text(
                  "Inference Time: ${inferenceTime!.inMilliseconds.toString()} ms")
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inference,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _inferenceResnet50() async {
    final stopwatch = Stopwatch()..start();
    OrtEnv.instance.init();
    final sessionOptions = OrtSessionOptions();
    // You can also try pointilism-9.ort and rain-princess.ort
    final rawAssetFile =
        await rootBundle.load("assets/models/resnet50-v2-7.onnx");
    // await rootBundle.load("assets/models/resnet-preproc-v1-18.onnx");
    final bytes = rawAssetFile.buffer.asUint8List();
    final session = OrtSession.fromBuffer(bytes, sessionOptions);
    final runOptions = OrtRunOptions();

    // You can also try red.png, redgreen.png, redgreenblueblack.png for easy debug
    ByteData blissBytes = await rootBundle.load(selectedImagePath!);
    final image = await decodeImageFromList(Uint8List.sublistView(blissBytes));
    final rgbFloats = await imageToFloatTensor(image);
    final inputOrt = OrtValueTensor.createTensorWithDataList(
        Float32List.fromList(rgbFloats), [1, 3, 224, 224]);

    final inputs = {'data': inputOrt};
    final outputs = session.run(runOptions, inputs);
    inputOrt.release();
    runOptions.release();
    sessionOptions.release();
    // session.release();
    OrtEnv.instance.release();
    List outFloats = outputs[0]?.value as List;
    stopwatch.stop();

    setState(() {
      inferenceResult = getImagenet(softmax(outFloats[0]));
      inferenceTime = stopwatch.elapsed;
    });
  }

  List<double> softmax(List<double> list) {
    final C = list.reduce(max);
    final d = list.map((y) => exp(y - C)).reduce((a, b) => a + b);
    return list.map((value) {
      return exp(value - C) / d;
    }).toList();
  }

  List<(Future<String>, double)> getImagenet(List<double> list) {
    final targetList = list.indexed.toList();
    targetList.sort((lValue, rValue) => rValue.$2.compareTo(lValue.$2));
    return targetList.sublist(0, 5).map((e) => (getLabel(e.$1), e.$2)).toList();
  }

  Future<String> getLabel(int index) async {
    final contents = await rootBundle.loadString("assets/synset.txt");

    return LineSplitter.split(contents)
        .map((line) => line.split(",")[0])
        .toList()[index];
  }

  int argmax(List<double> list) {
    int outMaxIndex = -1;
    double? maxValue;

    for (int i = 0; i < list.length; i++) {
      if (maxValue != null && list[i] <= maxValue) {
        continue;
      }
      maxValue = list[i];
      outMaxIndex = i;
    }
    return outMaxIndex;
  }

  Future<List<double>> imageToFloatTensor(ui.Image image) async {
    final imageAsFloatBytes =
        (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final rgbaUints = Uint8List.view(imageAsFloatBytes.buffer);
    final indexed = rgbaUints.indexed;
    return [
      ...indexed.where((e) => e.$1 % 4 == 0).map((e) {
        var processed = e.$2.toDouble() / 255.0;
        processed = processed - 0.485;
        processed = processed / 0.229;
        return processed;
      }),
      ...indexed.where((e) => e.$1 % 4 == 1).map((e) {
        var processed = e.$2.toDouble() / 255.0;
        processed = processed - 0.456;
        processed = processed / 0.224;
        return processed;
      }),
      ...indexed.where((e) => e.$1 % 4 == 2).map((e) {
        var processed = e.$2.toDouble() / 255.0;
        processed = processed - 0.406;
        processed = processed / 0.225;
        return processed;
      }),
    ];
  }
}
