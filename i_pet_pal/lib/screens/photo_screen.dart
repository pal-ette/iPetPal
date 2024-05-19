import 'dart:io';
import 'package:flutter/material.dart';
import 'package:i_pet_pal/models/resnet50.dart';
import 'package:image_picker/image_picker.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  XFile? _image;
  final ImagePicker picker = ImagePicker();
  final Resnet50 resnet = Resnet50();

  List<(Future<String>, double)> inferenceResult = [];

  void setImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
      return;
    }
    setState(() {
      _image = XFile(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 30, width: double.infinity),
        _buildPhotoArea(),
        const SizedBox(height: 20),
        _buildButton(),
      ],
    );
  }

  Widget _buildPhotoArea() {
    return _image != null
        ? Container(
            width: 300,
            height: 300,
            child: Image.file(File(_image!.path)),
          )
        : Container(
            width: 300,
            height: 300,
            color: Colors.grey,
          );
  }

  Widget _buildButton() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setImage(ImageSource.camera);
              },
              child: const Text("카메라"),
            ),
            const SizedBox(width: 30),
            ElevatedButton(
              onPressed: () {
                setImage(ImageSource.gallery);
              },
              child: const Text("갤러리"),
            ),
            const SizedBox(width: 30),
            ElevatedButton(
              onPressed: () async {
                if (_image == null) {
                  return;
                }
                final result = await resnet.inference(_image!.readAsBytes());
                setState(() {
                  inferenceResult = result;
                });
              },
              child: const Text("분석"),
            ),
          ],
        ),
        for (var inference in inferenceResult)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder(
                future: inference.$1,
                builder: (context, snapshot) => Text(snapshot.data!),
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
  }
}
