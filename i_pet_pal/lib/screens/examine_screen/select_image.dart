import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'confirm_image.dart';

class SelectImage extends StatefulWidget {
  const SelectImage({super.key});

  @override
  State<SelectImage> createState() => _SelectImageState();
}

class _SelectImageState extends State<SelectImage> {
  final ImagePicker picker = ImagePicker();

  void setImage(BuildContext context, ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
      return;
    }
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmImage(selectedImage: pickedFile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            children: [
              Text(
                "반려동물 사진을 찍거나 사진첩에서 사진을 선택해주세요.",
                style: TextStyle(
                  fontSize: 40,
                ),
              ),
            ],
          ),
        ),
        _buildButton(context),
        SizedBox(
          height: 30,
        )
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setImage(context, ImageSource.camera);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(60),
            ),
            child: const Column(
              children: [
                Icon(Icons.camera),
                Text("카메라"),
              ],
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setImage(context, ImageSource.gallery);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(60),
            ),
            child: const Column(
              children: [
                Icon(Icons.photo),
                Text("갤러리"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
