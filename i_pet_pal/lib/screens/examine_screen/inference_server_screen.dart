import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:i_pet_pal/api/triton_client.dart';
import 'package:image_picker/image_picker.dart';

enum InferenceType {
  eye,
  skin,
}

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
  late Future<List<(String, double)>> diseaseResult;

  @override
  void initState() {
    super.initState();

    setState(() {
      late String apiPath;
      if (widget.inferenceType == InferenceType.skin) {
        apiPath = "";
      } else if (widget.inferenceType == InferenceType.eye) {
        apiPath = "";
      }
      diseaseResult = TritonClient.inference(
        "https://nvidia.edens.one/v2",
        apiPath,
        widget.selectedImage.readAsBytes(),
      );
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
