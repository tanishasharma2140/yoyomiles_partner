import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';

class OverlayScreen extends StatefulWidget {
  const OverlayScreen({super.key});

  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
  Map<String, dynamic>? rideData;
  // 🔥 Define MethodChannel to bring app to front
  static const platform = MethodChannel('yoyomiles_partner/app_retain');

  @override
  void initState() {
    super.initState();
    print("🎨 OverlayScreen InitState called");
    
    // Listen for data
    FlutterOverlayWindow.overlayListener.listen((data) {
      print("📥 Overlay received data: $data");
      if (data != null) {
        setState(() {
          try {
            if (data is String) {
              rideData = jsonDecode(data);
            } else if (data is Map) {
              rideData = Map<String, dynamic>.from(data);
            }
          } catch (e) {
            print("❌ Error parsing overlay data: $e");
          }
        });
      }
    });
  }

  Future<void> _openApp() async {
    try {
      await platform.invokeMethod('openApp');
    } catch (e) {
      debugPrint("Error opening app: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug: If rideData is null, show a placeholder or just a message
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3), // Make it slightly visible for debugging
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: PortColor.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: rideData == null 
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("Loading Request...", style: TextStyle(color: Colors.black)),
                    ],
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: const Icon(Icons.person, size: 40, color: Colors.white),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rideData?['sender_name']?.toString() ?? "New Ride Request",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  rideData?['pickup_address']?.toString() ?? "Pickup location not provided",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () {
                              FlutterOverlayWindow.closeOverlay();
                              FlutterBackgroundService().invoke('STOP_RINGTONE');
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.black26, height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rideData?['sender_phone']?.toString() ?? "N/A",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const Text(
                                "New Request Incoming",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "₹${rideData?['amount'] ?? '0'}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                print("❌ Overlay Reject Pressed");
                                await FlutterOverlayWindow.closeOverlay();
                                FlutterBackgroundService().invoke('REJECT_RIDE_FROM_OVERLAY', rideData);
                                FlutterBackgroundService().invoke('STOP_RINGTONE');
                              },
                              child: const Text("REJECT"),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade800,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                print("✅ Overlay Accept Pressed");
                                await FlutterOverlayWindow.closeOverlay();
                                FlutterBackgroundService().invoke('ACCEPT_RIDE_FROM_OVERLAY', rideData);
                                FlutterBackgroundService().invoke('STOP_RINGTONE');

                                // 🔥 App ko foreground mein lane ka custom method call
                                await _openApp();
                              },
                              child: const Text("ACCEPT"),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
