/// Supabase configuration for the NGO module.
/// Uses the public anon key — safe for client-side use on public buckets.
abstract class NgoSupabaseConfig {
  static const String projectUrl = 'https://fjnhsaxuwyairfgrciyf.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZqbmhzYXh1d3lhaXJmZ3JjaXlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc5ODIxNzYsImV4cCI6MjEwMzU1ODE3Nn0'
      '.RXadCYW1QDqSgOkZPMV4Tl8XiveAIpRyuCN__jb_x5I';
  static const String serviceImagesBucket = 'service-images';
  static const String storageBaseUrl = '$projectUrl/storage/v1/object/public';
  static const String storageApiUrl = '$projectUrl/storage/v1/object';
}
