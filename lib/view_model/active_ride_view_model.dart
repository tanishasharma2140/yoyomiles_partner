import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yoyomiles_partner/model/active_ride_model.dart';
import 'package:yoyomiles_partner/repo/active_ride_repo.dart';

class ActiveRideViewModel with ChangeNotifier {
  final _activeRideRepo = ActiveRideRepo();

  bool _loading = false;
  bool get loading => _loading;

  ActiveRideModel? _activeRideModel;
  ActiveRideModel? get activeRideModel => _activeRideModel;

  Stream<DocumentSnapshot>? _rideListener;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setModelData(ActiveRideModel value) {
    _activeRideModel = value;
    notifyListeners();
  }

  /// ✅ Fetch active ride from API
  Future<void> activeRideApi(String driverId) async {
    setLoading(true);
    try {
      final value = await _activeRideRepo.activeRideApi(driverId);
      debugPrint('Active ride API response: $value');

      if (value.status == 200) {
        setModelData(value);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('activeRideApi error: $error');
      }
    } finally {
      setLoading(false);
    }
  }

  /// ✅ Listen for real-time active ride in Firestore
  void listenToActiveRide(String driverId) {
    debugPrint("🎧 Listening for active rides for driverId: $driverId");

    _rideListener = FirebaseFirestore.instance
        .collection('order')
        .where('accepted_driver_id', isEqualTo: driverId)
        .where('ride_status', isEqualTo: 1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final rideData = snapshot.docs.first.data();
        final rideId = snapshot.docs.first.id;
        debugPrint("🚘 Active ride found: $rideId");

        _activeRideModel = ActiveRideModel.fromJson({
          "data": rideData,
          "document_id": rideId,
        });
        notifyListeners();
      } else {
        debugPrint("❌ No active ride found");
        _activeRideModel = null;
        notifyListeners();
      }
    }) as Stream<DocumentSnapshot<Object?>>?;
  }

  void cancelRideListener() {
    _rideListener?.drain();
    _rideListener = null;
    debugPrint("🛑 Active ride listener cancelled");
  }
}
