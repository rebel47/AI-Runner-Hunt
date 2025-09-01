import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: ListView(
        children: [
          Card(child: ListTile(title: Text('Share Catch Photos'))),
          Card(child: ListTile(title: Text('City Chat Rooms'))),
          Card(child: ListTile(title: Text('Runner Sightings'))),
          Card(child: ListTile(title: Text('Community Challenges'))),
        ],
      ),
    );
  }
}
