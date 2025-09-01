import 'package:cloud_firestore/cloud_firestore.dart';

enum PoolStatus { active, completed }

class Pool {
  final String id;
  final String city;
  final double prizeAmount;
  final int maxWinners;
  final int currentWinners;
  final PoolStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;

  Pool({
    required this.id,
    required this.city,
    required this.prizeAmount,
    required this.maxWinners,
    required this.currentWinners,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  factory Pool.fromJson(Map<String, dynamic> json) {
    return Pool(
      id: json['id'] ?? '',
      city: json['city'] ?? '',
      prizeAmount: (json['prizeAmount'] ?? 0.0).toDouble(),
      maxWinners: json['maxWinners'] ?? 0,
      currentWinners: json['currentWinners'] ?? 0,
      status: json['status'] == 'completed' ? PoolStatus.completed : PoolStatus.active,
      startTime: (json['startTime'] is Timestamp)
          ? (json['startTime'] as Timestamp).toDate()
          : DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: (json['endTime'] is Timestamp)
          ? (json['endTime'] as Timestamp).toDate()
          : DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'prizeAmount': prizeAmount,
      'maxWinners': maxWinners,
      'currentWinners': currentWinners,
      'status': status == PoolStatus.completed ? 'completed' : 'active',
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool isActive() => status == PoolStatus.active && DateTime.now().isBefore(endTime);
  bool isFull() => currentWinners >= maxWinners;
}
yes