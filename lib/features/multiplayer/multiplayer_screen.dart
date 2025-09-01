import 'package:flutter/material.dart';

class MultiplayerScreen extends StatelessWidget {
  const MultiplayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiplayer Hunt')),
      body: Center(
        child: Text('Real-time multiplayer, team challenges, PvP competitions'),
      ),
    );
  }
}
