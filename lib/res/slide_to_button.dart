import 'package:flutter/material.dart';

class SlideToButton extends StatefulWidget {
  final String title;
  final VoidCallback onAccepted;

  const SlideToButton({
    super.key,
    required this.onAccepted,
    required this.title,
  });

  @override
  State<SlideToButton> createState() => SlideToButtonState();
}

class SlideToButtonState extends State<SlideToButton> {
  double _dragPosition = 0.0;
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width - 60;
    final double maxDrag = width - 60;
    double progress = (_dragPosition / maxDrag).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragPosition += details.delta.dx;
          if (_dragPosition < 0) _dragPosition = 0;
          if (_dragPosition > maxDrag) _dragPosition = maxDrag;
        });
      },
      onHorizontalDragEnd: (_) {
        if (_dragPosition > maxDrag * 0.7) {
          setState(() => _accepted = true);
          Future.delayed(const Duration(milliseconds: 300), () {
            widget.onAccepted();
            setState(() {
              _dragPosition = 0;
              _accepted = false;
            });
          });
        } else {
          setState(() => _dragPosition = 0);
        }
      },
      child: Container(
        width: width,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(35),
        ),
        child: Stack(
          children: [
            // Gradient fill
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: progress * width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                gradient: const LinearGradient(
                  colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                ),
              ),
            ),
            // Center text
            Center(
              child: Text(
                _accepted ? "Accepted!" : widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),

            // Sliding knob
            AnimatedPositioned(
              duration: const Duration(milliseconds: 90),
              left: _dragPosition,
              top: 4,
              bottom: 4,
              child: Container(
                width: 47,
                height: 47,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.green,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
