import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.pets,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'iPetPal',
              style: TextStyle(
                fontSize: 24,
              ),
            )
          ],
        ),
      ),
      body: const Text("22"),
    );
  }
}
