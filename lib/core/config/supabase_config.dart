import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration for FutBase
class SupabaseConfig {
  /// Supabase project URL
  static const String supabaseUrl = 'https://xgcqpdbmzgtisulylmtd.supabase.co';

  /// Supabase anonymous key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhnY3FwZGJtemd0aXN1bHlsbXRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA3MDQ4NjgsImV4cCI6MjA4NjI4MDg2OH0.SYXW9aKb3aY96SW96FCjgMMdGfd3z1jEYi-ef56RQi4';

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }

  /// Get Supabase client
  static SupabaseClient get client => Supabase.instance.client;

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get auth state changes
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}
