import 'dart:io';
import 'package:flutter/material.dart';
import 'package:i_pet_pal/screens/examine_screen/inference_device_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:i_pet_pal/models/skin_eye.dart';

class ConfirmImage extends StatefulWidget {
  final XFile selectedImage;

  const ConfirmImage({
    super.key,
    required this.selectedImage,
  });

  @override
  State<ConfirmImage> createState() => _ConfirmImageState();
}

class _ConfirmImageState extends State<ConfirmImage> {
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
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(
                  child: Image.file(File(widget.selectedImage.path)),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: FutureBuilder(
              future: skinEyeResult,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Column(
                    children: [
                      CircularProgressIndicator(),
                    ],
                  );
                }
                var inferenceTop = snapshot.data![0].$1;
                return FutureBuilder(
                  future: inferenceTop,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Column(
                        children: [
                          CircularProgressIndicator(),
                        ],
                      );
                    }
                    final InferenceType inferenceType = snapshot.data == "eye"
                        ? InferenceType.eye
                        : InferenceType.skin;

                    return Column(
                      children: [
                        if (inferenceType == InferenceType.eye)
                          const Text("눈 사진이 맞나요?"),
                        if (inferenceType == InferenceType.skin)
                          const Text("피부 사진이 맞나요?"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  confirm(inferenceType);
                                },
                                child: const Text("네"),
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  confirm(inferenceType);
                                },
                                child: const Text("아니오"),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void confirm(InferenceType inferenceType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InferenceDeviceScreen(
          selectedImage: widget.selectedImage,
          inferenceType: inferenceType,
        ),
      ),
    );
  }
}
