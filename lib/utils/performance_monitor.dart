import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

class PerformanceMonitor {
  static final PerformanceMonitor instance = PerformanceMonitor._internal();
  PerformanceMonitor._internal();

  Timer? _fpsTimer;
  int _frameCount = 0;
  double _fps = 0;

  void startFpsMonitoring() {
    _frameCount = 0;
    _fpsTimer?.cancel();
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fps = _frameCount.toDouble();
      log('FPS: $_fps');
      _frameCount = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback(_countFrame);
  }

  void _countFrame(Duration timeStamp) {
    _frameCount++;
    WidgetsBinding.instance.addPostFrameCallback(_countFrame);
  }

  void stopFpsMonitoring() {
    _fpsTimer?.cancel();
  }

  double get fps => _fps;

  // Memory usage tracking
  void logMemoryUsage() {
    // Placeholder: use dart:io or platform channels for actual memory usage
    log('Memory usage: [placeholder]');
  }

  // Network request monitoring
  void logNetworkRequest(String url, int durationMs, int bytes) {
    log('Network: $url, ${durationMs}ms, ${bytes} bytes');
  }

  // Battery drain analysis
  void logBatteryUsage(double percent) {
    log('Battery drain: $percent%');
  }

  // User experience metrics
  void logUxMetric(String metric, dynamic value) {
    log('UX: $metric = $value');
  }
}
