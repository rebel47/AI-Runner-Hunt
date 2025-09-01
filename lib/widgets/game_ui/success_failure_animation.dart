import 'package:flutter/material.dart';

class SuccessFailureAnimation extends StatelessWidget {
  final bool success;
  const SuccessFailureAnimation({required this.success, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      child: success
          ? Icon(Icons.check_circle, color: Colors.green, size: 64, key: const ValueKey('success'))
          : Icon(Icons.close, color: Colors.red, size: 64, key: const ValueKey('failure')),
    );
  }
}
