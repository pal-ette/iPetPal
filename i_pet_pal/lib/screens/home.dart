import 'package:flutter/material.dart';
import 'package:i_pet_pal/screens/examine_screen.dart';
import 'package:i_pet_pal/screens/setting_screen.dart';
import 'package:i_pet_pal/screens/info_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 1;

  final List<Widget> pages = <Widget>[
    const InfoScreen(),
    const ExamineScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.info), label: "정보"),
            BottomNavigationBarItem(icon: Icon(Icons.loupe), label: "검사"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "설정"),
          ],
          currentIndex: currentPageIndex,
          onTap: (value) => setState(() {
            currentPageIndex = value;
          }),
        ),
        body: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
                builder: (context) => pages[currentPageIndex]);
          },
        ));
  }
}
