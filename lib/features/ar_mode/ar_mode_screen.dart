import 'package:flutter/material.dart';
// import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
// import 'package:arkit_flutter_plugin/arkit_flutter_plugin.dart';

class ARModeScreen extends StatelessWidget {
  const ARModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Mode')),
      body: Center(
        child: Text('AR Mode: 3D runners, AR catch challenges, immersive experience'),
      ),
    );
  }
}
