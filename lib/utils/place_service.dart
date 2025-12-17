import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Web interop
import 'dart:js_util' as js_util;
import 'dart:html' as html;

class PlaceSuggestion {
  final String placeId;
  final String description;

  PlaceSuggestion({required this.placeId, required this.description});
}

class PlaceService {
  final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  Future<List<PlaceSuggestion>> autocomplete(String input) async {
    // On web, use the Maps JavaScript Places AutocompleteService to avoid CORS issues
    if (kIsWeb) {
      try {
        final google = js_util.getProperty(html.window, 'google');
        if (google == null) return [];
        final maps = js_util.getProperty(google, 'maps');
        final places = js_util.getProperty(maps, 'places');
        final AutoCtor = js_util.getProperty(places, 'AutocompleteService');
        final service = js_util.callConstructor(AutoCtor, []);

        final completer = Completer<List<PlaceSuggestion>>();
        final callback = js_util.allowInterop((predictions, status) {
          if (predictions == null) {
            completer.complete([]);
            return;
          }
          final preds = (predictions as List).map((p) {
            final placeId = js_util.getProperty(p, 'place_id') as String?;
            final description = js_util.getProperty(p, 'description') as String?;
            return PlaceSuggestion(placeId: placeId ?? '', description: description ?? '');
          }).toList();
          completer.complete(preds);
        });

        final options = js_util.jsify({'input': input, 'types': ['(regions)']});
        js_util.callMethod(service, 'getPlacePredictions', [options, callback]);

        return completer.future.timeout(const Duration(seconds: 8), onTimeout: () => []);
      } catch (e) {
        print('[PlaceService] web autocomplete error: $e');
        return [];
      }
    }

    // Fallback to server-side HTTP request (for non-web platforms)
    if (apiKey == null || apiKey!.isEmpty) return [];
    final uri = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
      'input': input,
      'key': apiKey!,
      'types': '(regions)', // broad set that includes cities
    });

    final resp = await http.get(uri).timeout(const Duration(seconds: 8));
    if (resp.statusCode != 200) return [];
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final predictions = data['predictions'] as List<dynamic>?;
    if (predictions == null) return [];
    return predictions.map((p) {
      return PlaceSuggestion(
        placeId: p['place_id'] as String,
        description: p['description'] as String,
      );
    }).toList();
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    if (kIsWeb) {
      try {
        final google = js_util.getProperty(html.window, 'google');
        if (google == null) return null;
        final maps = js_util.getProperty(google, 'maps');
        final places = js_util.getProperty(maps, 'places');
        final PlacesCtor = js_util.getProperty(places, 'PlacesService');
        final container = html.document.createElement('div');
        final service = js_util.callConstructor(PlacesCtor, [container]);

        final completer = Completer<Map<String, dynamic>?>();
        final callback = js_util.allowInterop((result, status) {
          if (result == null) {
            completer.complete(null);
            return;
          }
          final formatted = js_util.getProperty(result, 'formatted_address') as String?;
          final name = js_util.getProperty(result, 'name') as String?;
          final geometry = js_util.getProperty(result, 'geometry');
          final loc = geometry != null ? js_util.getProperty(geometry, 'location') : null;
          double? lat;
          double? lng;
          if (loc != null) {
            final latVal = js_util.callMethod(loc, 'lat', []);
            final lngVal = js_util.callMethod(loc, 'lng', []);
            lat = (latVal as num?)?.toDouble();
            lng = (lngVal as num?)?.toDouble();
          }
          final map = <String, dynamic>{
            'formatted_address': formatted,
            'name': name,
            'geometry': {
              'location': {'lat': lat, 'lng': lng}
            }
          };
          completer.complete(map);
        });

        final request = js_util.jsify({'placeId': placeId, 'fields': ['geometry', 'formatted_address', 'name']});
        js_util.callMethod(service, 'getDetails', [request, callback]);

        return completer.future.timeout(const Duration(seconds: 8), onTimeout: () => null);
      } catch (e) {
        print('[PlaceService] web getPlaceDetails error: $e');
        return null;
      }
    }

    if (apiKey == null || apiKey!.isEmpty) return null;
    final uri = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
      'place_id': placeId,
      'key': apiKey!,
      'fields': 'geometry,formatted_address,name',
    });

    final resp = await http.get(uri).timeout(const Duration(seconds: 8));
    if (resp.statusCode != 200) return null;
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final result = data['result'] as Map<String, dynamic>?;
    return result;
  }
}
