import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  void _onTapNounProject() async {
    await launchUrl(
      Uri.parse("https://thenounproject.com/browse/icons/term/puppy/"),
    );
  }

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
              const Text("https://github.com/pal-ette/iPetPal"),
              const SizedBox(
                height: 20,
              ),
              Row(
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
              ),
              //
            ],
          ),
        ],
      ),
    );
  }
}
