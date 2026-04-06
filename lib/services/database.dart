import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/app_enums.dart';

part 'database.g.dart';

class Obligations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get type => intEnum<ObligationType>()();
  RealColumn get amount => real()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get emiDurationMonths => integer().nullable()();
  IntColumn get gracePeriodDays => integer().withDefault(const Constant(0))();
  IntColumn get emiPaidMonths => integer().withDefault(const Constant(0))();
  IntColumn get priority => intEnum<PriorityLevel>()();
  IntColumn get status => intEnum<ObligationStatus>().withDefault(const Constant(0))();
  TextColumn get category => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get nextDueDate => dateTime().nullable()();
  RealColumn get totalBalance => real().withDefault(const Constant(0.0))();
  RealColumn get interestRate => real().withDefault(const Constant(0.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  TextColumn get taxCategory => text().nullable()(); // e.g., '80C', '80D'
}

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get obligationId => integer().references(Obligations, #id)();
  RealColumn get amountPaid => real()();
  DateTimeColumn get paidDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get paymentType => text()(); // e.g., 'EMI', 'Full', 'Partial'
  TextColumn get note => text().nullable()();
}

class UserSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  RealColumn get monthlyIncome => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('₹'))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get reminderDaysBefore => integer().withDefault(const Constant(3))();
  IntColumn get paydayOfMonth => integer().withDefault(const Constant(1))();
  IntColumn get projectionMonths => integer().withDefault(const Constant(1))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
  IntColumn get paymentStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPaymentDate => dateTime().nullable()();
  BoolColumn get smsSyncEnabled => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Obligations, Payments, UserSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        // Insert default settings
        await into(userSettings).insert(const UserSettingsCompanion(
          id: Value(1),
          monthlyIncome: Value(0.0),
          projectionMonths: Value(1),
          isPremium: Value(false),
          paymentStreak: Value(0),
        ));
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(obligations, obligations.displayOrder);
        }
        if (from < 3) {
          await m.addColumn(userSettings, userSettings.projectionMonths);
          // Also ensure settings exist if coming from very old version
          await customStatement('INSERT OR IGNORE INTO user_settings (id, projection_months) VALUES (1, 1)');
        }
        if (from < 4) {
          await m.addColumn(obligations, obligations.gracePeriodDays);
        }
        if (from < 5) {
          await m.addColumn(userSettings, userSettings.isPremium);
        }
        if (from < 6) {
          await m.addColumn(userSettings, userSettings.paymentStreak);
          await m.addColumn(userSettings, userSettings.lastPaymentDate);
        }
        if (from < 7) {
          await m.addColumn(obligations, obligations.totalBalance);
          await m.addColumn(obligations, obligations.interestRate);
        }
        if (from < 8) {
          await m.addColumn(userSettings, userSettings.smsSyncEnabled);
        }
        if (from < 9) {
          await m.addColumn(obligations, obligations.taxCategory);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'duedo.sqlite'));
    return NativeDatabase(file);
  });
}
