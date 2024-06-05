import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:i_pet_pal/api/triton_client.dart';
import 'package:i_pet_pal/screens/examine_screen/confirm_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;
import 'package:onnxruntime/onnxruntime.dart';

class InferenceServerScreen extends StatefulWidget {
  final XFile selectedImage;
  final InferenceType inferenceType;

  const InferenceServerScreen({
    super.key,
    required this.selectedImage,
    required this.inferenceType,
  });

  @override
  State<InferenceServerScreen> createState() => _InferenceState();
}

class _InferenceState extends State<InferenceServerScreen> {
  List<(String, double)>? diseaseResult;

  static Future<String> _imageToRequestBodyTf(ui.Image image) async {
    final imageAsFloatBytes =
        (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final rgbaUints = Uint8List.view(imageAsFloatBytes.buffer);
    final indexed = rgbaUints.indexed;
    final imageDoubleList = [
      ...indexed.where((e) => [0, 1, 2].contains(e.$1 % 4)).map((e) {
        var processed = e.$2.toDouble() / 225.0;
        return processed;
      })
    ];
    final imageTensor = OrtValueTensor.createTensorWithDataList(
        Float32List.fromList(imageDoubleList), [1, 224, 224, 3]);
    final body = {
      "inputs": [
        {
          "name": "input_1",
          "datatype": "FP32",
          "shape": [224, 224, 3],
          "data": imageTensor.value,
        },
      ],
      "outputs": [
        {
          "name": "dense_1",
          "parameters": {
            "classification": 4,
          },
        }
      ]
    };
    return jsonEncode(body);
  }

  static Future<String> _imageToRequestBody(ui.Image image) async {
    final imageAsFloatBytes =
        (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final rgbaUints = Uint8List.view(imageAsFloatBytes.buffer);
    final indexed = rgbaUints.indexed;
    final imageDoubleList = [
      ...indexed.where((e) => e.$1 % 4 == 0).map((e) {
        var processed = e.$2.toDouble() / 255.0;
        return processed;
      }),
      ...indexed.where((e) => e.$1 % 4 == 1).map((e) {
        var processed = e.$2.toDouble() / 255.0;
        return processed;
      }),
      ...indexed.where((e) => e.$1 % 4 == 2).map((e) {
        var processed = e.$2.toDouble() / 255.0;
        return processed;
      }),
    ];
    final imageTensor = OrtValueTensor.createTensorWithDataList(
        Float32List.fromList(imageDoubleList), [1, 224, 224, 3]);
    final body = {
      "inputs": [
        {
          "name": "input.1",
          "datatype": "FP32",
          "shape": [3, 224, 224],
          "data": imageTensor.value,
        },
      ],
      "outputs": [
        {
          "name": "651",
          "parameters": {
            "classification": 4,
          },
        }
      ]
    };
    return jsonEncode(body);
  }

  Future<(String, String)> _inference() async {
    late String apiPath;
    late String body;
    Uint8List imageBytes = await widget.selectedImage.readAsBytes();
    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetHeight: 224,
      targetWidth: 224,
    );
    final image = (await codec.getNextFrame()).image;
    if (widget.inferenceType == InferenceType.skin) {
      apiPath = "skin_disease_4";
      body = await _imageToRequestBody(image);
    } else if (widget.inferenceType == InferenceType.eye) {
      apiPath = "eye_disease_4";
      body = await _imageToRequestBodyTf(image);
    }
    return (apiPath, body);
  }

  @override
  void initState() {
    super.initState();

    _inference().then((target) {
      TritonClient.inference(
        "https://nvidia.edens.one/v2",
        target.$1,
        target.$2,
      ).then((result) {
        setState(() {
          diseaseResult = result;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.file(
            File(widget.selectedImage.path),
            filterQuality: FilterQuality.low,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color:
                Theme.of(context).colorScheme.surfaceContainer.withAlpha(180),
          ),
          Column(
            children: [
              Text(
                "결과",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 60.0,
                ),
              ),
              if (diseaseResult == null) const CircularProgressIndicator(),
              if (diseaseResult != null)
                Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            for (var inference in diseaseResult!)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 30,
                                ),
                                height: 30,
                                alignment: Alignment.center,
                                child: Stack(
                                  children: [
                                    Text(
                                      inference.$1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 2
                                          ..color = Theme.of(context)
                                              .colorScheme
                                              .surfaceContainer,
                                      ),
                                    ),
                                    Text(
                                      inference.$1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              for (var inference in diseaseResult!)
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 30,
                                      ),
                                      height: 30,
                                      child: LinearProgressIndicator(
                                        value: inference.$2,
                                      ),
                                    ),
                                    Stack(
                                      children: [
                                        Text(
                                          "${(inference.$2 * 100).toStringAsFixed(2)}%",
                                          style: TextStyle(
                                            foreground: Paint()
                                              ..style = PaintingStyle.stroke
                                              ..strokeWidth = 2
                                              ..color = (inference.$2 > 0.5)
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .surfaceContainer,
                                          ),
                                        ),
                                        Text(
                                          "${(inference.$2 * 100).toStringAsFixed(2)}%",
                                          style: TextStyle(
                                            color: (inference.$2 > 0.5)
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .popUntil((route) => route.isFirst),
                      child: const Text("처음으로 돌아가기"),
                    ),
                  ],
                ),
            ],
          )
        ],
      ),
    );
  }
}
