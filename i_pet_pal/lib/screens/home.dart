import 'package:flutter/material.dart';
import 'package:i_pet_pal/screens/examine_screen.dart';
import 'package:i_pet_pal/screens/info_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;

  final List<Widget> pages = <Widget>[
    const ExamineScreen(
      examineType: ExamineType.Device,
    ),
    const ExamineScreen(
      examineType: ExamineType.Server,
    ),
    const InfoScreen(),
  ];

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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "간이 검사"),
          BottomNavigationBarItem(icon: Icon(Icons.loupe), label: "상세 검사"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "정보"),
        ],
        currentIndex: currentPageIndex,
        onTap: (value) => setState(() {
          currentPageIndex = value;
        }),
      ),
      body: pages[currentPageIndex],
    );
  }
}
