import 'package:flutter/material.dart';
import 'examine_screen/select_image.dart';

enum ExamineType {
  device,
  server,
}

class ExamineScreen extends StatefulWidget {
  final ExamineType examineType;

  const ExamineScreen({
    super.key,
    required this.examineType,
  });

  @override
  State<StatefulWidget> createState() => _ExamineScreenState();
}

class _ExamineScreenState extends State<ExamineScreen> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectImage(
        examineType: widget.examineType,
      ),
    );
  }
}
