import 'package:flutter/material.dart';

class LevelIndicator extends StatelessWidget {
  final int level;
  final int xp;
  final int xpForNextLevel;
  const LevelIndicator({required this.level, required this.xp, required this.xpForNextLevel, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(child: Text('Lv $level')),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: xp / xpForNextLevel,
            color: Colors.amber,
            backgroundColor: Colors.amber.withOpacity(0.2),
          ),
        ),
        Text('$xp / $xpForNextLevel XP'),
      ],
    );
  }
}
