import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String city;
  final double walletBalance;
  final int totalWins;
  final int stepCount;
  final int level;
  final DateTime createdAt;
  final DateTime lastActive;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.city,
    this.walletBalance = 0.0,
    this.totalWins = 0,
    this.stepCount = 0,
    this.level = 1,
    required this.createdAt,
    required this.lastActive,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      city: json['city'] ?? '',
      walletBalance: (json['walletBalance'] ?? 0.0).toDouble(),
      totalWins: json['totalWins'] ?? 0,
      stepCount: json['stepCount'] ?? 0,
      level: json['level'] ?? 1,
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastActive: (json['lastActive'] is Timestamp)
          ? (json['lastActive'] as Timestamp).toDate()
          : DateTime.tryParse(json['lastActive'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'city': city,
      'walletBalance': walletBalance,
      'totalWins': totalWins,
      'stepCount': stepCount,
      'level': level,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? city,
    double? walletBalance,
    int? totalWins,
    int? stepCount,
    int? level,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      city: city ?? this.city,
      walletBalance: walletBalance ?? this.walletBalance,
      totalWins: totalWins ?? this.totalWins,
      stepCount: stepCount ?? this.stepCount,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  static bool isValidName(String name) => name.trim().isNotEmpty;
  static bool isValidCity(String city) => city.trim().isNotEmpty;
}
