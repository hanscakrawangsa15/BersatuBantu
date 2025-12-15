import 'dart:html' as html;
import 'dart:async';
import 'dart:js_util' as js_util;

bool isGoogleMapsAvailable() {
  try {
    final google = js_util.getProperty(html.window, 'google');
    if (google == null) return false;
    final maps = js_util.getProperty(google, 'maps');
    return maps != null;
  } catch (_) {
    return false;
  }
}

Future<bool> injectGoogleMapsScript(String? apiKey) async {
  try {
    if (isGoogleMapsAvailable()) return true;
    if (apiKey == null || apiKey.isEmpty) return false;

    final src = 'https://maps.googleapis.com/maps/api/js?key=${Uri.encodeComponent(apiKey)}&libraries=places';
    final script = html.ScriptElement()..src = src..async = true;

    final completer = Completer<bool>();
    script.onLoad.listen((_) => completer.complete(isGoogleMapsAvailable()));
    script.onError.listen((_) => completer.complete(false));

    html.document.head!.append(script);

    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () => isGoogleMapsAvailable());
  } catch (_) {
    return false;
  }
}
