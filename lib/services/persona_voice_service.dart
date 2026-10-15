import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final personaVoiceServiceProvider = Provider((ref) => PersonaVoiceService());

class PersonaVoiceService {
  final _random = Random();

  String getDailyHeroQuote(bool isSavage) {
    if (isSavage) {
      const savageQuotes = [
        "The bank's compound interest meter is ticking. Let's punch it in the teeth today.",
        "Your debt thinks it owns you. Prove it wrong before 9:00 PM.",
        "That impulse coffee isn't a treat, it's a tax on your patience. Stay hungry for freedom.",
        "No excuses today. Wealthy people don't sleep on their obligations.",
        "Compound interest is either your loyal servant or your merciless master. Choose.",
      ];
      return savageQuotes[_random.nextInt(savageQuotes.length)];
    } else {
      const zenQuotes = [
        "True wealth is quiet peace of mind. Every intentional choice brings you closer.",
        "A river cuts through rock not by power, but by persistence. Honor your journey.",
        "Today, give yourself the gift of zero financial anxiety. Breathe and stay steady.",
        "Every debt cleared is a chain removed from your future self.",
        "Simplicity and discipline create the most enduring abundance.",
      ];
      return zenQuotes[_random.nextInt(zenQuotes.length)];
    }
  }

  String getImpulseCoolingPrompt(bool isSavage, String item, double amount) {
    if (isSavage) {
      return "Step away from the checkout! Cooling '$item' (₹${amount.toInt()}) for 24 hours. Your future self deserves freedom, not quick buyer's remorse.";
    } else {
      return "Desire is a visitor, not your master. Let '$item' rest in the cooling vault for 24 hours while you reflect with clarity.";
    }
  }

  String getSnowflakeWinQuote(bool isSavage, double interestKilled, int daysSaved) {
    if (isSavage) {
      return "BOOM! Slayed ₹${interestKilled.toInt()} of future bank interest and shaved $daysSaved days off loan slavery! Bankers are in tears.";
    } else {
      return "Remarkable mindful progress. You have dissolved ₹${interestKilled.toInt()} in interest and brought your freedom $daysSaved days closer.";
    }
  }

  String getRingsCompleteCelebration(bool isSavage, int streak) {
    if (isSavage) {
      return "🔥 ALL 3 RINGS DESTROYED! $streak-day streak locked in. You are operating like the 1% today.";
    } else {
      return "✨ Harmonic balance reached. All 3 daily rings completed with a $streak-day streak of mindful stewardship.";
    }
  }
}
