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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.examineType == ExamineType.device)
            _buildDeviceDescription(context),
          if (widget.examineType == ExamineType.server)
            _buildServerDescription(context),
          _buildButton(context),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _buildDeviceDescription(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: const Text(
              "🔍 간이 검사",
              style: TextStyle(
                fontSize: 40,
              ),
            ),
          ),
          const Text(
            "서버 연결이 필요 없이 기기에서 진단합니다.",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          DefaultTabController(
            key: UniqueKey(),
            length: 3,
            child: Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: Image.asset('assets/guides/guide_1.jpg'),
                            ),
                            const Text(
                              "1. 새로 촬영하거나 저장된 사진을 선택합니다.",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Expanded(
                              child: Image.asset('assets/guides/guide_2.jpg'),
                            ),
                            const Text(
                              "2. 눈을 촬영한 사진인지, 피부를 촬영한 사진인지 확인합니다.",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Expanded(
                              child: Image.asset('assets/guides/guide_3_1.jpg'),
                            ),
                            const Text(
                              "3. 질병이 의심되는지 여부를 보여줍니다.",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TabPageSelector(
                    color: Colors.white,
                    selectedColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
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
          Container(
            alignment: Alignment.center,
            child: const Text(
              "🧑🏻‍⚕️ 상세 검사",
              style: TextStyle(
                fontSize: 40,
              ),
            ),
          ),
          const Text(
            "서버 연결을 통해서 보다 정확하게 진단합니다.",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          DefaultTabController(
            key: UniqueKey(),
            length: 3,
            child: Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: Image.asset('assets/guides/guide_1.jpg'),
                            ),
                            const Text(
                              "1. 새로 촬영하거나 저장된 사진을 선택합니다.",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Expanded(
                              child: Image.asset('assets/guides/guide_2.jpg'),
                            ),
                            const Text(
                              "2. 눈을 촬영한 사진인지, 피부를 촬영한 사진인지 확인합니다.",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Expanded(
                              child: Image.asset('assets/guides/guide_3_2.jpg'),
                            ),
                            const Text(
                              "3. 의심되는 질병을 높은 순서로 보여줍니다.",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TabPageSelector(
                    color: Colors.white,
                    selectedColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setImage(context, ImageSource.camera);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
            ),
            child: const Column(
              children: [
                Icon(Icons.camera),
                Text("카메라"),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setImage(context, ImageSource.gallery);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
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
