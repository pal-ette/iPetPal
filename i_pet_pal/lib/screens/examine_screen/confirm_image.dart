import 'dart:io';
import 'package:flutter/material.dart';
import 'package:i_pet_pal/screens/examine_screen/inference.dart';
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
            flex: 1,
            child: Image.file(File(widget.selectedImage.path)),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Inference(
                        selectedImage: widget.selectedImage,
                        inferenceType: InferenceType.eye,
                      ),
                    ),
                  );
                },
                child: const Text("아니오"),
              )
            ],
          ),
        ],
      ),
    );
  }
}
