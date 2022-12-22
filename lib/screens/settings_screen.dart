import 'package:flutter/material.dart';
import 'package:tootfruit/drawer.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);
  final _selectedFartCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.pink,
        drawer: const AppDrawer(),
        appBar: AppBar(
          elevation: 0,
          title: const Center(
            child: Text('SETTINGS'),
          ),
        ),
        body: ListView(
          children: [
            ListTile(
              leading: const Text('Selected Fart'),
              trailing: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: DropdownButtonFormField(
                  value: _selectedFartCon.text,
                  items: <String>[
                    'Auto',
                    'Fart1',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      alignment: Alignment.center,
                      value: value.toLowerCase(),
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (Object? value) {
                    _selectedFartCon.text = value.toString();
                  },
                ),
              ),
            )
          ],
        ));
  }
}
