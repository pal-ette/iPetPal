import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';

bool serverInference = false;

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  // This widget is the root of your application.
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SettingsList(
        lightTheme: SettingsThemeData(
          settingsListBackground: Theme.of(context).scaffoldBackgroundColor,
        ),
        darkTheme: SettingsThemeData(
          settingsListBackground: Theme.of(context).scaffoldBackgroundColor,
        ),
        sections: [
          SettingsSection(
            title: const Text('인공지능'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                title: const Text('서버에서 검사'),
                initialValue: serverInference,
                onToggle: (value) {
                  setState(() {
                    serverInference = !serverInference;
                  });
                },
                leading: const Icon(Icons.leak_add_outlined),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('계정'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.logout),
                title: const Text('로그아웃'),
                onPressed: ((context) {}),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('기타'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.star),
                title: const Text('앱 평가하기'),
                onPressed: ((context) {}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
