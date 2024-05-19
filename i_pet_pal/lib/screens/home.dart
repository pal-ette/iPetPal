import 'package:flutter/material.dart';

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
      appBar: AppBar(),
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
        const Text("1"),
        const Text("2"),
      ][currentPageIndex],
    );
  }
}
