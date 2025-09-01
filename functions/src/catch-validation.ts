import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();
const db = admin.firestore();

// Helper: Calculate distance between two lat/lng
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371000; // meters
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// Helper: Basic photo authenticity check (placeholder)
function isPhotoAuthentic(photoUrl: string): boolean {
  // TODO: Implement actual image analysis
  return !!photoUrl;
}

// Helper: Anti-cheat checks
function detectCheating(user: any, runner: any, catchData: any): boolean {
  // TODO: Implement location spoofing, movement pattern, photo validation
  return false;
}

// Helper: Reward calculation
function calculateReward(runner: any, user: any): number {
  let base = 100;
  if (runner.difficulty === 'medium') base = 200;
  if (runner.difficulty === 'hard') base = 300;
  // Bonus: consecutive catches
  if (user.consecutiveCatches) base *= (1 + user.consecutiveCatches * 0.1);
  // Bonus: daily streak
  if (user.dailyStreak) base *= (1 + user.dailyStreak * 0.05);
  // Bonus: city competition
  if (user.cityBonus) base *= 1.2;
  return Math.floor(base);
}

// Helper: Rate limiting
async function isRateLimited(userId: string): Promise<boolean> {
  // TODO: Implement rate limiting logic
  return false;
}

// claimRunner function
export const claimRunner = functions.https.onCall(async (data, context) => {
  try {
    // 1. User authentication verification
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
    }
    const userId = context.auth.uid;
    const { runnerId, photoUrl, userLat, userLng, timestamp } = data;
    // 2. Server-side distance recalculation
    const runnerDoc = await db.collection('runners').doc(runnerId).get();
    if (!runnerDoc.exists) throw new functions.https.HttpsError('not-found', 'Runner not found.');
    const runner = runnerDoc.data();
    const dist = calculateDistance(userLat, userLng, runner.latitude, runner.longitude);
    if (dist > 10) throw new functions.https.HttpsError('invalid-argument', 'You are too far from the runner.');
    // 3. Photo analysis for authenticity
    if (!isPhotoAuthentic(photoUrl)) throw new functions.https.HttpsError('invalid-argument', 'Photo failed authenticity check.');
    // 4. Rate limiting
    if (await isRateLimited(userId)) throw new functions.https.HttpsError('resource-exhausted', 'Too many catch attempts. Please wait.');
    // 5. Transaction safety for wallet updates
    const userRef = db.collection('users').doc(userId);
    const catchRef = db.collection('catches').doc();
    await db.runTransaction(async (t) => {
      // 6. Duplicate catch prevention
      const existingCatch = await db.collection('catches')
        .where('userId', '==', userId)
        .where('runnerId', '==', runnerId)
        .get();
      if (!existingCatch.empty) throw new functions.https.HttpsError('already-exists', 'You already caught this runner.');
      // 7. Runner status verification
      if (!runner.isActive) throw new functions.https.HttpsError('failed-precondition', 'Runner is not active.');
      // 8. Time window validation
      const now = Date.now();
      if (Math.abs(now - timestamp) > 30000) throw new functions.https.HttpsError('deadline-exceeded', 'Catch attempt expired.');
      // 9. Anti-cheat measures
      if (detectCheating(context.auth, runner, data)) throw new functions.https.HttpsError('permission-denied', 'Cheating detected.');
      // 10. Reward calculation
      const userDoc = await userRef.get();
      const user = userDoc.data();
      const reward = calculateReward(runner, user);
      // 11. Update wallet
      t.update(userRef, { walletBalance: (user.walletBalance || 0) + reward });
      // 12. Mark runner as caught
      t.update(runnerDoc.ref, { isActive: false, lastCaughtBy: userId });
      // 13. Record catch
      t.set(catchRef, {
        id: catchRef.id,
        userId,
        runnerId,
        photoUrl,
        reward,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        location: new admin.firestore.GeoPoint(userLat, userLng),
      });
      // 14. Logging
      console.log(`User ${userId} caught runner ${runnerId} for ${reward} coins.`);
    });
    return { success: true, reward };
  } catch (error: any) {
    console.error('Catch validation error:', error);
    throw new functions.https.HttpsError(error.code || 'internal', error.message || 'Catch failed.');
  }
});
