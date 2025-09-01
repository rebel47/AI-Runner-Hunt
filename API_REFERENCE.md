# API Reference: Cloud Functions

## Endpoints

### POST /claimRunner
- Description: Claim a runner after catch challenge
- Auth: Required
- Params: runnerId, photoUrl, userLat, userLng, timestamp
- Returns: success, reward

### Scheduled /runnerSimulation
- Description: Simulates runner movement every 5 seconds
- Auth: Internal
- Params: None
- Returns: None

## Error Codes
- unauthenticated
- not-found
- invalid-argument
- already-exists
- failed-precondition
- deadline-exceeded
- permission-denied
- internal

## Usage
- All endpoints require authentication
- See Firestore rules for data access
