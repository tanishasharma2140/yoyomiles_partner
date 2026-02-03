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
    if (overlayState == null) return;

    _isShowing = true;

    _overlayEntry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            width: MediaQuery.of(overlayState.context).size.width * 0.92,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🚖 Title
                Row(
                  children: const [
                    Icon(Icons.local_taxi, color: Colors.amber, size: 26),
                    SizedBox(width: 8),
                    Text(
                      "New Ride Request",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /// 📍 Pickup
                _locationTile(
                  icon: Icons.radio_button_checked,
                  iconColor: Colors.green,
                  title: "Pickup",
                  value: ride['pickup_address'] ?? "N/A",
                ),

                const SizedBox(height: 10),

                /// 📍 Drop
                _locationTile(
                  icon: Icons.location_on,
                  iconColor: Colors.red,
                  title: "Drop",
                  value: ride['drop_address'] ?? "N/A",
                ),

                const SizedBox(height: 14),

                /// 📏 Distance
                Row(
                  children: [
                    const Icon(Icons.social_distance,
                        size: 18, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      "${ride['distance'] ?? 0} km",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                /// ✅ / ❌ Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          hide();
                          onReject();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Reject",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          hide();
                          onAccept();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          "Accept Ride",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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

  /// 🔹 reusable tile
  static Widget _locationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
