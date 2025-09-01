import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthService {
  HealthService._privateConstructor();
  static final HealthService instance = HealthService._privateConstructor();
  final HealthFactory _health = HealthFactory();

  Future<bool> requestPermissions() async {
    final types = [HealthDataType.STEPS, HealthDataType.ACTIVE_ENERGY_BURNED, HealthDataType.DISTANCE_WALKED];
    return await _health.requestAuthorization(types);
  }

  Future<int> getSteps({required DateTime start, required DateTime end}) async {
    final data = await _health.getHealthDataFromTypes(start, end, [HealthDataType.STEPS]);
    return data.fold(0, (sum, d) => sum + (d.value as int));
  }

  Future<double> getCalories({required DateTime start, required DateTime end}) async {
    final data = await _health.getHealthDataFromTypes(start, end, [HealthDataType.ACTIVE_ENERGY_BURNED]);
    return data.fold(0.0, (sum, d) => sum + (d.value as double));
  }

  Future<double> getDistance({required DateTime start, required DateTime end}) async {
    final data = await _health.getHealthDataFromTypes(start, end, [HealthDataType.DISTANCE_WALKED]);
    return data.fold(0.0, (sum, d) => sum + (d.value as double));
  }

  Future<void> recordSession({required DateTime start, required DateTime end}) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('sessions') ?? [];
    sessions.add('${start.toIso8601String()},${end.toIso8601String()}');
    await prefs.setStringList('sessions', sessions);
  }

  Future<List<Map<String, DateTime>>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('sessions') ?? [];
    return sessions.map((s) {
      final parts = s.split(',');
      return {
        'start': DateTime.parse(parts[0]),
        'end': DateTime.parse(parts[1]),
      };
    }).toList();
  }

  Future<void> exportHealthData() async {
    // Placeholder: implement export functionality
  }
}
