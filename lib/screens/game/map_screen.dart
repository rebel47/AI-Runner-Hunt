import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../models/runner.dart';
import '../../models/pool.dart';
import '../../services/location_service.dart';
import '../../services/firestore_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _userPosition;
  StreamSubscription<Position>? _positionStream;
  Set<Marker> _markers = {};
  List<Runner> _runners = [];
  Pool? _currentPool;
  bool _loading = true;
  String? _error;
  double? _distanceToNearest;
  bool _showCatchButton = false;
  bool _proximityAlert = false;
  String _mapType = 'normal';

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    try {
      await LocationService.instance.requestPermission();
      _userPosition = await LocationService.instance.getCurrentLocation();
      _positionStream = LocationService.instance.watchPositionStream().listen((pos) {
        setState(() { _userPosition = pos; });
        _updateDistanceAndProximity();
      });
      // FIX: Use a default city or fetch from user profile/app state
      String city = 'New York'; // Replace with actual city from user profile
      FirestoreService.instance.getActiveRunners(city).listen((runners) {
        setState(() { _runners = runners; });
        _updateMarkers();
        _updateDistanceAndProximity();
      });
      _currentPool = await FirestoreService.instance.getCurrentPool(city);
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _updateMarkers() {
    Set<Marker> markers = {};
    if (_userPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('user'),
        position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'You'),
      ));
    }
    for (final runner in _runners) {
      markers.add(Marker(
        markerId: MarkerId(runner.id),
        position: LatLng(runner.latitude, runner.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(_getRunnerHue(runner.difficulty)),
        infoWindow: InfoWindow(
          title: 'AI Runner',
          snippet: 'Difficulty: ${runner.difficulty.name}',
          onTap: () => _showRunnerInfo(runner),
        ),
      ));
    }
    setState(() { _markers = markers; });
  }

  double _getRunnerHue(RunnerDifficulty difficulty) {
    switch (difficulty) {
      case RunnerDifficulty.easy: return BitmapDescriptor.hueGreen;
      case RunnerDifficulty.medium: return BitmapDescriptor.hueOrange;
      case RunnerDifficulty.hard: return BitmapDescriptor.hueRed;
    }
  }

  void _updateDistanceAndProximity() {
    if (_userPosition == null || _runners.isEmpty) {
      setState(() { _distanceToNearest = null; _showCatchButton = false; _proximityAlert = false; });
      return;
    }
    double minDist = double.infinity;
    bool catchable = false;
    bool proximity = false;
    for (final runner in _runners) {
      final dist = LocationService.instance.calculateDistance(
        _userPosition!.latitude, _userPosition!.longitude, runner.latitude, runner.longitude);
      if (dist < minDist) minDist = dist;
      if (dist <= 10) catchable = true;
      if (dist <= 50) proximity = true;
    }
    setState(() {
      _distanceToNearest = minDist;
      _showCatchButton = catchable;
      _proximityAlert = proximity;
    });
  }

  void _showRunnerInfo(Runner runner) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AI Runner', style: Theme.of(context).textTheme.titleLarge),
            Text('Difficulty: ${runner.difficulty.name}'),
            Text('Speed: ${runner.speed.toStringAsFixed(2)} m/s'),
            Text('Last caught by: ${runner.lastCaughtBy ?? 'N/A'}'),
            Text('Updated: ${runner.lastUpdated}'),
          ],
        ),
      ),
    );
  }

  void _centerOnUser() {
    if (_mapController != null && _userPosition != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(
        LatLng(_userPosition!.latitude, _userPosition!.longitude),
      ));
    }
  }

  void _toggleMapType() {
    setState(() {
      _mapType = _mapType == 'normal' ? 'satellite' : 'normal';
    });
    // FIX: Use setState to update mapType, GoogleMap widget will reflect change
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_error')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Runner Hunt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnUser,
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _toggleMapType,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _userPosition != null
                  ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
                  : const LatLng(0, 0),
              zoom: 16,
            ),
            mapType: _mapType == 'normal' ? MapType.normal : MapType.satellite,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
              // Apply custom dark style here if needed
            },
            onCameraMove: (position) {},
          ),
          if (_currentPool != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text('Current Pool: ${_currentPool!.city}', style: Theme.of(context).textTheme.titleMedium),
                      Text('Prize: ${_currentPool!.prizeAmount}'),
                      Text('Winners: ${_currentPool!.currentWinners}/${_currentPool!.maxWinners}'),
                    ],
                  ),
                ),
              ),
            ),
          if (_distanceToNearest != null)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Nearest Runner: ${_distanceToNearest!.toStringAsFixed(1)} m'),
                ),
              ),
            ),
          if (_proximityAlert)
            Positioned(
              top: 160,
              left: 0,
              right: 0,
              child: Card(
                color: Colors.redAccent,
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Runner nearby! Get ready to catch!', style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            child: _StepCounterWidget(),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: _CompassWidget(),
          ),
        ],
      ),
      floatingActionButton: _showCatchButton
          ? FloatingActionButton.extended(
              onPressed: () {
                // Implement catch logic
              },
              label: const Text('Catch Runner'),
              icon: const Icon(Icons.sports_kabaddi),
            )
          : null,
    );
  }
}

class _StepCounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder for step counter
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Icon(Icons.directions_walk),
            const SizedBox(width: 8),
            Text('Steps: 0'), // Integrate with health service
          ],
        ),
      ),
    );
  }
}

class _CompassWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder for compass
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Icon(Icons.explore),
            const SizedBox(width: 8),
            Text('N'), // Integrate with compass sensor
          ],
        ),
      ),
    );
  }
}
