// Fallback for non-web platforms: maps are available via native SDKs
bool isGoogleMapsAvailable() => true;

// No-op injector for non-web
Future<bool> injectGoogleMapsScript(String? apiKey) async => true;
