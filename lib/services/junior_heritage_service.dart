import 'dart:math';

/// A completed or pending chore/quest assigned to a junior account.
class ChoreItem {
  final String id;
  final String title;
  final double rewardAmount;
  final bool isCompleted;
  final bool isVerifiedByParent;
  final DateTime createdAt;

  const ChoreItem({
    required this.id,
    required this.title,
    required this.rewardAmount,
    this.isCompleted = false,
    this.isVerifiedByParent = false,
    required this.createdAt,
  });

  ChoreItem copyWith({
    String? id,
    String? title,
    double? rewardAmount,
    bool? isCompleted,
    bool? isVerifiedByParent,
    DateTime? createdAt,
  }) {
    return ChoreItem(
      id: id ?? this.id,
      title: title ?? this.title,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      isCompleted: isCompleted ?? this.isCompleted,
      isVerifiedByParent: isVerifiedByParent ?? this.isVerifiedByParent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'rewardAmount': rewardAmount,
        'isCompleted': isCompleted,
        'isVerifiedByParent': isVerifiedByParent,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChoreItem.fromJson(Map<String, dynamic> map) => ChoreItem(
        id: map['id'] as String,
        title: map['title'] as String,
        rewardAmount: (map['rewardAmount'] as num).toDouble(),
        isCompleted: map['isCompleted'] as bool? ?? false,
        isVerifiedByParent: map['isVerifiedByParent'] as bool? ?? false,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

/// A Junior / Teen profile under the Sovereign Heritage Trust.
class JuniorProfile {
  final String id;
  final String name;
  final String avatar;
  final int age;
  final double monthlyAllowance;
  final double totalSaved;
  final double totalSpent;
  final double totalGiven;
  final double compoundingFundBalance;
  final int ringStreakDays;
  final List<ChoreItem> chores;

  const JuniorProfile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.age,
    required this.monthlyAllowance,
    this.totalSaved = 0.0,
    this.totalSpent = 0.0,
    this.totalGiven = 0.0,
    this.compoundingFundBalance = 0.0,
    this.ringStreakDays = 0,
    this.chores = const [],
  });

  /// Total liquid balance available to child (saved + chore earnings - spent - given)
  double get liquidBalance => (totalSaved - totalSpent - totalGiven).clamp(0.0, double.infinity);

  /// Target daily rings progress (0.0 to 1.0)
  double get saveRingProgress => (totalSaved > 0 ? (totalSaved / (monthlyAllowance > 0 ? monthlyAllowance : 1000)).clamp(0.0, 1.0) : 0.0);
  double get spendRingProgress => (totalSpent > 0 ? (totalSpent / ((monthlyAllowance * 0.5) > 0 ? (monthlyAllowance * 0.5) : 500)).clamp(0.0, 1.0) : 0.0);
  double get giveRingProgress => (totalGiven > 0 ? (totalGiven / ((monthlyAllowance * 0.1) > 0 ? (monthlyAllowance * 0.1) : 100)).clamp(0.0, 1.0) : 0.0);

  JuniorProfile copyWith({
    String? id,
    String? name,
    String? avatar,
    int? age,
    double? monthlyAllowance,
    double? totalSaved,
    double? totalSpent,
    double? totalGiven,
    double? compoundingFundBalance,
    int? ringStreakDays,
    List<ChoreItem>? chores,
  }) {
    return JuniorProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      age: age ?? this.age,
      monthlyAllowance: monthlyAllowance ?? this.monthlyAllowance,
      totalSaved: totalSaved ?? this.totalSaved,
      totalSpent: totalSpent ?? this.totalSpent,
      totalGiven: totalGiven ?? this.totalGiven,
      compoundingFundBalance: compoundingFundBalance ?? this.compoundingFundBalance,
      ringStreakDays: ringStreakDays ?? this.ringStreakDays,
      chores: chores ?? this.chores,
    );
  }
}

/// Service managing the Sovereign Heritage Vault & Junior Freedom Trust.
class JuniorHeritageService {
  static final JuniorHeritageService _instance = JuniorHeritageService._internal();
  factory JuniorHeritageService() => _instance;

  JuniorHeritageService._internal() {
    _initDefaultProfiles();
  }

  final List<JuniorProfile> _profiles = [];

  List<JuniorProfile> get profiles => List.unmodifiable(_profiles);

