import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final vaultServiceProvider = Provider((ref) => VaultService());

class VaultService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const String _vaultKey = 'duedo_vault_enabled';
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _getPrefs async => _prefs ??= await SharedPreferences.getInstance();

  Future<bool> isBiometricsAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  Future<bool> authenticate({String reason = 'Authenticate to access your financial vault'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> isVaultEnabled() async {
    final prefs = await _getPrefs;
    return prefs.getBool(_vaultKey) ?? false;
  }

  Future<void> setVaultEnabled(bool enabled) async {
    final prefs = await _getPrefs;
    await prefs.setBool(_vaultKey, enabled);
  }
}
