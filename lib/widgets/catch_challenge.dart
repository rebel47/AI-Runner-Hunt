import 'package:flutter/material.dart';

typedef ChallengeCallback = void Function();

enum ChallengeType { tapRapidly, solvePuzzle, takeSelfie }

class CatchChallenge extends StatefulWidget {
  final int runnerLevel;
  final ChallengeCallback onSuccess;
  final ChallengeCallback onFailure;
  const CatchChallenge({required this.runnerLevel, required this.onSuccess, required this.onFailure, super.key});

  @override
  State<CatchChallenge> createState() => _CatchChallengeState();
}

class _CatchChallengeState extends State<CatchChallenge> {
  late ChallengeType _type;
  int _progress = 0;
  int _goal = 10;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _type = _selectChallengeType(widget.runnerLevel);
    _goal = 10 + widget.runnerLevel * 5;
  }

  ChallengeType _selectChallengeType(int level) {
    if (level % 3 == 0) return ChallengeType.solvePuzzle;
    if (level % 2 == 0) return ChallengeType.tapRapidly;
    return ChallengeType.takeSelfie;
  }

  void _handleTap() {
    setState(() { _progress++; });
    if (_progress >= _goal) {
      setState(() { _completed = true; });
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_type) {
      case ChallengeType.tapRapidly:
        return Column(
          children: [
            const Text('Tap rapidly to catch!'),
            ElevatedButton(
              onPressed: _completed ? null : _handleTap,
              child: Text('Tap (${_progress}/$_goal)'),
            ),
          ],
        );
      case ChallengeType.solvePuzzle:
        return Column(
          children: [
            const Text('Solve this puzzle!'),
            // Placeholder: Add accessibility-friendly puzzle widget
            ElevatedButton(
              onPressed: _completed ? null : widget.onSuccess,
              child: const Text('Solve'),
            ),
          ],
        );
      case ChallengeType.takeSelfie:
        return Column(
          children: [
            const Text('Take a selfie to catch!'),
            ElevatedButton(
              onPressed: _completed ? null : widget.onSuccess,
              child: const Text('Take Selfie'),
            ),
          ],
        );
    }
  }
}
