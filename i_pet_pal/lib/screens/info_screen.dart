import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("https://github.com/pal-ette/iPetPal"),
              SizedBox(
                height: 20,
              ),
              Text("puppy by IronSV from Noun Project (CC BY 3.0)"),
              // https://thenounproject.com/browse/icons/term/puppy/
            ],
          ),
        ],
      ),
    );
  }
}
