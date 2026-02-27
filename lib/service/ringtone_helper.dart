// import 'package:flutter/cupertino.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';
//
// class RingtoneHelper {
//   static final RingtoneHelper _instance = RingtoneHelper._internal();
//   factory RingtoneHelper() => _instance;
//   RingtoneHelper._internal();
//
//   final AudioPlayer _player = AudioPlayer();
//
//   bool _isPlaying = false;
//   bool _isStarting = false;
//
//   /// ✅ ADD THIS GETTER
//   bool get isPlaying => _isPlaying;
//
//   Future<void> start() async {
//     if (_isPlaying || _isStarting) return;
//
//     _isStarting = true;
//
//     try {
//       final session = await AudioSession.instance;
//       await session.configure(
//         const AudioSessionConfiguration(
//           androidAudioAttributes: AndroidAudioAttributes(
//             usage: AndroidAudioUsage.notificationRingtone,
//             contentType: AndroidAudioContentType.sonification,
//           ),
//         ),
//       );
//
//       await _player.setAsset('assets/driver_ringtone.mp3');
//       _player.setLoopMode(LoopMode.one);
//       await _player.play();
//
//       _isPlaying = true;
//     } catch (e) {
//       debugPrint("Ringtone error: $e");
//     } finally {
//       _isStarting = false;
//     }
//   }
//
//   Future<void> stop() async {
//     try {
//       await _player.stop();
//       await _player.seek(Duration.zero);
//     } catch (_) {}
//
//     _isPlaying = false;
//     _isStarting = false;
//   }
//
// }
//
//

import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:vibration/vibration.dart';

class RingtoneHelper {
  static final RingtoneHelper _instance = RingtoneHelper._internal();
  factory RingtoneHelper() => _instance;
  RingtoneHelper._internal() {
    _listenToPlayerState();
  }

  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;
  bool _isStarting = false;

  bool get isPlaying => _isPlaying;

  // 🔥 Listen to real audio state
  void _listenToPlayerState() {
    _player.playerStateStream.listen((state) {
      if (state.playing) {
        debugPrint("🔔 Ringtone STARTED");
        _startVibration();
      } else {
        debugPrint("⛔ Ringtone STOPPED");
        _stopVibration();
      }
    });
  }

  Future<void> start() async {
    if (_isPlaying || _isStarting) {
      debugPrint("🔔 Already playing...");
      return;
    }

    _isStarting = true;

    try {
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

    } catch (e) {
      debugPrint("❌ Ringtone error: $e");
    } finally {
      _isStarting = false;
    }
  }

  Future<void> _startVibration() async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) {
      debugPrint("📳 No vibrator support");
      return;
    }

    debugPrint("📳 Vibration STARTED");

    await Vibration.vibrate(
      pattern: [0, 800, 400, 800],
      repeat: 0,
    );
  }

  void _stopVibration() {
    Vibration.cancel();
    debugPrint("📳 Vibration STOPPED");
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      await _player.seek(Duration.zero);
    } catch (_) {}

    _isPlaying = false;
    _isStarting = false;
  }
}