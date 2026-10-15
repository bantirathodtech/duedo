import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'database.dart';
import '../models/app_enums.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

class DatabaseService {
  final AppDatabase _db;

  DatabaseService(this._db);

  // Obligations
  Stream<List<Obligation>> watchAllObligations() {
    return (_db.select(_db.obligations)..orderBy([(t) => OrderingTerm(expression: t.priority, mode: OrderingMode.asc)])).watch();
  }

  Future<List<Obligation>> getAllObligations() {
    return (_db.select(_db.obligations)..orderBy([(t) => OrderingTerm(expression: t.priority, mode: OrderingMode.asc)])).get();
  }

  Future<int> addObligation(ObligationsCompanion obligation) {
    return _db.into(_db.obligations).insert(obligation);
  }

  Future<Obligation?> getObligationById(int id) {
    return (_db.select(_db.obligations)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<bool> updateObligation(Obligation obligation) {
    return _db.update(_db.obligations).replace(obligation);
  }

  Future<int> deleteObligation(int id) {
    return (_db.delete(_db.obligations)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markObligationAsPaid(int id) async {
    await (_db.update(_db.obligations)..where((t) => t.id.equals(id))).write(
      const ObligationsCompanion(status: Value(ObligationStatus.paid)),
    );
  }

  // Payments
  Future<int> addPayment(PaymentsCompanion payment) {
    return _db.into(_db.payments).insert(payment);
  }

  Stream<List<Payment>> watchPaymentsForObligation(int obligationId) {
    return (_db.select(_db.payments)..where((t) => t.obligationId.equals(obligationId))).watch();
  }

  Future<List<Payment>> getPaymentsForObligation(int obligationId) {
    return (_db.select(_db.payments)..where((t) => t.obligationId.equals(obligationId))).get();
  }

  Stream<List<Payment>> watchAllPayments() {
    return _db.select(_db.payments).watch();
  }

  Future<double> getPaymentsSum(int obligationId) async {
    final query = _db.selectOnly(_db.payments)
      ..addColumns([_db.payments.amountPaid.sum()])
      ..where(_db.payments.obligationId.equals(obligationId));
    final result = await query.getSingleOrNull();
    return result?.read(_db.payments.amountPaid.sum()) ?? 0.0;
  }

  // Settings
  Stream<UserSetting?> watchSettings() {
    return (_db.select(_db.userSettings)..where((t) => t.id.equals(1))).watchSingleOrNull();
  }

  Future<void> updateSettings(UserSettingsCompanion settings) async {
    await _db.into(_db.userSettings).insertOnConflictUpdate(settings);
  }

  Future<UserSetting?> getSettings() {
    return (_db.select(_db.userSettings)..where((t) => t.id.equals(1))).getSingleOrNull();
  }

  Future<NotificationTemplate?> getRandomNotificationTemplate(String category, bool isSavage) async {
    final query = _db.select(_db.notificationTemplates)
      ..where((t) => t.category.equals(category) & t.isSavage.equals(isSavage));
    final results = await query.get();
    if (results.isEmpty) return null;
    return (results..shuffle()).first;
  }

  Future<void> init() async {
    final settings = await getSettings();
    if (settings == null) {
      await seedProductionDemoData();
    } else {
      final obligations = await getAllObligations();
      if (obligations.isEmpty) {
        await seedProductionDemoData();
      }
    }
  }

  /// Seeds high-production realistic dummy data across all 9 phases so developers and testers
  /// can immediately experience the full app in production fidelity.
  Future<void> seedProductionDemoData({bool force = false}) async {
    final existing = await getAllObligations();
    if (!force && existing.isNotEmpty) return;

    if (force) {
      await _db.delete(_db.payments).go();
      await _db.delete(_db.obligations).go();
    }

    final now = DateTime.now();

    // 1. User Settings & Streak
    await updateSettings(UserSettingsCompanion(
      id: const Value(1),
      monthlyIncome: const Value(95000.0),
      currency: const Value('₹'),
      notificationsEnabled: const Value(true),
      reminderDaysBefore: const Value(2),
      paydayOfMonth: const Value(1),
      isPremium: const Value(true),
      paymentStreak: const Value(42),
      isSavageMode: const Value(false),
      lastPaymentDate: Value(now.subtract(const Duration(days: 1))),
    ));

    // 2. High-APR Credit Card (Top Avalanche Candidate - Phase 1, 2, 8)
    final hdfcId = await addObligation(ObligationsCompanion(
      title: const Value('HDFC Regalia Credit Card'),
      type: const Value(ObligationType.emi),
      amount: const Value(6500.0),
      totalBalance: const Value(74500.0),
      interestRate: const Value(42.0),
      priority: const Value(PriorityLevel.high),
      category: const Value('Credit Card'),
      startDate: Value(now.subtract(const Duration(days: 120))),
      nextDueDate: Value(DateTime(now.year, now.month, now.day + 5)),
      notes: const Value('Pre-approved settlement waiver eligible before statement generation date'),
      isActive: const Value(true),
    ));

    // Recent Payment for HDFC card
    await addPayment(PaymentsCompanion(
      obligationId: Value(hdfcId),
      amountPaid: const Value(5000.0),
      paidDate: Value(now.subtract(const Duration(days: 25))),
      paymentType: const Value('UPI Slay'),
      note: const Value('Snowflake strike via Google Pay'),
    ));

    // 3. Medium-Term Personal Loan (Phase 1 Snowball step 2 & Phase 3 Calendar)
    final iciciId = await addObligation(ObligationsCompanion(
      title: const Value('ICICI Express Personal Loan'),
      type: const Value(ObligationType.emi),
      amount: const Value(9850.0),
      totalBalance: const Value(185000.0),
      interestRate: const Value(13.5),
      priority: const Value(PriorityLevel.medium),
      category: const Value('Personal Loan'),
      startDate: Value(now.subtract(const Duration(days: 210))),
      nextDueDate: Value(DateTime(now.year, now.month, now.day + 12)),
      emiDurationMonths: const Value(24),
      emiPaidMonths: const Value(7),
      notes: const Value('Tenure: 24 Months | 7 EMIs paid | Auto-debit on 12th'),
      isActive: const Value(true),
    ));

    await addPayment(PaymentsCompanion(
      obligationId: Value(iciciId),
      amountPaid: const Value(9850.0),
      paidDate: Value(now.subtract(const Duration(days: 18))),
      paymentType: const Value('Auto-Debit'),
      note: const Value('Regular scheduled EMI'),
    ));

    // 4. Low-APR Education Loan with Tax Benefit 80E (Phase 1, 3, 4)
    await addObligation(ObligationsCompanion(
      title: const Value('SBI Scholar Education Loan'),
      type: const Value(ObligationType.emi),
      amount: const Value(7200.0),
      totalBalance: const Value(320000.0),
      interestRate: const Value(8.5),
      priority: const Value(PriorityLevel.low),
      category: const Value('Education'),
      startDate: Value(now.subtract(const Duration(days: 450))),
      nextDueDate: Value(DateTime(now.year, now.month, now.day + 20)),
      emiDurationMonths: const Value(60),
      emiPaidMonths: const Value(15),
      taxCategory: const Value('80E'),
      notes: const Value('Eligible for 100% tax deduction on interest under Section 80E'),
      isActive: const Value(true),
    ));

    // 5. Entertainment Subscription for Vampire Slasher (Phase 6)
    await addObligation(ObligationsCompanion(
      title: const Value('Netflix Premium 4K UHD'),
      type: const Value(ObligationType.recurring),
      amount: const Value(649.0),
      totalBalance: const Value(0.0),
      interestRate: const Value(0.0),
      priority: const Value(PriorityLevel.low),
      category: const Value('Entertainment'),
      startDate: Value(now.subtract(const Duration(days: 180))),
      nextDueDate: Value(DateTime(now.year, now.month, now.day + 2)),
      notes: const Value('Detected by Vampire Slasher: 5-year opportunity cost ₹58,000'),
      isActive: const Value(true),
    ));

    // 6. Fitness Subscription for Vampire Slasher (Phase 6)
    await addObligation(ObligationsCompanion(
      title: const Value('Cult.Fit Elite Pass'),
      type: const Value(ObligationType.recurring),
      amount: const Value(1499.0),
      totalBalance: const Value(0.0),
      interestRate: const Value(0.0),
      priority: const Value(PriorityLevel.low),
      category: const Value('Fitness'),
      startDate: Value(now.subtract(const Duration(days: 90))),
      nextDueDate: Value(DateTime(now.year, now.month, now.day + 8)),
      notes: const Value('Detected by Vampire Slasher: Unutilized for 45 days'),
      isActive: const Value(true),
    ));
  }
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService(ref.watch(databaseProvider));
});
