import 'package:flutter/material.dart';
import 'examine_screen/select_image.dart';

class ExamineScreen extends StatelessWidget {
  const ExamineScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SelectImage(),
    );
  }
}
