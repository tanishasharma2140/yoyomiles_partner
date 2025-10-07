import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class Utils{
   static void showSuccessMessage(BuildContext context, String message) {
     _showFlushBar(context, message, Colors.green, Icons.check_circle);
   }

   static void showErrorMessage(BuildContext context, String message) {
     _showFlushBar(context, message, Colors.redAccent, Icons.error);
   }
   static void _showFlushBar(
       BuildContext context,
       String message,
       Color backgroundColor,
       IconData icon,
       ) {
     Flushbar(
       message: message,
       backgroundColor: backgroundColor,
       duration: const Duration(seconds: 5),
       margin: const EdgeInsets.all(8),
       borderRadius: BorderRadius.circular(8),
       icon: Icon(
         icon,
         color: Colors.white,
       ),
       mainButton: IconButton(
         icon: const Icon(
           Icons.close,
           color: Colors.white,
         ),
         onPressed: () {
           Navigator.of(context).pop();
         },
       ),
       flushbarPosition: FlushbarPosition.TOP,
     ).show(context);
   }
}
// import 'dart:async';
//
// import 'package:flutter/material.dart';
//
// class Utils {
//   static OverlayEntry? _overlayEntry;
//   static bool _isShowing = false;
//
//   static void show(String message, BuildContext context,{Color? color}) {
//     if (_isShowing) {
//       _overlayEntry?.remove();
//     }
//
//     _overlayEntry = OverlayEntry(
//       builder: (BuildContext context) => Center(
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//             decoration: BoxDecoration(
//               color: color??Colors.black.withOpacity(0.8),
//               borderRadius: BorderRadius.circular(24.0),
//             ),
//             child: Text(
//               message,
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//         ),
//       ),
//     );
//
//     Overlay.of(context).insert(_overlayEntry!);
//     _isShowing = true;
//
//     _startTimer();
//   }
//
//   static void _startTimer() {
//     Timer(const Duration(seconds: 2), () {
//       if (_overlayEntry != null) {
//         _overlayEntry!.remove();
//         _isShowing = false;
//       }
//     });
//   }}