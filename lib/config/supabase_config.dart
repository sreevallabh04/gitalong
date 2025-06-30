import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ivnpvzfzvtcxkwciaewp.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2bnB2emZ6dnRjeGt3Y2lhZXdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEyMDgxODUsImV4cCI6MjA2Njc4NDE4NX0.WYPIlhRAbec9zstLI_IzG3kFRtzBzCrkXkwJVED_zd4';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
