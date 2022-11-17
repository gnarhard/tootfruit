import 'package:flutter/material.dart';
import 'package:tooty_fruity/screens/settings_screen.dart';
import 'package:tooty_fruity/screens/toot_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.pinkAccent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 8.0),
        child: Column(
          children: [
            ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TootScreen()),
                  );
                },
                title: const Text(
                  'Fart',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                )),
            ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
                title: const Text(
                  'Settings',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ))
          ],
        ),
      ),
    );
  }
}
