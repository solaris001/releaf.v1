import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({required this.onThemeChanged, super.key});

  final void Function(ThemeMode themeMode) onThemeChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: settingsAppBar(),
      body: Stack(
        children: [
          // List of settings
          ListView.builder(
            itemCount: 3, // Adjust this based on the number of settings
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(settingsTileName[index] ?? 'Undefined'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to the settings detail/edit page for the selected setting
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => getSettingsPage(index),
                    ),
                  );
                },
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SvgPicture.asset(
              'assets/images/meerkatThinking.svg',
              height: MediaQuery.of(context).size.height / 2.5,
              fit: BoxFit.scaleDown,
            ),
          ),
        ],
      ),
    );
  }

  Map<int, String> settingsTileName = {
    0: 'Dark Mode',
    1: 'User Settings',
    2: 'Notifications',
  };

  Widget getSettingsPage(int index) {
    // Implement the logic to return the appropriate settings detail/edit page
    // based on the selected setting index
    switch (index) {
      case 0:
        return DarkModeSettingsPage(onThemeChanged: widget.onThemeChanged);
      //case 1:
      // return // UserSettingsPage();
      //case 2:
      //  return // NotificationsSettingsPage();
      // Add more cases for additional settings
      default:
        return const Placeholder();
    }
  }
}

AppBar settingsAppBar() {
  return AppBar(
    elevation: 0,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Settings'),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // close page
          },
        ),
      ],
    ),
  );
}

class DarkModeSettingsPage extends StatefulWidget {
  const DarkModeSettingsPage({required this.onThemeChanged, super.key});

  final void Function(ThemeMode themeMode) onThemeChanged;

  @override
  State<DarkModeSettingsPage> createState() => _DarkModeSettingsPageState();
}

class _DarkModeSettingsPageState extends State<DarkModeSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final currentThemeMode = Theme.of(context).brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dark Mode Settings'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You can switch to Dark Mode here.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Dark Mode'),
                    const Spacer(),
                    Switch(
                      value: currentThemeMode == ThemeMode.dark,
                      onChanged: (value) {
                        // Switch between light and dark mode
                        widget.onThemeChanged(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(
                'assets/images/meerkatThinking.svg',
                height: MediaQuery.of(context).size.height / 2.5,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
