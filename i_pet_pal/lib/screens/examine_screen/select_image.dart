import 'package:i_pet_pal/screens/examine_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'confirm_image.dart';

class SelectImage extends StatefulWidget {
  final ExamineType examineType;

  const SelectImage({
    super.key,
    required this.examineType,
  });

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
          builder: (context) => ConfirmImage(
            selectedImage: pickedFile,
            examineType: widget.examineType,
          ),
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
        if (widget.examineType == ExamineType.Device)
          _buildDeviceDescription(context),
        if (widget.examineType == ExamineType.Server)
          _buildServerDescription(context),
        _buildButton(context),
        const SizedBox(
          height: 30,
        )
      ],
    );
  }

  Widget _buildDeviceDescription(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                "🔍 간이 검사",
                style: TextStyle(
                  fontSize: 40,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Text("사진을 통해 빠르게 아픈지 아닌지를 판단합니다."),
                Text("서버 연결이 필요 없이 기기에서 진단합니다."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerDescription(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                "🧑🏻‍⚕️ 상세 검사",
                style: TextStyle(
                  fontSize: 40,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Text("사진을 통해 의심되는 질병을 진단합니다."),
                Text("서버 연결을 통해서 보다 정확하게 진단합니다."),
              ],
            ),
          ),
        ],
      ),
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
