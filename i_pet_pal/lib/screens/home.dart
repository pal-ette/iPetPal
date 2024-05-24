import 'package:flutter/material.dart';
import 'package:i_pet_pal/screens/photo_screen.dart';

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
            icon: Icon(Icons.camera),
            label: "Photo",
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: "History",
          )
        ],
      ),
      body: const <Widget>[
        PhotoScreen(),
        Text("2"),
      ][currentPageIndex],
    );
  }
}
