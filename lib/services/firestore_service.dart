import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/pool.dart';
import '../models/runner.dart';
import '../models/catch_record.dart';

class FirestoreService {
  FirestoreService._privateConstructor();
  static final FirestoreService instance = FirestoreService._privateConstructor();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User Methods
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _db.collection('users').doc(profile.uid).set(profile.toJson());
    } catch (e) {
      throw 'Failed to create user profile.';
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      throw 'Failed to update user profile.';
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserProfile.fromJson(doc.data()!);
    } catch (e) {
      throw 'Failed to fetch user profile.';
    }
  }

  Future<void> updateWallet(String uid, double amount) async {
    try {
      await _db.collection('users').doc(uid).update({'walletBalance': amount});
    } catch (e) {
      throw 'Failed to update wallet.';
    }
  }

  // Pool Methods
  Stream<List<Pool>> getActivePools(String city) {
    return _db.collection('pools')
      .where('city', isEqualTo: city)
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((snap) => snap.docs.map((doc) => Pool.fromJson(doc.data())).toList());
  }

  Future<Pool?> getCurrentPool(String city) async {
    try {
      final snap = await _db.collection('pools')
        .where('city', isEqualTo: city)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
      if (snap.docs.isEmpty) return null;
      return Pool.fromJson(snap.docs.first.data());
    } catch (e) {
      throw 'Failed to fetch current pool.';
    }
  }

  Future<void> updatePoolWinners(String poolId, int winners) async {
    try {
      await _db.collection('pools').doc(poolId).update({'currentWinners': winners});
    } catch (e) {
      throw 'Failed to update pool winners.';
    }
  }

  // Runner Methods
  Stream<List<Runner>> getActiveRunners(String city) {
    return _db.collection('runners')
      .where('city', isEqualTo: city)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => Runner.fromJson(doc.data())).toList());
  }

  Future<void> updateRunnerStatus(String runnerId, bool isActive) async {
    try {
      await _db.collection('runners').doc(runnerId).update({'isActive': isActive});
    } catch (e) {
      throw 'Failed to update runner status.';
    }
  }

  // Catch Methods
  Future<void> recordCatch(CatchRecord record) async {
    try {
      await _db.collection('catches').doc(record.id).set(record.toJson());
    } catch (e) {
      throw 'Failed to record catch.';
    }
  }

  Stream<List<CatchRecord>> getUserCatchHistory(String userId) {
    return _db.collection('catches')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => CatchRecord.fromJson(doc.data())).toList());
  }
}
