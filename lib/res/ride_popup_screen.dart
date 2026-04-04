// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
//
// class RidePopupScreen extends StatefulWidget {
//   final Map<String, dynamic> data;
//
//   const RidePopupScreen({super.key, required this.data});
//
//   @override
//   State<RidePopupScreen> createState() => _RidePopupScreenState();
// }
//
// class _RidePopupScreenState extends State<RidePopupScreen>
//     with SingleTickerProviderStateMixin {
//   int totalSeconds = 15;
//   int currentSeconds = 15;
//   Timer? timer;
//
//   double dragPosition = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }
//
//   void startTimer() {
//     timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       if (currentSeconds == 0) {
//         Navigator.pop(context);
//         t.cancel();
//       } else {
//         setState(() => currentSeconds--);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }
//
//   double get progress => currentSeconds / totalSeconds;
//
//   @override
//   Widget build(BuildContext context) {
//     final pickup = widget.data['pickup_address'] ?? "N/A";
//     final drop = widget.data['drop_address'] ?? "N/A";
//     final amount = widget.data['amount'] ?? "0";
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 400),
//           curve: Curves.easeOut,
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//
//               /// 🔥 Circular Timer
//               Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   SizedBox(
//                     height: 100,
//                     width: 100,
//                     child: CustomPaint(
//                       painter: CircleTimerPainter(progress),
//                     ),
//                   ),
//                   Text(
//                     "$currentSeconds",
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold),
//                   )
//                 ],
//               ),
//
//               const SizedBox(height: 20),
//
//               const Text(
//                 "New Ride Request",
//                 style: TextStyle(color: Colors.white, fontSize: 20),
//               ),
//
//               const SizedBox(height: 20),
//
//               /// Ride Card
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1E1E1E),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Column(
//                   children: [
//                     rowItem(Icons.circle, Colors.green, pickup),
//                     const SizedBox(height: 15),
//                     rowItem(Icons.location_on, Colors.red, drop),
//
//                     const SizedBox(height: 20),
//
//                     Text(
//                       "₹ $amount",
//                       style: const TextStyle(
//                           color: Colors.amber,
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const Spacer(),
//
//               /// 🔥 Swipe Button
//               GestureDetector(
//                 onHorizontalDragUpdate: (details) {
//                   setState(() {
//                     dragPosition += details.delta.dx;
//                     if (dragPosition < 0) dragPosition = 0;
//                   });
//                 },
//                 onHorizontalDragEnd: (details) {
//                   if (dragPosition > 200) {
//                     // ACCEPT
//                     timer?.cancel();
//                     Navigator.pop(context);
//                   } else {
//                     setState(() => dragPosition = 0);
//                   }
//                 },
//                 child: Container(
//                   height: 60,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade800,
//                     borderRadius: BorderRadius.circular(40),
//                   ),
//                   child: Stack(
//                     children: [
//                       Center(
//                         child: Text(
//                           "Swipe to Accept",
//                           style: TextStyle(color: Colors.white70),
//                         ),
//                       ),
//
//                       Positioned(
//                         left: dragPosition,
//                         child: Container(
//                           height: 60,
//                           width: 60,
//                           decoration: BoxDecoration(
//                             color: Colors.green,
//                             borderRadius: BorderRadius.circular(40),
//                           ),
//                           child: const Icon(Icons.arrow_forward,
//                               color: Colors.white),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               /// Reject Button
//               TextButton(
//                 onPressed: () {
//                   timer?.cancel();
//                   Navigator.pop(context);
//                 },
//                 child: const Text("Reject",
//                     style: TextStyle(color: Colors.red)),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget rowItem(IconData icon, Color color, String text) {
//     return Row(
//       children: [
//         Icon(icon, color: color, size: 14),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(text, style: const TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }
// }
//
// /// 🔥 Circle Painter
// class CircleTimerPainter extends CustomPainter {
//   final double progress;
//
//   CircleTimerPainter(this.progress);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final bgPaint = Paint()
//       ..color = Colors.grey.shade800
//       ..strokeWidth = 6
//       ..style = PaintingStyle.stroke;
//
//     final fgPaint = Paint()
//       ..color = Colors.green
//       ..strokeWidth = 6
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;
//
//     canvas.drawCircle(size.center(Offset.zero), size.width / 2, bgPaint);
//
//     double sweep = 2 * pi * progress;
//
//     canvas.drawArc(
//       Rect.fromLTWH(0, 0, size.width, size.height),
//       -pi / 2,
//       sweep,
//       false,
//       fgPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }