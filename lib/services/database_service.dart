import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'database.dart';

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

  // Payments
  Future<int> addPayment(PaymentsCompanion payment) {
    return _db.into(_db.payments).insert(payment);
  }

  Stream<List<Payment>> watchPaymentsForObligation(int obligationId) {
    return (_db.select(_db.payments)..where((t) => t.obligationId.equals(obligationId))).watch();
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

  Future<void> init() async {
    final settings = await getSettings();
    if (settings == null) {
      // Seed initial settings on first run
      await updateSettings(const UserSettingsCompanion(
        id: Value(1),
        monthlyIncome: Value(0),
        currency: Value('INR'),
        notificationsEnabled: Value(true),
        reminderDaysBefore: Value(1),
        paydayOfMonth: Value(1),
        isPremium: Value(false),
      ));
    }
  }
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService(ref.watch(databaseProvider));
});
