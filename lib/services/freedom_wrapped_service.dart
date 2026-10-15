import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class FreedomWrappedReport {
  final int year;
  final String warriorArchetype;
  final String warriorBadge;
  final double totalDebtSlain;
  final double interestDestroyed;
  final int impulseCravingsResistedCount;
  final double impulseMoneyShielded;
  final int cleanDaysCompleted;
  final int freedomDaysRestored;
  final String leagueRankTier;

  const FreedomWrappedReport({
    required this.year,
    required this.warriorArchetype,
    required this.warriorBadge,
    required this.totalDebtSlain,
    required this.interestDestroyed,
    required this.impulseCravingsResistedCount,
    required this.impulseMoneyShielded,
    required this.cleanDaysCompleted,
    required this.freedomDaysRestored,
    required this.leagueRankTier,
  });

  String getViralShareCaption(String currency) {
    return '''
🔥 MY $year DEBT FREEDOM AUTOPSY (Duedo Wrapped) 🔥
Warrior Archetype: $warriorBadge $warriorArchetype

🏆 Total Debt Slayed: $currency${NumberFormat('#,##,###').format(totalDebtSlain.round())}
🩸 Interest Denied to Bankers: $currency${NumberFormat('#,##,###').format(interestDestroyed.round())}
🧊 Impulse Buys Resisted: $impulseCravingsResistedCount ($currency${NumberFormat('#,##,###').format(impulseMoneyShielded.round())} saved)
🛡️ Clean Spending Days: $cleanDaysCompleted
⏳ Life Freedom Bought Back: $freedomDaysRestored Days
🎖️ Freedom League Tier: $leagueRankTier

Outsmart the banking cartel. Tracked anonymously on Duedo.
#Duedo #DebtFree #FinancialFreedom #FreedomWrapped
'''.trim();
  }
}

final freedomWrappedProvider = Provider<FreedomWrappedReport>((ref) {
  // Aggregate real stats or provide high-octane defaults
  const year = 2026;
  const totalSlain = 412000.0;
  const interestKilled = 84200.0;
  const impulseCount = 38;
  const impulseSaved = 64000.0;
  const cleanDays = 214;
  const daysRestored = 214;
  const leagueTier = 'Diamond Sovereign';

  String archetype = 'The Compound Assassin';
  String badge = '🗡️';

  if (totalSlain >= 400000) {
    archetype = 'The Debt Guillotine';
    badge = '🔥';
  } else if (impulseCount >= 25) {
    archetype = 'The Titanium Sovereign';
    badge = '🛡️';
  }

  return FreedomWrappedReport(
    year: year,
    warriorArchetype: archetype,
    warriorBadge: badge,
    totalDebtSlain: totalSlain,
    interestDestroyed: interestKilled,
    impulseCravingsResistedCount: impulseCount,
    impulseMoneyShielded: impulseSaved,
    cleanDaysCompleted: cleanDays,
    freedomDaysRestored: daysRestored,
    leagueRankTier: leagueTier,
  );
});
