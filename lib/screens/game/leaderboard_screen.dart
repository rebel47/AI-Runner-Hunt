import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: ListView(
        children: [
          Card(child: ListTile(title: Text('City Leaderboard'))),
          Card(child: ListTile(title: Text('Global Leaderboard'))),
          Card(child: ListTile(title: Text('Friend Challenges'))),
          Card(child: ListTile(title: Text('Seasonal Tournaments'))),
          Card(child: ListTile(title: Text('Achievements'))),
        ],
      ),
    );
  }
}
