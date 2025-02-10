import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Dil'),
            trailing: Text('Türkçe'),
          ),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('Bildirim Sesi'),
          ),
          ListTile(
            leading: Icon(Icons.timer),
            title: Text('Pomodoro Ayarları'),
          ),
        ],
      ),
    );
  }
}
