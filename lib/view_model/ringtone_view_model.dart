import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class RingtoneViewModel with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRinging = false;

  bool get isRinging => _isRinging;

  Future<void> playRingtone() async {
    if (_isRinging) return;

    try {
      await _audioPlayer.setAudioContext(
        const AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            usageType: AndroidUsageType.alarm,
            contentType: AndroidContentType.music,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(),
        ),
      );

      await _audioPlayer.play(
        AssetSource("driver_ringtone.mp3"),
        volume: 1.0,
      );

      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      _isRinging = true;
      notifyListeners();
    } catch (e) {
      print("❌ ringtone error → $e");
    }
  }

  Future<void> stopRingtone() async {
    if (!_isRinging) return;

    try {
      await _audioPlayer.stop();
      _isRinging = false;
      notifyListeners();
    } catch (e) {
      print("❌ stop error → $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
}
