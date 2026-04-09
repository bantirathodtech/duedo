import 'package:vibration/vibration.dart';

class HapticService {
  /// A light, celebratory double-tap for clearing EMIs or hitting milestones.
  static Future<void> victoryPop() async {
    if (await Vibration.hasVibrator()) {
      if (await Vibration.hasAmplitudeControl()) {
        await Vibration.vibrate(duration: 10, amplitude: 128);
        await Future.delayed(const Duration(milliseconds: 50));
        await Vibration.vibrate(duration: 15, amplitude: 200);
      } else {
        await Vibration.vibrate(duration: 50);
      }
    }
  }

  /// A heavy, sharp thud for "Savage" or high-priority alerts.
  static Future<void> savageThud() async {
    if (await Vibration.hasVibrator()) {
      if (await Vibration.hasAmplitudeControl()) {
        await Vibration.vibrate(duration: 80, amplitude: 255);
      } else {
        await Vibration.vibrate(duration: 150);
      }
    }
  }

  /// A very subtle click for minor UI interactions.
  static Future<void> subtleClick() async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: 5, amplitude: 60);
    }
  }

  /// A pulsating warning wave for 1-day reminders or critical dues.
  static Future<void> warningWave() async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(pattern: [0, 50, 20, 100, 20, 150]);
    }
  }

  // Legacy compatibility wrappers
  static void selection() => subtleClick();
  static void light() => subtleClick();
  static void medium() => Vibration.vibrate(duration: 50);
  static void heavy() => savageThud();
  static void success() => victoryPop();
  static void error() => warningWave();
  static void warning() => subtleClick(); // Compatibility
}
