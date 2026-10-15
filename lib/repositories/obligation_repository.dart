import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'package:drift/drift.dart';
import '../services/database.dart';
import '../services/audit_log.dart';
import '../services/database_service.dart';
import '../services/financial_logic_service.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../services/slain_debt_trophy_service.dart';
import '../models/app_enums.dart';

final obligationRepositoryProvider = Provider((ref) {
  final databaseService = ref.read(databaseServiceProvider);
  final financialLogicService = ref.read(financialLogicServiceProvider);
  final supabaseService = ref.read(supabaseServiceProvider);
  final notificationService = ref.read(notificationServiceProvider);
  return ObligationRepository(databaseService, financialLogicService, supabaseService, notificationService, ref);
});

class ObligationRepository {
  final DatabaseService _databaseService;
  final FinancialLogicService _financialLogicService;
  final SupabaseService _supabaseService;
  final NotificationService _notificationService;
  final Ref _ref;

  ObligationRepository(this._databaseService, this._financialLogicService, this._supabaseService, this._notificationService, this._ref);

  Future<void> init() async {
    AuditLog.startTimer('Repo_Init');
    // Ensure anonymous auth is at least attempted to enable 'canSync' if allowed
    final supabase = _ref.read(supabaseServiceProvider);
    await supabase.initialize();
    AuditLog.stopTimer('Repo_Init');
  }

  /// Bulk sync all local records to the cloud (used after Google Sign-In)
  Future<void> syncAllLocalToCloud() async {
    if (!_supabaseService.canSync) return;
    
    debugPrint('Hybrid Sync: Starting Guest -> Cloud migration...');
    
    // 1. Sync Settings
    final settings = await _databaseService.getSettings();
    if (settings != null) {
      await updateSettings(settings.toCompanion(true));
    }

    // 2. Sync Obligations
    final obligations = await _databaseService.getAllObligations();
    for (final obs in obligations) {
      await _supabaseService.upsert('obligations', _obligationToMap(obs));
      
      // 3. Sync Payments for this obligation
      final payments = await _databaseService.getPaymentsForObligation(obs.id);
      for (final p in payments) {
        await _supabaseService.upsert('payments', {
          'id': p.id,
          'obligation_id': p.obligationId,
          'amount_paid': p.amountPaid,
          'payment_type': p.paymentType,
          'note': p.note,
          'paid_date': p.paidDate.toIso8601String(),
        });
      }
    }
    
    debugPrint('Hybrid Sync: Migration complete.');
  }

  Stream<List<Obligation>> getAllObligations() {
    return _databaseService.watchAllObligations();
  }

  Future<int> createObligation(ObligationsCompanion obligation) async {
    final id = await _databaseService.addObligation(obligation);
    
    // Sync to cloud and notifications
    final obs = await _databaseService.getObligationById(id);
    if (obs != null) {
      await _supabaseService.upsert('obligations', _obligationToMap(obs));
      await _syncNotifications(obs);
    }
    return id;
  }

  Future<bool> updateObligation(Obligation obligation) async {
    final success = await _databaseService.updateObligation(obligation);
    if (success) {
      await _supabaseService.upsert('obligations', _obligationToMap(obligation));
      await _syncNotifications(obligation);
    }
    return success;
  }

  Future<int> deleteObligation(int id) async {
    await _notificationService.cancelNotification(id);
    final count = await _databaseService.deleteObligation(id);
    await _supabaseService.delete('obligations', id);
    return count;
  }

  Future<void> reorderObligations(List<Obligation> reorderedList) async {
    for (int i = 0; i < reorderedList.length; i++) {
      final updated = reorderedList[i].copyWith(displayOrder: i);
      await _databaseService.updateObligation(updated);
      // Sync reorder to cloud
      await _supabaseService.upsert('obligations', _obligationToMap(updated));
    }
  }

  Stream<List<Payment>> getPaymentsStream(int? id) {
    if (id == null) return Stream.value([]);
    return _databaseService.watchPaymentsForObligation(id);
  }

  Stream<List<Payment>> getAllPaymentsStream() {
    return _databaseService.watchAllPayments();
  }

