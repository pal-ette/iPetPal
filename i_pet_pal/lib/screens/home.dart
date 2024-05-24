import 'package:flutter/material.dart';
import 'package:i_pet_pal/screens/photo_screen.dart';
import 'package:i_pet_pal/screens/setting_screen.dart';
import 'package:i_pet_pal/screens/info_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;

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
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.loupe),
            label: "검사",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: "설정",
          ),
          NavigationDestination(
            icon: Icon(Icons.info),
            label: "만든이",
          ),
        ],
      ),
      body: const <Widget>[
        ExamineScreen(),
        SettingScreen(),
        InfoScreen(),
      ][currentPageIndex],
    );
  }
}
