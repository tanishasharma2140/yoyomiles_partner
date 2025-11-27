import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircularWaveAnimation extends StatefulWidget {
  final double size;          // Total size of square area
  final Color color;          // Wave color (fill color)
  final Widget? child;        // Center widget (icon / image)
  final int waveCount;        // Number of waves
  final Duration duration;    // Total animation duration

  const CircularWaveAnimation({
    super.key,
    this.size = 200,
    this.color = Colors.white, // default white
    this.child,
    this.waveCount = 3,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<CircularWaveAnimation> createState() => _CircularWaveAnimationState();
}

class _CircularWaveAnimationState extends State<CircularWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(); // infinite loop
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(
              progress: _controller.value,
              waveCount: widget.waveCount,
              color: widget.color,
            ),
            child: Center(
              child: widget.child ??
                  Container(
                    width: widget.size * 0.22,
                    height: widget.size * 0.22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.person_pin_circle,
                      size: 32,
                      color: Colors.green,
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress; // 0 → 1
  final int waveCount;
  final Color color;

  _WavePainter({
    required this.progress,
    required this.waveCount,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = math.min(size.width, size.height) / 2;

    for (int i = 0; i < waveCount; i++) {
      // Each wave shifted in time
      final waveProgress = (progress + (i / waveCount)) % 1.0;

      // Ease-out curve: fast at start, slow at end
      final eased = Curves.easeOut.transform(waveProgress);

      final radius = eased * maxRadius;

      // Fade out as it expands
      final opacity = (1 - waveProgress).clamp(0.0, 1.0);

      final paint = Paint()
        ..style = PaintingStyle.fill   // 🔥 filled circle, not border
        ..color = color.withOpacity(opacity * 0.35); // soft transparent fill

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveCount != waveCount ||
        oldDelegate.color != color;
  }
}