  void _initDefaultProfiles() {
    if (_profiles.isNotEmpty) return;
    _profiles.addAll([
      JuniorProfile(
        id: 'junior_1',
        name: 'Aarav',
        avatar: '🚀',
        age: 11,
        monthlyAllowance: 1500,
        totalSaved: 3200,
        totalSpent: 450,
        totalGiven: 150,
        compoundingFundBalance: 12500,
        ringStreakDays: 14,
        chores: [
          ChoreItem(
            id: 'c1',
            title: 'Read 3 chapters of "Rich Kid Smart Kid"',
            rewardAmount: 150,
            isCompleted: true,
            isVerifiedByParent: true,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ChoreItem(
            id: 'c2',
            title: 'Audit household electricity vampire leaks',
            rewardAmount: 100,
            isCompleted: false,
            isVerifiedByParent: false,
            createdAt: DateTime.now(),
          ),
          ChoreItem(
            id: 'c3',
            title: 'Feed & walk the dog every morning',
            rewardAmount: 75,
            isCompleted: false,
            isVerifiedByParent: false,
            createdAt: DateTime.now(),
          ),
        ],
      ),
      JuniorProfile(
        id: 'junior_2',
        name: 'Ananya',
        avatar: '🦊',
        age: 15,
        monthlyAllowance: 3000,
        totalSaved: 7800,
        totalSpent: 1200,
        totalGiven: 400,
        compoundingFundBalance: 45000,
        ringStreakDays: 28,
        chores: [
          ChoreItem(
            id: 'c4',
            title: 'Track grocery receipts with 1-Snap Scanner',
            rewardAmount: 200,
            isCompleted: true,
            isVerifiedByParent: false,
            createdAt: DateTime.now(),
          ),
          ChoreItem(
            id: 'c5',
            title: 'Score 90%+ in Math term mock test',
            rewardAmount: 500,
            isCompleted: false,
            isVerifiedByParent: false,
            createdAt: DateTime.now(),
          ),
        ],
      ),
    ]);
  }

  /// Add a new junior account.
  void addProfile(JuniorProfile profile) {
    _profiles.add(profile);
  }

  /// Mark chore as completed by child.
  void markChoreDone(String profileId, String choreId) {
    final pIndex = _profiles.indexWhere((p) => p.id == profileId);
    if (pIndex == -1) return;

    final profile = _profiles[pIndex];
    final updatedChores = profile.chores.map((c) {
      if (c.id == choreId) {
        return c.copyWith(isCompleted: true);
      }
      return c;
    }).toList();

    _profiles[pIndex] = profile.copyWith(chores: updatedChores);
  }

  /// Parent verifies chore and pays reward directly into child's savings.
  void verifyAndPayoutChore(String profileId, String choreId) {
    final pIndex = _profiles.indexWhere((p) => p.id == profileId);
    if (pIndex == -1) return;

    final profile = _profiles[pIndex];
    double rewardEarned = 0;
    final updatedChores = profile.chores.map((c) {
      if (c.id == choreId) {
        rewardEarned = c.rewardAmount;
        return c.copyWith(isCompleted: true, isVerifiedByParent: true);
      }
      return c;
    }).toList();

    _profiles[pIndex] = profile.copyWith(
      chores: updatedChores,
      totalSaved: profile.totalSaved + rewardEarned,
      ringStreakDays: profile.ringStreakDays + 1,
    );
  }

  /// Add a chore quest for a child.
  void addChore(String profileId, {required String title, required double reward}) {
    final pIndex = _profiles.indexWhere((p) => p.id == profileId);
    if (pIndex == -1) return;

    final profile = _profiles[pIndex];
    final newChore = ChoreItem(
      id: 'chore_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      rewardAmount: reward,
      createdAt: DateTime.now(),
    );

    _profiles[pIndex] = profile.copyWith(
      chores: [...profile.chores, newChore],
    );
  }

  /// Transfer funds from child's liquid savings into the Sovereign Compounding Fund (Index Fund / Sovereign Gold).
  void transferToCompoundingFund(String profileId, double amount) {
    final pIndex = _profiles.indexWhere((p) => p.id == profileId);
    if (pIndex == -1) return;

    final profile = _profiles[pIndex];
    final transferAmt = min(amount, profile.liquidBalance);
    if (transferAmt <= 0) return;

    _profiles[pIndex] = profile.copyWith(
      totalSaved: profile.totalSaved - transferAmt,
      compoundingFundBalance: profile.compoundingFundBalance + transferAmt,
    );
  }

  /// Calculates compound growth of monthly contribution over years at given annual return.
  /// Formula: Future Value of monthly annuity = P * [((1 + r)^n - 1) / r] * (1 + r)
  double projectCompoundGrowth({
    required double initialPrincipal,
    required double monthlyContribution,
    required int years,
    double annualRate = 0.12,
  }) {
    final monthlyRate = annualRate / 12;
    final totalMonths = years * 12;
    final fvPrincipal = initialPrincipal * pow(1 + monthlyRate, totalMonths);
    final fvContributions = monthlyContribution *
        ((pow(1 + monthlyRate, totalMonths) - 1) / monthlyRate) *
        (1 + monthlyRate);
    return fvPrincipal + fvContributions;
  }
}
