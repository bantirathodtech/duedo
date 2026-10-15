import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MilestoneType {
  debtDestroyer, // First debt paid
  cashflowKing,  // Disposable > 50%
  freedomSeeker, // Freedom < 12 months
  consistencyMaster, // 30 day streak
  sovereignMember, // Net worth inversion: > 50% principal eliminated
}

class Milestone {
  final MilestoneType type;
  final String title;
  final String description;
  final String icon;
  final DateTime? unlockedAt;

  Milestone({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
  });

  Milestone copyWith({DateTime? unlockedAt}) {
    return Milestone(
      type: type,
      title: title,
      description: description,
      icon: icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type.index,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };
}

class MilestoneService {
  static const _key = 'unlocked_milestones';
  
  final List<Milestone> _allMilestones = [
    Milestone(
      type: MilestoneType.debtDestroyer,
      title: 'Debt Destroyer',
      description: 'You paid off your first obligation! The snowball is rolling.',
      icon: '🎯',
    ),
    Milestone(
      type: MilestoneType.cashflowKing,
      title: 'Cashflow King',
      description: 'Your disposable income is now over 50% of your earnings.',
      icon: '👑',
    ),
    Milestone(
      type: MilestoneType.freedomSeeker,
      title: 'Freedom Seeker',
      description: 'Your debt-free date is less than a year away!',
      icon: '🕊️',
    ),
    Milestone(
      type: MilestoneType.consistencyMaster,
      title: 'Consistency Master',
      description: '30-day streak of staying on top of your obligations.',
      icon: '🔥',
    ),
    Milestone(
      type: MilestoneType.sovereignMember,
      title: 'The Sovereign Member',
      description: 'Net Worth Inversion achieved! You have eliminated more than 50% of your total obligations.',
      icon: '👑',
    ),
  ];

  Future<List<Milestone>> getMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    
    final unlockedMap = <int, DateTime>{};
    for (var s in saved) {
      final map = jsonDecode(s);
      unlockedMap[map['type']] = DateTime.parse(map['unlockedAt']);
    }

    return _allMilestones.map((m) {
      if (unlockedMap.containsKey(m.type.index)) {
        return m.copyWith(unlockedAt: unlockedMap[m.type.index]);
      }
      return m;
    }).toList();
  }

  Future<bool> unlockMilestone(MilestoneType type) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    
    // Check if already unlocked
    for (var s in saved) {
      if (jsonDecode(s)['type'] == type.index) return false;
    }

    final newUnlock = jsonEncode({
      'type': type.index,
      'unlockedAt': DateTime.now().toIso8601String(),
    });
    
    saved.add(newUnlock);
    await prefs.setStringList(_key, saved);
    return true;
  }
}

final milestoneServiceProvider = Provider((ref) => MilestoneService());
