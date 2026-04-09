import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'audit_log.dart';

final supabaseServiceProvider = Provider((ref) => SupabaseService());

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  bool _canSync = false;

  User? get currentUser => _client.auth.currentUser;
  bool get canSync => _canSync;
  bool get isAuthenticated => currentUser != null && currentUser!.appMetadata['provider'] != 'anonymous';

  /// Check if we have an existing session on startup
  Future<void> initialize() async {
    AuditLog.startTimer('Supabase_Init');
    try {
      final session = _client.auth.currentSession;
      if (session != null) {
        _canSync = true;
        AuditLog.info('Session restored for ${currentUser?.email}', tag: 'AUTH');
      } else {
        _canSync = false;
        AuditLog.info('No active session. Local-Only mode.', tag: 'AUTH');
      }
    } catch (e) {
      AuditLog.info('Init error: $e', tag: 'AUTH');
    } finally {
      AuditLog.stopTimer('Supabase_Init');
    }
  }

  Future<void> signInWithGoogle() async {
    // This is the Web Client ID used as the 'serverClientId' for token verification
    const webClientId = '489187531057-b5nbssqk9huivts3ulnh9ffsflis755m.apps.googleusercontent.com'; 
    const iosClientId = ''; // Leave empty if not using iOS

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;
    final accessToken = googleAuth?.accessToken;
    final idToken = googleAuth?.idToken;

    if (accessToken == null || idToken == null) {
      throw 'Google Sign-In failed: Missing tokens';
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
    
    _canSync = true;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    _canSync = false;
  }

  Future<void> signInAnonymously() async {
    if (currentUser != null) {
      _canSync = true;
      return;
    }

    try {
      final response = await _client.auth.signInAnonymously();
      if (response.user != null) {
        _canSync = true;
      }
    } catch (e) {
      _canSync = false;
      debugPrint('Supabase: Anonymous auth skipped/failed: $e');
    }
  }

  // Generic Upsert for Sync
  Future<void> upsert(String table, Map<String, dynamic> data) async {
    if (!_canSync) return;
    try {
      await _client.from(table).upsert(data);
    } catch (e) {
      debugPrint('Supabase Sync Error (Upsert $table): $e');
    }
  }

  // Generic Sync Pull
  Future<List<Map<String, dynamic>>> fetch(String table) async {
    if (!_canSync) return [];
    try {
      return await _client.from(table).select();
    } catch (e) {
      debugPrint('Supabase Sync Error (Fetch $table): $e');
      return [];
    }
  }

  // Delete Sync
  Future<void> delete(String table, dynamic id) async {
    if (!_canSync) return;
    try {
      await _client.from(table).delete().eq('id', id);
    } catch (e) {
      debugPrint('Supabase Sync Error (Delete $table): $e');
    }
  }
}
