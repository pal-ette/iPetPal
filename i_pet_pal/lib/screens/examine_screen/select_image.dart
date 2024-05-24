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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 30, width: double.infinity),
        const Text("반려동물 사진을 찍거나 사진첩에서 사진을 선택해주세요."),
        const SizedBox(height: 20),
        _buildButton(context),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setImage(context, ImageSource.camera);
          },
          child: const Text("카메라"),
        ),
        ElevatedButton(
          onPressed: () {
            setImage(context, ImageSource.gallery);
          },
          child: const Text("갤러리"),
        ),
      ],
    );
  }
}
