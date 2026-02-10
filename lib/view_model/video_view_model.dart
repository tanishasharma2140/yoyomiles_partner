import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/video_model.dart';
import 'package:yoyomiles_partner/repo/video_repo.dart';

class VideoViewModel with ChangeNotifier {
  final _videoRepo = VideoRepo();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  VideoModel? _videoModel;
  VideoModel? get videoModel => _videoModel;

  setVehicleData(VideoModel value) {
    _videoModel = value;
    notifyListeners();
  }

  Future<void> videoApi() async {
    setLoading(true);

    _videoRepo.videoApi().then((value) {
      debugPrint('value:$value');
      if (value.success == true) {
        setVehicleData(value);
      }
      setLoading(false);
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }

}
