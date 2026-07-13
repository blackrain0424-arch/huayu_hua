import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  static const url = 'https://zdlitgzmybrrjqaxstvw.supabase.co';
  static const anonKey =
      'sb_publishable_7ya6Th9jOZ8nUJpzIs8tsg_xwwIX9OL';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Supabase.initialize(url: url, anonKey: anonKey);
    _initialized = true;
  }

  SupabaseClient get client => Supabase.instance.client;
  bool get isInitialized => _initialized;
}
