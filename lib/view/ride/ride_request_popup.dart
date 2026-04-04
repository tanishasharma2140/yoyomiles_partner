// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:yoyomiles_partner/res/sizing_const.dart';
// import 'package:yoyomiles_partner/view_model/assign_ride_view_model.dart';
// import 'package:yoyomiles_partner/view_model/driver_ignored_ride_view_model.dart';
// import 'package:yoyomiles_partner/view_model/ride_view_model.dart';
//
// class RideRequestPopup extends StatefulWidget {
//   final Map<String, dynamic> rideData;
//   const RideRequestPopup({super.key, required this.rideData});
//
//   @override
//   State<RideRequestPopup> createState() => _RideRequestPopupState();
// }
//
// class _RideRequestPopupState extends State<RideRequestPopup> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   int _secondsRemaining = 30;
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 30),
//     );
//     _controller.reverse(from: 1.0);
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_secondsRemaining > 0) {
//         setState(() {
//           _secondsRemaining--;
//         });
//       } else {
//         _onIgnore();
//       }
//     });
//   }
//
//   void _onAccept() async {
//     _timer?.cancel();
//     final assignVm = Provider.of<AssignRideViewModel>(context, listen: false);
//     final rideVm = Provider.of<RideViewModel>(context, listen: false);
//
//     rideVm.stopRideRingtone();
//
//     final String orderId = widget.rideData['order_id']?.toString() ?? widget.rideData['id']?.toString() ?? "";
//
//     Navigator.pop(context); // Close Popup
//     await assignVm.assignRideApi(context, 1, orderId, widget.rideData);
//   }
//
//   void _onIgnore() async {
//     _timer?.cancel();
//     final rideVm = Provider.of<RideViewModel>(context, listen: false);
//     final ignoreVm = Provider.of<DriverIgnoredRideViewModel>(context, listen: false);
//
//     rideVm.stopRideRingtone();
//
//     final String orderId = widget.rideData['order_id']?.toString() ?? widget.rideData['id']?.toString() ?? "";
//
//     if (mounted) {
//       Navigator.pop(context); // Close Popup
//     }
//
//     if (orderId.isNotEmpty) {
//       await ignoreVm.driverIgnoredRideApi(context: context, orderId: orderId);
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       insetPadding: const EdgeInsets.all(20),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           color: Colors.white,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   "New Ride Request",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
//                 ),
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     CircularProgressIndicator(
//                       value: _controller.value,
//                       strokeWidth: 4,
//                       backgroundColor: Colors.grey.shade200,
//                       valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
//                     ),
//                     Text("$_secondsRemaining", style: const TextStyle(fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ],
//             ),
//             const Divider(height: 30),
//             _buildInfoRow(Icons.location_on, "Pickup", widget.rideData['pickup_address'] ?? "N/A", Colors.green),
//             const SizedBox(height: 15),
//             _buildInfoRow(Icons.flag, "Drop", widget.rideData['drop_address'] ?? "N/A", Colors.red),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("Estimated Fare", style: TextStyle(color: Colors.grey)),
//                     Text("₹${widget.rideData['amount'] ?? '0'}",
//                       style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
//                   ],
//                 ),
//                 if (widget.rideData['distance'] != null)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       const Text("Distance", style: TextStyle(color: Colors.grey)),
//                       Text("${widget.rideData['distance']} km",
//                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//                     ],
//                   ),
//               ],
//             ),
//             const SizedBox(height: 30),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: _onIgnore,
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       side: const BorderSide(color: Colors.red),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: const Text("IGNORE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//                 const SizedBox(width: 15),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _onAccept,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: const Text("ACCEPT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String title, String value, Color color) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, color: color, size: 24),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//               Text(value, style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
