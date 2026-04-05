import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supabaseServiceProvider = Provider((ref) => SupabaseService());

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Future<void> signInAnonymously() async {
    if (currentUser == null) {
      await _client.auth.signInAnonymously();
    }
  }

  // Generic Upsert for Sync
  Future<void> upsert(String table, Map<String, dynamic> data) async {
    await _client.from(table).upsert(data);
  }

  // Generic Sync Pull
  Future<List<Map<String, dynamic>>> fetch(String table) async {
    return await _client.from(table).select();
  }

  // Delete Sync
  Future<void> delete(String table, dynamic id) async {
    await _client.from(table).delete().eq('id', id);
  }
}
