import 'package:flutter/material.dart';
import 'package:i_pet_pal/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Home(),
      title: 'iPetPal',
      theme: ThemeData(
        fontFamily: 'KyoboHandwrite2023',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
        ),
        useMaterial3: true,
      ),
    );
  }
}
