import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:i_pet_pal/models/skin_eye.dart';

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
  final SkinEyeClassification skinEyeClassification = SkinEyeClassification();
  late Future<List<(Future<String>, double)>> skinEyeResult;

  @override
  void initState() {
    super.initState();

    setState(() {
      skinEyeResult =
          skinEyeClassification.inference(widget.selectedImage.readAsBytes());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 400,
            child: Image.file(
              File(widget.selectedImage.path),
            ),
          ),
          FutureBuilder(
            future: skinEyeResult,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              var inferenceTop = snapshot.data![0].$1;
              return FutureBuilder(
                future: inferenceTop,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return Text("${snapshot.data} 사진이 맞나요?");
                },
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text("네"),
              ),
              const SizedBox(
                width: 30,
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text("아니오"),
              )
            ],
          ),
        ],
      ),
    );
  }
}
