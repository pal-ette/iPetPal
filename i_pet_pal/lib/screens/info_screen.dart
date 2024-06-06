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
                _github(),
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

  Widget _weblinkText(String text, String url) {
    return GestureDetector(
      onTap: () async => await launchUrl(
        Uri.parse(url),
      ),
      child: Text(
        text,
        style: const TextStyle(
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _github() {
    return _weblinkText("https://github.com/pal-ette/iPetPal",
        "https://github.com/pal-ette/iPetPal");
  }

  Widget _iconLicense() {
    return Row(
      children: [
        const Text("puppy by IronSV from "),
        _weblinkText(
          "Noun Project",
          "https://thenounproject.com/browse/icons/term/puppy/",
        ),
        const Text(" (CC BY 3.0)"),
      ],
    );
  }

  Widget _fontLicense() {
    return Row(children: [
      const Text("이 어플리케이션에는 "),
      _weblinkText(
        "교보 손글씨 2023 우선아 폰트",
        "https://www.kyobobook.co.kr/handwriting/font",
      ),
      const Text(" 가 사용되었습니다."),
    ]);
  }
}
