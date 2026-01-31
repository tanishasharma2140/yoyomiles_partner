import 'package:flutter/material.dart';

class RidePopupHelper {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void show({
    required GlobalKey<NavigatorState> navigatorKey,
    required Map<String, dynamic> ride,
    required VoidCallback onAccept,
    required VoidCallback onReject,
  }) {
    if (_isShowing) return;

    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) {
      debugPrint("❌ Overlay not ready yet");
      return;
    }

    _isShowing = true;

    _overlayEntry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: MediaQuery.of(overlayState.context).size.width * 0.9,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🚖 New Ride Request",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text("Pickup: ${ride['pickup_address']}"),
                Text("Drop: ${ride['drop_address']}"),
                Text("Distance: ${ride['distance']} km"),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          hide();
                          onAccept();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("Accept"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          hide();
                          onReject();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text("Reject"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
  }


  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }
}
