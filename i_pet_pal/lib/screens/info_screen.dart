import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final widget in [
                const Text("https://github.com/pal-ette/iPetPal"),
                _iconLicense(),
                _fontLicense(),
              ]) ...[
                widget,
                const SizedBox(
                  height: 20,
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  void _onTapNounProject() async {
    await launchUrl(
      Uri.parse("https://thenounproject.com/browse/icons/term/puppy/"),
    );
  }

  Widget _iconLicense() {
    return Row(
      children: [
        const Text("puppy by IronSV from "),
        GestureDetector(
          onTap: _onTapNounProject,
          child: const Text(
            "Noun Project",
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const Text(" (CC BY 3.0)"),
      ],
    );
  }

  Widget _fontLicense() {
    return const Text("이 어플리케이션에는 교보 손글씨 2023 우선아 폰트를 사용되었습니다.");
  }
}
