// Supabase Configuration
class SupabaseConfig {
  // Your actual Supabase project credentials
  static const String devUrl = 'https://pcilfcaimakfsrqynroc.supabase.co';
  static const String devAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBjaWxmY2FpbWFrZnNycXlucm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0NDMzMzYsImV4cCI6MjA3MzAxOTMzNn0.R7EMplupDhAv8zIatm1CxEIG-tK3hAFABpqOdu8hzpI';
  
  // Environment-based configuration
  static String get projectUrl {
    // In production, use environment variables
    const String envUrl = String.fromEnvironment('SUPABASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // For development, use the dev values
    return devUrl;
  }
  
  static String get anonKeyValue {
    // In production, use environment variables
    const String envKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    
    // For development, use the dev values
    return devAnonKey;
  }
  
  // Validation
  static bool get isConfigured {
    return projectUrl != devUrl && anonKeyValue != devAnonKey;
  }
  
  // Debug mode
  static const bool debug = true; // Set to false in production
}
