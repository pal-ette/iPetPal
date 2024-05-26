import 'dart:io';
import 'package:flutter/material.dart';
import 'package:i_pet_pal/models/resnet50.dart';
import 'package:image_picker/image_picker.dart';

enum InferenceType {
  eye,
  skin,
}

class Inference extends StatefulWidget {
  final XFile selectedImage;
  final InferenceType inferenceType;

  const Inference({
    super.key,
    required this.selectedImage,
    required this.inferenceType,
  });

  @override
  State<Inference> createState() => _InferenceState();
}

class _InferenceState extends State<Inference> {
  final Resnet50 deseaseClassification = Resnet50();
  late Future<List<(Future<String>, double)>> deseaseResult;

  @override
  void initState() {
    super.initState();

    setState(() {
      deseaseResult =
          deseaseClassification.inference(widget.selectedImage.readAsBytes());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Image.file(
              File(widget.selectedImage.path),
            ),
          ),
          FutureBuilder(
            future: deseaseResult,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Column(
                  children: [
                    CircularProgressIndicator(),
                  ],
                );
              }

              return Column(
                children: [
                  for (var inference in snapshot.data!)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder(
                          future: inference.$1,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }
                            return Text(snapshot.data!);
                          },
                        ),
                        Slider(
                          onChanged: null,
                          value: inference.$2,
                        ),
                        Text("${(inference.$2 * 100).toStringAsFixed(2)}%"),
                      ],
                    ),
                ],
              );
            },
          ),
          // child: FutureBuilder(
          //   future: deseaseResult,
          //   builder: (context, snapshot) {
          //     if (!snapshot.hasData) {
          //       return const CircularProgressIndicator();
          //     }

          //     return Column(
          //       children:
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
