import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'database.dart';
import 'database_service.dart';
import 'notification_service.dart';
import 'logger_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // 1. Initialize fresh DB connection (Isolate-safe)
      final db = AppDatabase();
      final dbService = DatabaseService(db);
      final notificationService = NotificationService(dbService);
      
      await notificationService.init();
      
      // 2. Refresh schedules
      final settings = await dbService.getSettings();
      if (settings != null && settings.notificationsEnabled) {
        final isSavage = settings.isSavageMode;
        await notificationService.scheduleDailyVibe(isSavage: isSavage);
        await notificationService.scheduleWeeklyReview(isSavage: isSavage);
        await notificationService.scheduleMonthlyReview(isSavage: isSavage);
        await notificationService.schedulePaydayReminder(settings.paydayOfMonth, isSavage: isSavage);
        await notificationService.scheduleGhostingReminder();
      }
      
      await db.close();
      return true;
    } catch (e, stackTrace) {
      LoggerService.log(
        "WorkManager Task Error",
        category: LogCategory.error,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  });
}

class BackgroundService {
  static const String taskName = "com.avishio.duedo.refresh_notifications";

  static Future<void> init() async {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) return;

    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      "1", // Unique ID
      taskName,
      frequency: const Duration(hours: 24),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: true,
      ),
    );
  }
}
