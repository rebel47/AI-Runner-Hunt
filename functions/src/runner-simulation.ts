import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GeoPoint } from '@google-cloud/firestore';

admin.initializeApp();
const db = admin.firestore();

// City boundaries (example: polygon for New York)
const cityPolygons: Record<string, Array<[number, number]>> = {
  'New York': [
    [40.700292, -74.020325], [40.877483, -73.907005], [40.870028, -73.906158], [40.700292, -74.020325]
  ],
  // Add more cities as needed
};

// Movement patterns
const movementPatterns = ['randomWalker', 'circularPatrol', 'escapeArtist', 'predictable'];

// Helper: Check if point is inside polygon
function isInsidePolygon(lat: number, lng: number, polygon: Array<[number, number]>): boolean {
  let inside = false;
  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const xi = polygon[i][0], yi = polygon[i][1];
    const xj = polygon[j][0], yj = polygon[j][1];
    const intersect = ((yi > lng) !== (yj > lng)) &&
      (lat < (xj - xi) * (lng - yi) / (yj - yi) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

// Helper: Get nearby players
async function getNearbyPlayers(city: string, lat: number, lng: number, radius: number): Promise<any[]> {
  // Query Firestore for players in city within radius
  // Placeholder: implement geospatial query
  return [];
}

// Helper: Get hiding spots
function getHidingSpots(city: string): Array<[number, number]> {
  // Return array of lat/lng hiding spots for city
  return [];
}

// Helper: Smart movement logic
function getNextPosition(runner: any, pattern: string, city: string, players: any[]): { lat: number, lng: number, speed: number, direction: number, hiding: boolean } {
  // Implement smart movement based on pattern, city boundaries, player proximity, hiding spots, etc.
  // Placeholder: random movement within polygon
  let lat = runner.latitude;
  let lng = runner.longitude;
  let speed = runner.speed;
  let direction = runner.direction;
  let hiding = false;
  // TODO: Implement pathfinding, patrols, escape, etc.
  // Simulate movement variance
  lat += (Math.random() - 0.5) * 0.0002;
  lng += (Math.random() - 0.5) * 0.0002;
  // Stay within city boundaries
  if (!isInsidePolygon(lat, lng, cityPolygons[city])) {
    lat = runner.latitude;
    lng = runner.longitude;
  }
  // Simulate hiding
  if (Math.random() < 0.05) hiding = true;
  return { lat, lng, speed, direction, hiding };
}

// Scheduled runner simulation function
export const runnerSimulation = functions.pubsub.schedule('every 5 seconds').onRun(async (context) => {
  try {
    const cities = Object.keys(cityPolygons);
    for (const city of cities) {
      // Get active runners for city
      const runnersSnap = await db.collection('runners').where('city', '==', city).where('isActive', '==', true).get();
      const runners = runnersSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      // Get player count for dynamic difficulty
      const playerCount = 10; // Placeholder: query actual player count
      for (let i = 0; i < runners.length; i++) {
        const runner = runners[i];
        // Assign movement pattern/personality
        const pattern = runner.pattern || movementPatterns[i % movementPatterns.length];
        // Get nearby players
        const players = await getNearbyPlayers(city, runner.latitude, runner.longitude, 0.001);
        // Calculate next position
        const next = getNextPosition(runner, pattern, city, players);
        // Collision detection
        for (let j = 0; j < runners.length; j++) {
          if (i !== j) {
            const other = runners[j];
            const dist = Math.sqrt(Math.pow(next.lat - other.latitude, 2) + Math.pow(next.lng - other.longitude, 2));
            if (dist < 0.0001) {
              // Too close, adjust position
              next.lat += 0.0002;
              next.lng += 0.0002;
            }
          }
        }
        // Update runner in Firestore
        await db.collection('runners').doc(runner.id).update({
          latitude: next.lat,
          longitude: next.lng,
          speed: next.speed,
          direction: next.direction,
          isHiding: next.hiding,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      // Dynamic difficulty adjustment
      // TODO: Adjust runner speed/patterns based on playerCount
    }
  } catch (error) {
    console.error('Runner simulation error:', error);
    // Optionally send error to monitoring/logging service
  }
});
