import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class RingtoneHelper {
  static final RingtoneHelper _instance = RingtoneHelper._internal();
  factory RingtoneHelper() => _instance;
  RingtoneHelper._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> start() async {
    if (_isPlaying) return; // 🔒 debounce

    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        androidAudioAttributes: AndroidAudioAttributes(
          usage: AndroidAudioUsage.notificationRingtone,
          contentType: AndroidAudioContentType.sonification,
        ),
      ),
    );

    await _player.setAsset('assets/driver_ringtone.mp3');
    _player.setLoopMode(LoopMode.one);
    await _player.play();

    _isPlaying = true;
  }

  Future<void> stop() async {
    if (!_isPlaying) return;

    await _player.stop();
    _isPlaying = false;
  }
}