  Future<void> markAsPaid(Obligation obligation, double amount, {String? note, bool isPartial = false}) async {
    // 1. Add to payment history
    final paymentId = await _databaseService.addPayment(
      PaymentsCompanion.insert(
        obligationId: obligation.id,
        amountPaid: amount,
        paymentType: isPartial ? 'Partial' : (obligation.type == ObligationType.emi ? 'EMI' : 'Full'),
        note: Value(note),
      ),
    );

    // Sync payment to cloud
    await _supabaseService.upsert('payments', {
      'id': paymentId,
      'obligation_id': obligation.id,
      'amount_paid': amount,
      'payment_type': isPartial ? 'Partial' : (obligation.type == ObligationType.emi ? 'EMI' : 'Full'),
      'note': note,
      'paid_date': DateTime.now().toIso8601String(),
    });

    // 2. Update obligation state
    if (obligation.type == ObligationType.emi) {
      final updatedEmiPaidMonths = (obligation.emiPaidMonths) + 1;
      final isFinished = updatedEmiPaidMonths >= (obligation.emiDurationMonths ?? 0);
      
      final nextDueDate = _addOneMonth(obligation.nextDueDate ?? obligation.startDate); 

      final updated = obligation.copyWith(
        emiPaidMonths: updatedEmiPaidMonths,
        nextDueDate: Value(nextDueDate),
        status: isFinished ? ObligationStatus.paid : ObligationStatus.pending,
        isActive: !isFinished,
        updatedAt: DateTime.now(),
      );

      await updateObligation(updated);
      
      if (isFinished) {
        await _ref.read(slainDebtTrophyProvider.notifier).registerSlainDebt(obligation);
        await _notificationService.showEMIVictory(obligation.title);
      }
    } else {
      // For One-time, check total paid
      final totalPaid = await _databaseService.getPaymentsSum(obligation.id);
      final isFinished = totalPaid >= obligation.amount;

      final updated = obligation.copyWith(
        status: isFinished ? ObligationStatus.paid : ObligationStatus.pending,
        isActive: !isFinished,
        updatedAt: DateTime.now(),
      );

      await updateObligation(updated);

      if (isFinished) {
        await _ref.read(slainDebtTrophyProvider.notifier).registerSlainDebt(obligation);
        await _notificationService.showEMIVictory(obligation.title);
      }
    }
  }

  // Settings
  Stream<UserSetting?> getSettings() {
    return _databaseService.watchSettings();
  }

  Future<void> updateSettings(UserSettingsCompanion settings) async {
    await _databaseService.updateSettings(settings);
    // Sync settings to cloud
    final current = await _databaseService.getSettings();
    if (current != null) {
      await _supabaseService.upsert('user_settings', {
        'id': 1,
        'monthly_income': current.monthlyIncome,
        'currency': current.currency,
        'notifications_enabled': current.notificationsEnabled,
        'reminder_days_before': current.reminderDaysBefore,
        'payday_of_month': current.paydayOfMonth,
        'projection_months': current.projectionMonths,
        'theme_mode': current.themeMode,
      });
    }
  }

  // Analytics Helpers
  String getUrgency(Obligation obligation) => _financialLogicService.getUrgencyLabel(obligation);


  Map<String, dynamic> _obligationToMap(Obligation o) {
    return {
      'id': o.id,
      'title': o.title,
      'type': o.type.index,
      'amount': o.amount,
      'start_date': o.startDate.toIso8601String(),
      'end_date': o.endDate?.toIso8601String(),
      'emi_duration_months': o.emiDurationMonths,
      'grace_period_days': o.gracePeriodDays,
      'emi_paid_months': o.emiPaidMonths,
      'priority': o.priority.index,
      'status': o.status.index,
      'category': o.category,
      'notes': o.notes,
      'next_due_date': o.nextDueDate?.toIso8601String(),
      'is_active': o.isActive,
      'created_at': o.createdAt.toIso8601String(),
      'updated_at': o.updatedAt.toIso8601String(),
      'display_order': o.displayOrder,
    };
  }

  Future<void> _syncNotifications(Obligation o) async {
    await _notificationService.cancelNotification(o.id);
    
    if (!o.isActive || o.status == ObligationStatus.paid) return;

    final dueDate = o.nextDueDate ?? o.startDate;
    final now = DateTime.now();
    
    final settings = await getSettings().first;
    final isSavage = settings?.isSavageMode ?? false;
    
    // Activate Zomato-style 5-3-2-1 Sequence
    await _notificationService.scheduleStrategicSequence(
      o.id,
      o.title,
      dueDate,
      isSavage: isSavage,
    );

    // Exact Day Notification
    if (dueDate.isAfter(now)) {
      await _notificationService.scheduleDueDateNotification(
        id: o.id,
        title: 'Payment Due Today: ${o.title}',
        body: 'Don\'t forget to record your payment of ${o.amount}. Click to open Duedo.',
        scheduledDate: DateTime(dueDate.year, dueDate.month, dueDate.day, 9, 0),
      );
    }
  }

  Future<String?> getRandomNotificationPhrase(String category, bool isSavage) async {
    final template = await _databaseService.getRandomNotificationTemplate(category, isSavage);
    return template?.phrase;
  }

  DateTime _addOneMonth(DateTime date) {
    int nextMonth = date.month + 1;
    int nextYear = date.year;
    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }
    
    // Find the last day of the next month to prevent overflow (e.g. Jan 31 -> Feb 28)
    int lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
    int nextDay = date.day > lastDayOfNextMonth ? lastDayOfNextMonth : date.day;
    
    return DateTime(nextYear, nextMonth, nextDay, date.hour, date.minute);
  }
}
