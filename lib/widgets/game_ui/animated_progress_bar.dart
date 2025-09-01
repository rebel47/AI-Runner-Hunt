import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final double max;
  final Color color;
  final String label;
  const AnimatedProgressBar({required this.value, required this.max, required this.color, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value / max),
          duration: const Duration(milliseconds: 800),
          builder: (context, val, child) {
            return LinearProgressIndicator(
              value: val,
              color: color,
              backgroundColor: color.withOpacity(0.2),
            );
          },
        ),
        Text('${value.toInt()} / ${max.toInt()}'),
      ],
    );
  }
}
