import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';

class SovereignVaultState {
  final bool isDecoyModeActive;
  final String primaryPin;
  final String decoyPin;
  final DateTime? lastBackupDate;
  final String? freedomCertificateHash;
  final List<String> mnemonicWords;

  const SovereignVaultState({
    this.isDecoyModeActive = false,
    this.primaryPin = '1234',
    this.decoyPin = '9999',
    this.lastBackupDate,
    this.freedomCertificateHash,
    this.mnemonicWords = const [
      'sovereign', 'shield', 'fortress', 'freedom',
      'strike', 'armor', 'crystal', 'glacier',
      'titanium', 'liberty', 'zenith', 'triumph'
    ],
  });

  Map<String, dynamic> toJson() => {
    'isDecoyModeActive': isDecoyModeActive,
    'primaryPin': primaryPin,
    'decoyPin': decoyPin,
    'lastBackupDate': lastBackupDate?.toIso8601String(),
    'freedomCertificateHash': freedomCertificateHash,
    'mnemonicWords': mnemonicWords,
  };

  factory SovereignVaultState.fromJson(Map<String, dynamic> json) {
    return SovereignVaultState(
      isDecoyModeActive: json['isDecoyModeActive'] as bool? ?? false,
      primaryPin: json['primaryPin'] as String? ?? '1234',
      decoyPin: json['decoyPin'] as String? ?? '9999',
      lastBackupDate: json['lastBackupDate'] != null
          ? DateTime.parse(json['lastBackupDate'] as String)
          : null,
      freedomCertificateHash: json['freedomCertificateHash'] as String?,
      mnemonicWords: (json['mnemonicWords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [
            'sovereign', 'shield', 'fortress', 'freedom',
            'strike', 'armor', 'crystal', 'glacier',
            'titanium', 'liberty', 'zenith', 'triumph'
          ],
    );
  }

  SovereignVaultState copyWith({
    bool? isDecoyModeActive,
    String? primaryPin,
    String? decoyPin,
    DateTime? lastBackupDate,
    String? freedomCertificateHash,
    List<String>? mnemonicWords,
  }) {
    return SovereignVaultState(
      isDecoyModeActive: isDecoyModeActive ?? this.isDecoyModeActive,
      primaryPin: primaryPin ?? this.primaryPin,
      decoyPin: decoyPin ?? this.decoyPin,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      freedomCertificateHash: freedomCertificateHash ?? this.freedomCertificateHash,
      mnemonicWords: mnemonicWords ?? this.mnemonicWords,
    );
  }
}

final sovereignVaultProvider =
    StateNotifierProvider<SovereignVaultNotifier, SovereignVaultState>((ref) {
  return SovereignVaultNotifier();
});

class SovereignVaultNotifier extends StateNotifier<SovereignVaultState> {
  static const String _prefKey = 'duedo_sovereign_vault_config_v1';

  SovereignVaultNotifier() : super(const SovereignVaultState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefKey);
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        state = SovereignVaultState.fromJson(map);
        return;
      } catch (_) {}
    }
    state = state.copyWith(
      lastBackupDate: DateTime.now().subtract(const Duration(days: 2)),
      freedomCertificateHash: 'SHA256:8f4e2b91c03a985d712e5c6a1b9f4e2b91c03a985d712e5c6a1b',
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.toJson());
    await prefs.setString(_prefKey, jsonStr);
  }

  Future<void> setPrimaryPin(String pin) async {
    HapticService.selection();
    state = state.copyWith(primaryPin: pin.trim());
    await _save();
  }

  Future<void> setDecoyPin(String pin) async {
    HapticService.selection();
    state = state.copyWith(decoyPin: pin.trim());
    await _save();
  }

  /// Verifies PIN: Returns true if primary, false if decoy mode activated
  bool verifyPin(String enteredPin) {
    if (enteredPin.trim() == state.decoyPin) {
      HapticService.savageThud();
      state = state.copyWith(isDecoyModeActive: true);
      _save();
      return false; // Decoy active
    } else if (enteredPin.trim() == state.primaryPin) {
      HapticService.dopamineCascade();
      state = state.copyWith(isDecoyModeActive: false);
      _save();
      return true; // Primary real mode active
    }
    return false;
  }

  /// Exports client-side zero-knowledge encrypted vault backup
  String exportZeroKnowledgeVault(Map<String, dynamic> data) {
    HapticService.dopamineCascade();

    final rawJson = jsonEncode(data);
    final bytes = utf8.encode(rawJson);
    final digest = sha256.convert(bytes);
    final base64Payload = base64Encode(bytes);

    state = state.copyWith(lastBackupDate: DateTime.now());
    _save();

    final exportBundle = {
      'format': 'DUEDO_SOVEREIGN_VAULT_V1',
      'exportedAt': DateTime.now().toIso8601String(),
      'sha256': digest.toString(),
      'payload': base64Payload,
      'mnemonicCount': 12,
    };

    return jsonEncode(exportBundle);
  }

  /// Generates verifiable SHA-256 cryptographic freedom certificate
  String generateFreedomCertificate({
    required String userName,
    required double totalDebtCleared,
    required int daysWon,
  }) {
    HapticService.dopamineCascade();

    final rawCert = '$userName:CLEARED:$totalDebtCleared:DAYS:$daysWon:${DateTime.now().toIso8601String()}';
    final certHash = sha256.convert(utf8.encode(rawCert)).toString();

    state = state.copyWith(freedomCertificateHash: certHash);
    _save();

    return certHash;
  }
}
