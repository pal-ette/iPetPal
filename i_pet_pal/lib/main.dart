import 'package:flutter/material.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
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
  ui.Image? image;

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
            Image.asset('assets/cat.png'),
            RawImage(
              image: image,
            )
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
    OrtEnv.instance.init();
    final sessionOptions = OrtSessionOptions();
    // You can also try pointilism-9.ort and rain-princess.ort
    final rawAssetFile =
        await rootBundle.load("assets/models/resnet50-v1-12.onnx");
    // await rootBundle.load("assets/models/resnet-preproc-v1-18.onnx");
    final bytes = rawAssetFile.buffer.asUint8List();
    final session = OrtSession.fromBuffer(bytes, sessionOptions);
    final runOptions = OrtRunOptions();

    // You can also try red.png, redgreen.png, redgreenblueblack.png for easy debug
    ByteData blissBytes = await rootBundle.load('assets/cat.png');
    final image = await decodeImageFromList(Uint8List.sublistView(blissBytes));
    final rgbFloats = await imageToFloatTensor(image);
    print(rgbFloats);
    final inputOrt = OrtValueTensor.createTensorWithDataList(
        Float32List.fromList(rgbFloats), [1, 3, 224, 224]);

    final regenImage = await floatTensorToImage(rgbFloats);
    setState(() {
      this.image = regenImage;
    });

    final inputs = {'data': inputOrt};
    final outputs = session.run(runOptions, inputs);
    inputOrt.release();
    runOptions.release();
    sessionOptions.release();
    // session.release();
    OrtEnv.instance.release();
    List outFloats = outputs[0]?.value as List;

    for (int i = 0; i < outFloats[0].length; ++i) {}
    print(outFloats[0][283]);
    print(argmax(outFloats[0]));
  }

  int argmax(List<double> list) {
    int outMaxIndex = -1;
    double? maxValue = null;

    for (int i = 0; i < list.length; i++) {
      if (maxValue != null && list[i] <= maxValue) {
        continue;
      }
      maxValue = list[i];
      outMaxIndex = i;
      print('${i} & ${maxValue}');
    }
    print(maxValue);
    return outMaxIndex;
  }

  Future<List<double>> imageToFloatTensor(ui.Image image) async {
    final imageAsFloatBytes =
        (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final rgbaUints = Uint8List.view(imageAsFloatBytes.buffer);

    final indexed = rgbaUints.indexed;
    return [
      ...indexed.where((e) => [0, 1, 2].contains(e.$1 % 4)).map((e) {
        var processed = e.$2.toDouble() / 255.0;
        if (e.$1 == 0) {
          processed = processed - 0.485;
          processed = processed / 0.229;
        }
        if (e.$1 == 1) {
          processed = processed - 0.456;
          processed = processed / 0.224;
        }
        if (e.$1 == 2) {
          processed = processed - 0.406;
          processed = processed / 0.225;
        }
        return processed;
      }),
    ];
  }

  Future<ui.Image> floatTensorToImage(List tensorData) {
    print(tensorData.length);
    final outRgbaFloats = Uint8List(4 * 224 * 224);
    for (int x = 0; x < 224; x++) {
      for (int y = 0; y < 224; y++) {
        final index = x * 224 * 4 + y * 4;
        final baseIndex = x * 224 * 3 + y * 3;
        outRgbaFloats[index + 0] =
            (tensorData[baseIndex + 0] * 255).toInt(); // r
        outRgbaFloats[index + 1] =
            (tensorData[baseIndex + 1] * 255).toInt(); // g
        outRgbaFloats[index + 2] =
            (tensorData[baseIndex + 2] * 255).toInt(); // b
        outRgbaFloats[index + 3] = 255; // a
      }
    }
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(outRgbaFloats, 224, 224, ui.PixelFormat.rgba8888,
        (ui.Image image) {
      completer.complete(image);
    });

    return completer.future;
  }
}
