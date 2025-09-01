import 'package:flutter/material.dart';
import '../../services/health_service.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  int _steps = 0;
  double _calories = 0.0;
  double _distance = 0.0;
  bool _loading = true;
  DateTime _start = DateTime.now().subtract(const Duration(days: 7));
  DateTime _end = DateTime.now();
  int _sessionSteps = 0;
  bool _sessionActive = false;
  DateTime? _sessionStart;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() { _loading = true; });
    await HealthService.instance.requestPermissions();
    _steps = await HealthService.instance.getSteps(start: _start, end: _end);
    _calories = await HealthService.instance.getCalories(start: _start, end: _end);
    _distance = await HealthService.instance.getDistance(start: _start, end: _end);
    setState(() { _loading = false; });
  }

  void _startSession() {
    setState(() { _sessionActive = true; _sessionStart = DateTime.now(); _sessionSteps = 0; });
  }

  Future<void> _stopSession() async {
    setState(() { _sessionActive = false; });
    final end = DateTime.now();
    await HealthService.instance.recordSession(start: _sessionStart!, end: end);
    // Calculate session steps
    final steps = await HealthService.instance.getSteps(start: _sessionStart!, end: end);
    setState(() { _sessionSteps = steps; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _StepCounterWidget(steps: _steps),
                _StatsPanel(calories: _calories, distance: _distance),
                _ChallengePanel(),
                _AchievementsPanel(),
                _SessionPanel(
                  sessionActive: _sessionActive,
                  sessionSteps: _sessionSteps,
                  onStart: _startSession,
                  onStop: _stopSession,
                ),
                _ExportPanel(),
              ],
            ),
    );
  }
}

class _StepCounterWidget extends StatelessWidget {
  final int steps;
  const _StepCounterWidget({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: steps / 10000,
              strokeWidth: 12,
            ),
          ),
          Text('$steps', style: Theme.of(context).textTheme.headlineLarge),
        ],
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  final double calories;
  final double distance;
  const _StatsPanel({required this.calories, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Calories: ${calories.toStringAsFixed(0)}'),
        subtitle: Text('Distance: ${distance.toStringAsFixed(2)} m'),
      ),
    );
  }
}

class _ChallengePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder for fitness challenges
    return Card(child: ListTile(title: Text('Weekly Challenge')));
  }
}

class _AchievementsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder for achievements
    return Card(child: ListTile(title: Text('Achievements')));
  }
}

class _SessionPanel extends StatelessWidget {
  final bool sessionActive;
  final int sessionSteps;
  final VoidCallback onStart;
  final VoidCallback onStop;
  const _SessionPanel({required this.sessionActive, required this.sessionSteps, required this.onStart, required this.onStop});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(sessionActive ? 'Active Hunting Session' : 'Start Hunting Session'),
            subtitle: sessionActive ? Text('Steps: $sessionSteps') : null,
            trailing: sessionActive
                ? ElevatedButton(onPressed: onStop, child: Text('Stop'))
                : ElevatedButton(onPressed: onStart, child: Text('Start')),
          ),
        ],
      ),
    );
  }
}

class _ExportPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder for health data export
    return Card(child: ListTile(title: Text('Export Health Data')));
  }
}
