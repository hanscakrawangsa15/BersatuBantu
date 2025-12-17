import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bersatubantu/models/event_model.dart';
import 'package:bersatubantu/models/event_registration_model.dart';
import 'supabase.dart';

class VolunteerEventService {
  final SupabaseClient _client = SupabaseService().client;

  /// Fetch all volunteer events that are open
  Future<List<Event>> fetchOpenVolunteerEvents() async {
    try {
      final response = await _client
          .from('events')
          .select('''
            id,
            organization_id,
            title,
            description,
            cover_image_url,
            category,
            location,
            city,
            start_time,
            end_time,
            quota,
            status,
            created_at,
            organizations(name)
          ''')
          .eq('category', 'volunteer')
          .neq('status', 'draft')
          .order('start_time', ascending: true);

      return List<Event>.from(response.map((event) {
        event['organization_name'] = event['organizations']?['name'] ?? 'Organisasi';
        return Event.fromMap(event);
      }));
    } catch (e) {
      print('[VolunteerEventService] Error fetching open events: $e');
      rethrow;
    }
  }

  /// Fetch volunteer events for specific category/city
  Future<List<Event>> fetchFilteredVolunteerEvents({
    String? city,
    String? searchQuery,
  }) async {
    try {
      var query = _client
          .from('events')
          .select('''
            id,
            organization_id,
            title,
            description,
            cover_image_url,
            category,
            location,
            city,
            start_time,
            end_time,
            quota,
            status,
            created_at,
            organizations(name)
          ''')
          .eq('category', 'volunteer')
          .neq('status', 'draft');

      if (city != null && city.isNotEmpty) {
        query = query.eq('city', city);
      }

      final response = await query.order('start_time', ascending: true);

      List<Event> events = List<Event>.from(response.map((event) {
        event['organization_name'] = event['organizations']?['name'] ?? 'Organisasi';
        return Event.fromMap(event);
      }));

      if (searchQuery != null && searchQuery.isNotEmpty) {
        events = events
            .where((event) => event.title.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }

      return events;
    } catch (e) {
      print('[VolunteerEventService] Error fetching filtered events: $e');
      rethrow;
    }
  }

  /// Register user for volunteer event
  Future<bool> registerForEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      // Check if already registered
      final existingRegistration = await _client
          .from('event_registrations')
          .select('id')
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingRegistration != null) {
        throw Exception('Anda sudah terdaftar untuk event ini');
      }

      // Create registration
      await _client.from('event_registrations').insert({
        'event_id': eventId,
        'user_id': userId,
        'status': 'approved', // Auto-approve for now
        'registered_at': DateTime.now().toIso8601String(),
      });

      print('[VolunteerEventService] Successfully registered user $userId for event $eventId');
      return true;
    } catch (e) {
      print('[VolunteerEventService] Error registering for event: $e');
      rethrow;
    }
  }

  /// Cancel event registration
  Future<bool> cancelRegistration({
    required String registrationId,
  }) async {
    try {
      await _client
          .from('event_registrations')
          .update({'status': 'cancelled'})
          .eq('id', registrationId);

      print('[VolunteerEventService] Successfully cancelled registration $registrationId');
      return true;
    } catch (e) {
      print('[VolunteerEventService] Error cancelling registration: $e');
      rethrow;
    }
  }

  /// Get user's ongoing event registrations
  Future<List<EventRegistration>> fetchUserOngoingEvents({
    required String userId,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _client
          .from('event_registrations')
          .select('''
            id,
            event_id,
            user_id,
            status,
            registered_at,
            events(
              id,
              title,
              start_time,
              end_time,
              location,
              cover_image_url,
              organizations(name)
            )
          ''')
          .eq('user_id', userId)
          .neq('status', 'cancelled')
          .order('registered_at', ascending: false);

      List<EventRegistration> registrations = List<EventRegistration>.from(
        response.map((reg) {
          final event = reg['events'];
          final endTime = DateTime.parse(event['end_time']);
          
          // Only include if event has not ended yet
          if (DateTime.now().isBefore(endTime)) {
            return EventRegistration(
              id: reg['id'],
              eventId: reg['event_id'],
              userId: reg['user_id'],
              status: reg['status'],
              registeredAt: DateTime.parse(reg['registered_at']),
              eventTitle: event['title'],
              eventStartTime: DateTime.parse(event['start_time']),
              eventEndTime: DateTime.parse(event['end_time']),
              eventLocation: event['location'],
              coverImageUrl: event['cover_image_url'],
              organizationName: event['organizations']?['name'] ?? 'Organisasi',
            );
          }
          return null;
        }).whereType<EventRegistration>(),
      );

      return registrations;
    } catch (e) {
      print('[VolunteerEventService] Error fetching ongoing events: $e');
      rethrow;
    }
  }

  /// Get user's past event registrations
  Future<List<EventRegistration>> fetchUserPastEvents({
    required String userId,
  }) async {
    try {
      final response = await _client
          .from('event_registrations')
          .select('''
            id,
            event_id,
            user_id,
            status,
            registered_at,
            events(
              id,
              title,
              start_time,
              end_time,
              location,
              cover_image_url,
              organizations(name)
            )
          ''')
          .eq('user_id', userId)
          .neq('status', 'cancelled')
          .order('registered_at', ascending: false);

      List<EventRegistration> registrations = List<EventRegistration>.from(
        response.map((reg) {
          final event = reg['events'];
          final endTime = DateTime.parse(event['end_time']);
          
          // Only include if event has ended
          if (DateTime.now().isAfter(endTime)) {
            return EventRegistration(
              id: reg['id'],
              eventId: reg['event_id'],
              userId: reg['user_id'],
              status: reg['status'],
              registeredAt: DateTime.parse(reg['registered_at']),
              eventTitle: event['title'],
              eventStartTime: DateTime.parse(event['start_time']),
              eventEndTime: DateTime.parse(event['end_time']),
              eventLocation: event['location'],
              coverImageUrl: event['cover_image_url'],
              organizationName: event['organizations']?['name'] ?? 'Organisasi',
            );
          }
          return null;
        }).whereType<EventRegistration>(),
      );

      return registrations;
    } catch (e) {
      print('[VolunteerEventService] Error fetching past events: $e');
      rethrow;
    }
  }

  /// Get event details by ID
  Future<Event?> getEventById(String eventId) async {
    try {
      final response = await _client
          .from('events')
          .select('''
            id,
            organization_id,
            title,
            description,
            cover_image_url,
            category,
            location,
            city,
            start_time,
            end_time,
            quota,
            status,
            created_at,
            organizations(name)
          ''')
          .eq('id', eventId)
          .maybeSingle();

      if (response == null) return null;

      response['organization_name'] = response['organizations']?['name'] ?? 'Organisasi';
      return Event.fromMap(response);
    } catch (e) {
      print('[VolunteerEventService] Error fetching event: $e');
      return null;
    }
  }

  /// Check if user is registered for event
  Future<bool> isUserRegistered({
    required String eventId,
    required String userId,
  }) async {
    try {
      final response = await _client
          .from('event_registrations')
          .select('id')
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .eq('status', 'approved')
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('[VolunteerEventService] Error checking registration: $e');
      return false;
    }
  }
}