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
  DateTimeColumn get lastOpened => dateTime().nullable()();
  BoolColumn get isSavageMode => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class NotificationTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()(); // e.g., 'daily', 'weekly', 'savage', 'emi'
  TextColumn get phrase => text()();
  BoolColumn get isSavage => boolean().withDefault(const Constant(false))();
}

extension UserSettingX on UserSetting {
  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      monthlyIncome: Value(monthlyIncome),
      currency: Value(currency),
      notificationsEnabled: Value(notificationsEnabled),
      reminderDaysBefore: Value(reminderDaysBefore),
      paydayOfMonth: Value(paydayOfMonth),
      isPremium: Value(isPremium),
      projectionMonths: Value(projectionMonths),
      themeMode: Value(themeMode),
      isSavageMode: Value(isSavageMode),
    );
  }
}
@DriftDatabase(tables: [Obligations, Payments, UserSettings, NotificationTemplates])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 11;

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
        if (from < 10) {
          await m.addColumn(userSettings, userSettings.lastOpened);
          await m.addColumn(userSettings, userSettings.isSavageMode);
        }
        if (from < 11) {
          await m.createTable(notificationTemplates);
        }
        if (from < 12) {
          // Add performance indexes using custom SQL
          await customStatement('CREATE INDEX IF NOT EXISTS idx_obligations_next_due_date ON obligations (next_due_date);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_obligations_status ON obligations (status);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_payments_obligation_id ON payments (obligation_id);');
        }
      },
      beforeOpen: (details) async {
        if (details.wasCreated || details.hadUpgrade) {
          if (details.hadUpgrade && (details.versionBefore ?? 0) < 11) {
             await _seedInitialTemplates();
          }
        }
      },
    );
  }

  Future<void> _seedInitialTemplates() async {
    final templates = [
      // Daily Supportive
      ('daily', 'Your Freedom Date just moved 24 hours closer! 🚀', false),
      ('daily', 'Small savings today = Big freedom tomorrow. 🧘‍♂️', false),
      ('daily', 'Ready to record your wins for today? Your vault is waiting. 💰', false),
      ('daily', 'Money management is a marathon, and you\'re winning! 🏃‍♂️', false),
      
      // Daily Savage
      ('daily', 'Is that another subscription? Your retirement fund is crying. 😭', true),
      ('daily', 'Recording an expense won\'t hurt, but your credit score might. 📉', true),
      ('daily', 'Your wallet is basically a sieve. Let\'s fix some holes. 🕳️', true),
      ('daily', 'Don\'t ignore me. Debt doesn\'t sleep, and neither do I. 😈', true),
      ('daily', 'Buying things you don\'t need with money you don\'t have? Classic. 🤡', true),

      // Weekly Supportive
      ('weekly', 'You survived the week without breaking your payment streak! 🥂', false),
      ('weekly', 'Your Sunday review is in: You\'re becoming a financial monk! 🧘‍♂️', false),
      
      // Weekly Savage
      ('weekly', 'Week review: Your impulsive spending was the main character. 🎭', true),
      ('weekly', 'If your money could talk, it would be screaming right now. 😱', true),

      // Payday
      ('payday', 'PAYDAY! 💸 Quick, hide some in the vault before you see a sale sign! 🏃‍♂️', false),
      ('payday', 'Wealth Flip alert: Payday is here. Time to make your future self rich.  Flip it! 🔄', false),

      // Sync
      ('sync', 'BEEP BEEP! ⚡ Detected a payment. I\'ve synced it so you don\'t have to. 🎯', false),
      ('sync', 'Got it! Spotted that expenditure in the wild. Database updated. 🦁', false),

      // EMI Warnings (Supportive)
      ('emi', 'Heads up! {title} is coming in 5 days. You\'ve got this! 🧘‍♂️', false),
      ('emi', '3 days to go for {title}. Your discipline is legendary! 🛑', false),

      // EMI Warnings (Savage)
      ('emi', '5 days for {title}. Don\'t look surprised when the money disappears. 💸', true),
      ('emi', '3 days left. The Bank doesn\'t accept "I forgot" as currency. 🏦', true),
    ];

    for (final t in templates) {
      await into(notificationTemplates).insert(
        NotificationTemplatesCompanion.insert(
          category: t.$1,
          phrase: t.$2,
          isSavage: Value(t.$3),
        ),
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'duedo.sqlite'));
    return NativeDatabase(file);
  });
}
