import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:onnxruntime/onnxruntime.dart';

class TritonClient {
  static Future<bool> ping(String baseUrl) async {
    final url = Uri.parse("$baseUrl/health/ready");
    final response = await http.get(url);
    return response.statusCode == 200;
  }

  static Future<List<(String, double)>> inference(
      String baseUrl, String modelName, Future<Uint8List> imageFuture) async {
    Uint8List imageBytes = await imageFuture;
    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetHeight: 224,
      targetWidth: 224,
    );
    final image = (await codec.getNextFrame()).image;
    final rgbFloats = await imageToFloatTensor(image);
    final imageTensor = OrtValueTensor.createTensorWithDataList(
        Float32List.fromList(rgbFloats), [1, 3, 224, 224]);

    final url = Uri.parse("$baseUrl/models/$modelName/infer");
    final body = {
      "inputs": [
        {
          "name": "data",
          "datatype": "FP32",
          "shape": [3, 224, 224],
          "data": imageTensor.value,
        },
      ],
      "outputs": [
        {
          "name": "resnetv24_dense0_fwd",
          "parameters": {
            "classification": 11,
          },
        }
      ]
    };
    return http.post(url, body: jsonEncode(body)).then(
      (response) {
        final responseBody = jsonDecode(response.body);
        final result = List<(String, double)>.from(
            responseBody["outputs"][0]["data"].map((data) {
          final c = data.split(":");
          return (c[2], double.parse(c[0]));
        }));
        final values = result.map((e) => e.$2);
        final softmaxValues = softmax(values.toList());
        return List<(String, double)>.generate(
            5, (index) => (result[index].$1, softmaxValues[index]));
      },
    );
  }

  static List<double> softmax(List<double> list) {
    final C = list.reduce(max);
    final d = list.map((y) => exp(y - C)).reduce((a, b) => a + b);
    return list.map((value) {
      return exp(value - C) / d;
    }).toList();
  }

  static Future<List<double>> imageToFloatTensor(ui.Image image) async {
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
