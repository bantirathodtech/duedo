import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:io';

import 'database_service.dart';
import 'haptic_service.dart';
import 'logger_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final DatabaseService _dbService;

  NotificationService(this._dbService);

  Future<void> init() async {
    tz_data.initializeTimeZones();
    // Yield to let OS handle timezone parsing
    await Future.delayed(const Duration(milliseconds: 100));
    
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == 'settle_now' && response.payload != null) {
          // Parse id from payload 'id=123&title=...'
          final uri = Uri.parse('duedo://notification?${response.payload}');
          final idStr = uri.queryParameters['id'];
          if (idStr != null) {
            final id = int.tryParse(idStr);
            if (id != null) {
              // Mark as paid via DatabaseService directly for speed
              await _dbService.markObligationAsPaid(id);
              LoggerService.log("Notification Action: Settled obligation $id", category: LogCategory.financial);
            }
          }
        }
      },
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleDueDateNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    
    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _safeZonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'due_dates',
          'Due Date Reminders',
          channelDescription: 'Reminders for your financial obligations',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('morning_chime'),
        ),
        iOS: DarwinNotificationDetails(
          sound: 'morning_chime.aiff',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> showInstantAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await _notifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'ai_alerts',
            'AI Financial Alerts',
            channelDescription: 'Intelligence alerts from Duedo AI',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('cha_ching'),
          ),
          iOS: DarwinNotificationDetails(
            sound: 'cha_ching.aiff',
          ),
        ),
      );
    } catch (e) {
      // Fallback if custom sound fails
      await _notifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'ai_alerts_fallback',
            'AI Financial Alerts',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  Future<void> showFreedomClockTicker({
    required int daysToDebtFreedom,
    required double totalDebtRemaining,
    required String currency,
    String? nextUrgentDebt,
  }) async {
    final title = '⏳ $daysToDebtFreedom Days to Complete Debt Freedom';
    final body = 'Remaining: $currency${totalDebtRemaining.toStringAsFixed(0)}'
        '${nextUrgentDebt != null ? ' • Next: $nextUrgentDebt' : ''}';

    try {
      await _notifications.show(
        id: 8888,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'freedom_ticker',
            'Freedom Countdown Ticker',
            channelDescription: 'Live lock screen countdown to debt freedom',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: false,
            autoCancel: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: false,
          ),
        ),
      );
    } catch (e) {
      LoggerService.log('Freedom clock ticker notification failed: $e', category: LogCategory.error);
    }
  }

  final _wittyDailyPhrases = [
    "Your Freedom Date just moved 24 hours closer. 🚀",
    "The financial snowball is rolling. Want to add some more snow? ❄️",
    "Your bank account is low-key proud of your discipline today. 🥂",
    "Wealth isn't just numbers; it's a mood. Stay wealthy! 🧘‍♂️",
    "Is it just us, or does your DTI score look extra lean today? 💪",
  ];

  final _wittyWeeklyPhrases = [
    "Weekly Review: You survived the weekend without breaking the streak! 💰",
    "7 days of discipline. You're officially in the top 5% of adulting. 🏆",
    "Money management level: Grandmaster. Check your progress! ⚔️",
  ];

  final _savageDailyPhrases = [
    "Is that another subscription? Your retirement fund is crying. 😭",
    "Recording an expense won't hurt, but your credit score might. 📉",
    "Your wallet is basically a sieve. Let's fix some holes. 🕳️",
    "Don't ignore me. Debt doesn't sleep, and neither do I. 😈",
  ];

  final _wittyMonthlyPhrases = [
    "30 days later: You're officially wealthier than you were last month. Fact. 📈",
    "Monthly Roundup: Your financial future just sent a thank-you note. 💌",
    "Another month of discipline. Your freedom date is calling! 📞",
  ];

  final _wittyPaydayPhrases = [
    "PAYDAY! 💰 Remember, a wealth flip is better than a shopping spree. 😉",
    "Funds detected! 🚨 Want to turn some of that into long-term freedom? 🚀",
  ];

  final _savageWeeklyPhrases = [
    "Your weekly review is here. I hope you're ready for some brutal honesty. 😤",
    "Week overview: Your bank account is holding an intervention. 🛑",
    "Look at these numbers. Are you proud or just pretending to be? 🧐",
  ];

  final _savageMonthlyPhrases = [
    "Month end evaluation: Can we call this an achievement or just survival? 🏚️",
    "Your monthly roundup is ready. It's uglier than your high school photo. 💀",
    "30 days of bad decisions. Want to see the damage report? 📉",
  ];

  final _savagePaydayPhrases = [
    "Payday! 💸 Don't spend it all in one place... or any place. Just put it in the vault. 🏦",
    "Fresh funds! 🚨 Try not to set them on fire this time. 🔥",
  ];

  Future<void> scheduleDailyVibe({bool isSavage = false}) async {
    final template = await _dbService.getRandomNotificationTemplate('daily', isSavage);
    final phrase = template?.phrase ?? (isSavage ? _savageDailyPhrases.first : _wittyDailyPhrases.first);
        
    // Schedule for 9 AM tomorrow
    final now = DateTime.now();
    final tomorrow9AM = DateTime(now.year, now.month, now.day + 1, 9, 0);
    
    await _safeZonedSchedule(
      id: 888, // Constant ID for daily vibe
      title: isSavage ? "Brutal Truth 🧨" : "Morning Mood ☀️",
      body: phrase,
      scheduledDate: tz.TZDateTime.from(tomorrow9AM, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_vibe', 
          'Daily Motivation',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          sound: RawResourceAndroidNotificationSound('morning_chime'),
        ),
        iOS: DarwinNotificationDetails(
          sound: 'morning_chime.aiff',
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleGhostingReminder() async {
    // Schedule for 3 days from now
    final scheduledDate = DateTime.now().add(const Duration(days: 3));
    
    await _safeZonedSchedule(
      id: 999, // Constant ID for ghosting
      title: "We Miss You... 💔",
      body: "It's been 3 days. Your wallet is feeling lonely and uncontrolled. Come back?",
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'ghosting', 
          'Retention Alerts',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          sound: RawResourceAndroidNotificationSound('warning_siren'),
        ),
        iOS: DarwinNotificationDetails(
          sound: 'warning_siren.aiff',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showEMIVictory(String title) async {
    await HapticService.victoryPop();
    await showInstantAlert(
      id: 111,
      title: "EMI DECAPITATED! ⚔️",
      body: "You've fully cleared '$title'. That's one less weight on your shoulders!",
    );
  }

  Future<void> scheduleWeeklyReview({bool isSavage = false}) async {
    final template = await _dbService.getRandomNotificationTemplate('weekly', isSavage);
    final phrase = template?.phrase ?? (isSavage ? _savageWeeklyPhrases.first : _wittyWeeklyPhrases.first);

    // Schedule for coming Sunday at 7 PM
    final now = DateTime.now();
    int daysUntilSunday = DateTime.sunday - now.weekday;
    if (daysUntilSunday <= 0) daysUntilSunday += 7;
    final sunday7PM = DateTime(now.year, now.month, now.day + daysUntilSunday, 19, 0);

    await _safeZonedSchedule(
      id: 777,
      title: "Weekly Review 📈",
      body: phrase,
      scheduledDate: tz.TZDateTime.from(sunday7PM, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_review', 
          'Weekly Summary',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          sound: RawResourceAndroidNotificationSound('morning_chime'),
        ),
        iOS: DarwinNotificationDetails(
          sound: 'morning_chime.aiff',
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleMonthlyReview({bool isSavage = false}) async {
    final template = await _dbService.getRandomNotificationTemplate('monthly', isSavage);
    final phrase = template?.phrase ?? (isSavage ? _savageMonthlyPhrases.first : _wittyMonthlyPhrases.first);

    // Schedule for 1st of next month at 10 AM
    final now = DateTime.now();
    final firstOfNextMonth = DateTime(now.year, now.month + 1, 1, 10, 0);

    await _safeZonedSchedule(
      id: 666,
      title: "Monthly Roundup 💎",
      body: phrase,
      scheduledDate: tz.TZDateTime.from(firstOfNextMonth, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'monthly_review', 
          'Monthly Insights',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          sound: RawResourceAndroidNotificationSound('morning_chime'),
        ),
        iOS: DarwinNotificationDetails(
          sound: 'morning_chime.aiff',
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> schedulePaydayReminder(int payday, {bool isSavage = false}) async {
    final template = await _dbService.getRandomNotificationTemplate('payday', isSavage);
    final phrase = template?.phrase ?? (isSavage ? _savagePaydayPhrases.first : _wittyPaydayPhrases.first);

    final now = DateTime.now();
    DateTime paydayDate = DateTime(now.year, now.month, payday, 11, 0);
    if (paydayDate.isBefore(now)) {
      paydayDate = DateTime(now.year, now.month + 1, payday, 11, 0);
    }

    await _safeZonedSchedule(
      id: 555,
      title: "Payday Wealth Flip 💸",
      body: phrase,
      scheduledDate: tz.TZDateTime.from(paydayDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'payday', 
          'Payday Reminders',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          sound: RawResourceAndroidNotificationSound('cha_ching'),
        ),
        iOS: DarwinNotificationDetails(
          sound: 'cha_ching.aiff',
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleStrategicSequence(int id, String title, DateTime dueDate, {bool isSavage = false}) async {
    final daysToDue = [5, 3, 2, 1];
    
    for (final days in daysToDue) {
      final scheduledDate = dueDate.subtract(Duration(days: days));
      if (scheduledDate.isBefore(DateTime.now())) continue;

      final template = await _dbService.getRandomNotificationTemplate('emi', isSavage);
      String phrase = template?.phrase ?? "Heads up! {title} is coming in $days days.";
      phrase = phrase.replaceAll('{title}', title);

      await _safeZonedSchedule(
        id: id + days,
        title: "Countdown: $days Days 🛑",
        body: phrase,
        scheduledDate: tz.TZDateTime.from(scheduledDate.add(const Duration(hours: 10)), tz.local),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'emi_reminders', 
            'EMI Countdown',
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            sound: days <= 1 
                ? const RawResourceAndroidNotificationSound('warning_siren')
                : const RawResourceAndroidNotificationSound('morning_chime'),
            actions: days <= 2 ? [
              const AndroidNotificationAction('settle_now', 'Settle Now', showsUserInterface: true),
            ] : null,
          ),
          iOS: DarwinNotificationDetails(
            sound: days <= 1 ? 'warning_siren.aiff' : 'morning_chime.aiff',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'id=$id&title=$title',
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  /// Internal helper to catch "invalid_sound" errors and retry with default sound
  Future<void> _safeZonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {
    try {
      await _notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: androidScheduleMode,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
    } catch (e) {
      if (e is Exception && e.toString().contains('invalid_sound')) {
        // Retry without custom sound
        final fallbackDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            notificationDetails.android!.channelId,
            notificationDetails.android!.channelName,
            importance: notificationDetails.android!.importance,
            priority: notificationDetails.android!.priority,
            category: notificationDetails.android!.category,
            actions: notificationDetails.android!.actions,
          ),
          iOS: const DarwinNotificationDetails(), // Default sound
        );

        await _notifications.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: fallbackDetails,
          androidScheduleMode: androidScheduleMode,
          matchDateTimeComponents: matchDateTimeComponents,
          payload: payload,
        );
      } else {
        rethrow;
      }
    }
  }
}

final notificationServiceProvider = Provider((ref) => NotificationService(ref.watch(databaseServiceProvider)));
