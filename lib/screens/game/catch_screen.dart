import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/runner.dart';
import '../../models/catch_record.dart';
import '../../services/location_service.dart';
import '../../widgets/catch_challenge.dart';

class CatchScreen extends StatefulWidget {
  final Runner runner;
  final Position userPosition;
  const CatchScreen({required this.runner, required this.userPosition, super.key});

  @override
  State<CatchScreen> createState() => _CatchScreenState();
}

class _CatchScreenState extends State<CatchScreen> {
  bool _challengeStarted = false;
  bool _challengeSuccess = false;
  bool _challengeFailed = false;
  bool _photoTaken = false;
  File? _photoFile;
  String? _error;
  int _timeLeft = 30;
  Timer? _timer;
  bool _cooldown = false;
  String? _reward;

  @override
  void initState() {
    super.initState();
    _startChallenge();
  }

  void _startChallenge() {
    setState(() { _challengeStarted = true; });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() { _timeLeft--; });
      if (_timeLeft <= 0) {
        _failCatch('Time expired!');
        timer.cancel();
      }
    });
  }

  Future<void> _takeSelfie() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front, imageQuality: 80);
      if (picked == null) throw 'No photo taken.';
      // TODO: Validate photo quality, embed GPS metadata, compress
      setState(() { _photoFile = File(picked.path); _photoTaken = true; });
      _validateCatch();
    } catch (e) {
      setState(() { _error = e.toString(); });
    }
  }

  Future<void> _validateCatch() async {
    // Real-time distance check
    final pos = await LocationService.instance.getCurrentLocation();
    final dist = LocationService.instance.calculateDistance(
      pos.latitude, pos.longitude, widget.runner.latitude, widget.runner.longitude);
    if (dist > 10) {
      _failCatch('Too far from runner!');
      return;
    }
    // TODO: Validate photo authenticity
    _successCatch();
  }

  void _successCatch() {
    setState(() { _challengeSuccess = true; _reward = '+100 Coins!'; });
    _timer?.cancel();
    // TODO: Save catch record, show animation, enable share
  }

  void _failCatch(String reason) {
    setState(() { _challengeFailed = true; _error = reason; _cooldown = true; });
    _timer?.cancel();
    // TODO: Start cooldown timer
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cooldown) {
      return Scaffold(
        body: Center(child: Text('Cooldown: Try again soon!', style: const TextStyle(color: Colors.red))),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Catch Runner')),
      body: Center(
        child: _challengeFailed
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.close, color: Colors.red, size: 64),
                Text(_error ?? 'Failed!', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
              ],
            )
          : _challengeSuccess
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                  Text('Success!', style: const TextStyle(color: Colors.green)),
                  Text(_reward ?? ''),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Share to social media
                    },
                    child: const Text('Share'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Catch Challenge', style: Theme.of(context).textTheme.titleLarge),
                  Text('Time left: $_timeLeft s'),
                  CatchChallenge(
                    runnerLevel: widget.runner.difficulty.index + 1,
                    onSuccess: _takeSelfie,
                    onFailure: _failCatch,
                  ),
                  if (_photoTaken && _photoFile != null)
                    Image.file(_photoFile!, width: 120, height: 120),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ),
      ),
    );
  }
}
