import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:i_pet_pal/models/skin_disease_normal.dart';
import 'package:image_picker/image_picker.dart';

enum InferenceType {
  eye,
  skin,
}

class InferenceDeviceScreen extends StatefulWidget {
  final XFile selectedImage;
  final InferenceType inferenceType;

  const InferenceDeviceScreen({
    super.key,
    required this.selectedImage,
    required this.inferenceType,
  });

  @override
  State<InferenceDeviceScreen> createState() => _InferenceState();
}

class _InferenceState extends State<InferenceDeviceScreen> {
  late Future<List<(Future<String>, double)>> diseaseResult;
  final SkinDiseaseNormalClassification skinDiseaseNormalClassification =
      SkinDiseaseNormalClassification();

  @override
  void initState() {
    super.initState();

    setState(() {
      // diseaseResult = TritonClient.inference(
      //   "https://nvidia.edens.one/v2",
      //   "resnet50_onnx",
      //   widget.selectedImage.readAsBytes(),
      // );
      diseaseResult = skinDiseaseNormalClassification
          .inference(widget.selectedImage.readAsBytes());
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
              FutureBuilder(
                future: diseaseResult,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              for (var inference in snapshot.data!)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 30,
                                  ),
                                  height: 30,
                                  alignment: Alignment.center,
                                  child: FutureBuilder(
                                    future: inference.$1,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }
                                      return Stack(
                                        children: [
                                          Text(
                                            snapshot.data!,
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
                                            snapshot.data!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                for (var inference in snapshot.data!)
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
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
