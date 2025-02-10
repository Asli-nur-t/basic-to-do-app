import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profil'),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Bildirimler'),
          ),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('Yedekleme'),
          ),
        ],
      ),
    );
  }
}
