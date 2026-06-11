import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final AudioPlayer _sonarPlayer = AudioPlayer();

  static Future<void> playHit() async {
    try {
      await _sfxPlayer.play(AssetSource('sounds/hit.wav')); // Reverted swap
      await Future.any([
        _sfxPlayer.onPlayerComplete.first,
        Future.delayed(const Duration(seconds: 3)) // Safety timeout
      ]);
    } catch (e) {
      SystemSound.play(SystemSoundType.alert);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  static Future<void> playMiss() async {
    try {
      await _sfxPlayer.play(AssetSource('sounds/miss.wav')); // Reverted swap
      await Future.any([
        _sfxPlayer.onPlayerComplete.first,
        Future.delayed(const Duration(seconds: 3)) // Safety timeout
      ]);
    } catch (e) {
      SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  static Future<void> playComputerHit() async {
    try {
      await _sfxPlayer.play(AssetSource('sounds/computer_hit.wav'));
      await Future.any([
        _sfxPlayer.onPlayerComplete.first,
        Future.delayed(const Duration(seconds: 3))
      ]);
    } catch (e) {
      SystemSound.play(SystemSoundType.alert);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  static Future<void> playComputerMiss() async {
    try {
      await _sfxPlayer.play(AssetSource('sounds/computer_miss.wav'));
      await Future.any([
        _sfxPlayer.onPlayerComplete.first,
        Future.delayed(const Duration(seconds: 3))
      ]);
    } catch (e) {
      SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  static void playSonar() async {
    try {
      _sonarPlayer.setReleaseMode(ReleaseMode.loop);
      await _sonarPlayer.play(AssetSource('sounds/sonar.wav'));
    } catch (e) {
      // Ignored
    }
  }

  static void stopSonar() async {
    try {
      await _sonarPlayer.stop();
    } catch (e) {
      // Ignored
    }
  }
}
