import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

enum RunnerDifficulty { easy, medium, hard }

class Runner {
  final String id;
  final String city;
  final double latitude;
  final double longitude;
  final double speed;
  final double direction;
  final bool isActive;
  final String? lastCaughtBy;
  final RunnerDifficulty difficulty;
  final DateTime createdAt;
  final DateTime lastUpdated;

  Runner({
    required this.id,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.direction,
    required this.isActive,
    this.lastCaughtBy,
    required this.difficulty,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory Runner.fromJson(Map<String, dynamic> json) {
    return Runner(
      id: json['id'] ?? '',
      city: json['city'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      speed: (json['speed'] ?? 0.0).toDouble(),
      direction: (json['direction'] ?? 0.0).toDouble(),
      isActive: json['isActive'] ?? true,
      lastCaughtBy: json['lastCaughtBy'],
      difficulty: _difficultyFromString(json['difficulty'] ?? 'easy'),
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastUpdated: (json['lastUpdated'] is Timestamp)
          ? (json['lastUpdated'] as Timestamp).toDate()
          : DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'direction': direction,
      'isActive': isActive,
      'lastCaughtBy': lastCaughtBy,
      'difficulty': difficulty.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  static RunnerDifficulty _difficultyFromString(String str) {
    switch (str) {
      case 'medium': return RunnerDifficulty.medium;
      case 'hard': return RunnerDifficulty.hard;
      default: return RunnerDifficulty.easy;
    }
  }

  double distanceTo(double lat, double lng) {
    const earthRadius = 6371000.0; // meters
    final dLat = _deg2rad(lat - latitude);
    final dLng = _deg2rad(lng - longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(latitude)) * cos(_deg2rad(lat)) *
        sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * pi / 180.0;
}
