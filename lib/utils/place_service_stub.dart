import 'place_suggestion.dart';

class PlaceService {
  Future<List<PlaceSuggestion>> autocomplete(String input) async {
    // Android release: kosong dulu
    return <PlaceSuggestion>[];
  }

  /// HARUS Map karena UI pakai details['...']
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    // Biar UI aman saat akses keys, kembalikan struktur minimal yang dipakai
    return <String, dynamic>{
      'formatted_address': null,
      'name': null,
      'geometry': {
        'location': {'lat': null, 'lng': null}
      }
    };
  }
}
