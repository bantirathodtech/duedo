import 'dart:io';
import 'logger_service.dart';

class SecurityService {
  /// Basic check for Root/Jailbreak status
  /// Note: This is an 'informational' check for production integrity
  static Future<bool> isDeviceCompromised() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    try {
      // Check for common root paths/binaries
      final commonPaths = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
      ];

      for (var path in commonPaths) {
        if (File(path).existsSync()) {
          LoggerService.log('Device Root Binary Detected: $path', category: LogCategory.security);
          return true;
        }
      }

      // Check for 'test-keys' build tag (Android only)
      if (Platform.isAndroid) {
        // We can't access build tags easily without a plugin, 
        // but we can try to execute 'su'
        try {
          final result = await Process.run('su', ['-c', 'id']);
          if (result.exitCode == 0) {
            LoggerService.log('Root access confirmed via su command execution', category: LogCategory.security);
            return true;
          }
        } catch (_) {}
      }

      return false;
    } catch (e) {
      LoggerService.log('Error during security check: $e', category: LogCategory.error);
      return false;
    }
  }
}
