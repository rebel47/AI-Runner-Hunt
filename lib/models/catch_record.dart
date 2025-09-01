import 'package:cloud_firestore/cloud_firestore.dart';

class CatchRecord {
  final String id;
  final String userId;
  final String runnerId;
  final String photoUrl;
  final double reward;
  final DateTime timestamp;
  final GeoPoint location;

  CatchRecord({
    required this.id,
    required this.userId,
    required this.runnerId,
    required this.photoUrl,
    required this.reward,
    required this.timestamp,
    required this.location,
  });

  factory CatchRecord.fromJson(Map<String, dynamic> json) {
    return CatchRecord(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      runnerId: json['runnerId'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      reward: (json['reward'] ?? 0.0).toDouble(),
      timestamp: (json['timestamp'] is Timestamp)
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      location: json['location'] is GeoPoint
          ? json['location']
          : GeoPoint(
              (json['location']?['latitude'] ?? 0.0).toDouble(),
              (json['location']?['longitude'] ?? 0.0).toDouble(),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'runnerId': runnerId,
      'photoUrl': photoUrl,
      'reward': reward,
      'timestamp': Timestamp.fromDate(timestamp),
      'location': location,
    };
  }
}
