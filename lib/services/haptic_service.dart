import 'package:flutter/services.dart';

class HapticService {
  static void selection() {
    HapticFeedback.selectionClick();
  }

  static void light() {
    HapticFeedback.lightImpact();
  }

  static void medium() {
    HapticFeedback.mediumImpact();
  }

  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  static void success() {
    HapticFeedback.vibrate(); // Basic for now, but used for success animations
  }

  static void error() {
    // Custom error pattern: 3 quick heavy impacts
    Future.delayed(Duration.zero, () => HapticFeedback.heavyImpact());
    Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.heavyImpact());
    Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact());
  }

  static void warning() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 150), () => HapticFeedback.mediumImpact());
  }
}
