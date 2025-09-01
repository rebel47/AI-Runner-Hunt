import 'package:flutter/material.dart';

class FloatingGlassPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  const FloatingGlassPanel({required this.child, this.blur = 10, this.opacity = 0.3, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          color: Colors.white.withOpacity(opacity),
          child: child,
        ),
      ),
    );
  }
}
