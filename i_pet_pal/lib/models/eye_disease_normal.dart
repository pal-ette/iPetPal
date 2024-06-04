import 'package:onnxruntime/onnxruntime.dart';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:convert';

class EyeDiseaseNormalClassification {
  Future<List<(Future<String>, double)>> inference(
      Future<Uint8List> imageFuture) async {
    final stopwatch = Stopwatch()..start();
    OrtEnv.instance.init();
    final sessionOptions = OrtSessionOptions();
    // You can also try pointilism-9.ort and rain-princess.ort
    final rawAssetFile =
        await rootBundle.load("assets/models/eye_disease_normal.onnx");
    final bytes = rawAssetFile.buffer.asUint8List();
    final session = OrtSession.fromBuffer(bytes, sessionOptions);
    final runOptions = OrtRunOptions();

    // You can also try red.png, redgreen.png, redgreenblueblack.png for easy debug
    Uint8List imageBytes = await imageFuture;
    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetHeight: 224,
      targetWidth: 224,
    );
    final image = (await codec.getNextFrame()).image;
    final rgbFloats = await imageToFloatTensor(image);
    final inputOrt = OrtValueTensor.createTensorWithDataList(
        Float32List.fromList(rgbFloats), [1, 224, 224, 3]);
    final inputs = {session.inputNames[0]: inputOrt};
    final outputs = session.run(runOptions, inputs);
    inputOrt.release();
    runOptions.release();
    sessionOptions.release();
    session.release();
    OrtEnv.instance.release();
    List outFloats = outputs[0]?.value as List;
    stopwatch.stop();
    final result = outFloats[0][0].clamp(0.0, 1.0);
    return [
      (getLabel(0), 1.0 - result),
      (getLabel(1), result),
    ];
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
    return targetList.sublist(0, 2).map((e) => (getLabel(e.$1), e.$2)).toList();
  }

  Future<String> getLabel(int index) async {
    final contents =
        await rootBundle.loadString("assets/labels/eye_disease_normal.txt");

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
      ...indexed.where((e) => [0, 1, 2].contains(e.$1 % 4)).map((e) {
        var processed = e.$2.toDouble();
        return processed;
      })
    ];
  }
}
