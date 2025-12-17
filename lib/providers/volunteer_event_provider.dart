import 'package:flutter/material.dart';
import 'package:bersatubantu/models/event_model.dart';
import 'package:bersatubantu/models/event_registration_model.dart';
import 'package:bersatubantu/services/volunteer_event_service.dart';

class VolunteerEventProvider extends ChangeNotifier {
  final VolunteerEventService _service = VolunteerEventService();

  // Open volunteer events
  List<Event> openEvents = [];
  bool isLoadingOpenEvents = false;
  String? openEventsError;

  // Filtered events
  List<Event> filteredEvents = [];
  bool isLoadingFilteredEvents = false;
  String? filteredEventsError;

  // User's ongoing events
  List<EventRegistration> ongoingEvents = [];
  bool isLoadingOngoingEvents = false;
  String? ongoingEventsError;

  // User's past events
  List<EventRegistration> pastEvents = [];
  bool isLoadingPastEvents = false;
  String? pastEventsError;

  // Event detail
  Event? selectedEvent;
  bool isCheckingRegistration = false;
  bool isUserRegistered = false;

  // Last action message
  String? lastMessage;

  // Fetch all open volunteer events
  Future<void> loadOpenEvents() async {
    isLoadingOpenEvents = true;
    openEventsError = null;
    notifyListeners();

    try {
      openEvents = await _service.fetchOpenVolunteerEvents();
      print('[VolunteerEventProvider] Loaded ${openEvents.length} open events');
    } catch (e) {
      openEventsError = 'Gagal memuat event: $e';
      print('[VolunteerEventProvider] Error: $openEventsError');
    }

    isLoadingOpenEvents = false;
    notifyListeners();
  }

  // Filter events by city and search query
  Future<void> filterEvents({
    String? city,
    String? searchQuery,
  }) async {
    isLoadingFilteredEvents = true;
    filteredEventsError = null;
    notifyListeners();

    try {
      filteredEvents = await _service.fetchFilteredVolunteerEvents(
        city: city,
        searchQuery: searchQuery,
      );
      print('[VolunteerEventProvider] Filtered to ${filteredEvents.length} events');
    } catch (e) {
      filteredEventsError = 'Gagal filter event: $e';
      print('[VolunteerEventProvider] Error: $filteredEventsError');
    }

    isLoadingFilteredEvents = false;
    notifyListeners();
  }

  // Register for an event
  Future<bool> registerForEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      final result = await _service.registerForEvent(
        eventId: eventId,
        userId: userId,
      );

      if (result) {
        lastMessage = 'Berhasil mendaftar untuk event!';
        
        // Update registration status for selected event
        if (selectedEvent?.id == eventId) {
          isUserRegistered = true;
          notifyListeners();
        }
        
        // Reload events
        await loadOpenEvents();
      }

      return result;
    } catch (e) {
      lastMessage = 'Gagal mendaftar: $e';
      print('[VolunteerEventProvider] Registration error: $e');
      notifyListeners();
      return false;
    }
  }

  // Cancel event registration
  Future<bool> cancelRegistration({
    required String registrationId,
  }) async {
    try {
      final result = await _service.cancelRegistration(
        registrationId: registrationId,
      );

      if (result) {
        lastMessage = 'Pendaftaran dibatalkan';
        
        // Reload ongoing and past events
        await loadUserOngoingEvents(userId: '');
        await loadUserPastEvents(userId: '');
      }

      return result;
    } catch (e) {
      lastMessage = 'Gagal membatalkan: $e';
      print('[VolunteerEventProvider] Cancellation error: $e');
      notifyListeners();
      return false;
    }
  }

  // Load user's ongoing events
  Future<void> loadUserOngoingEvents({
    required String userId,
  }) async {
    if (userId.isEmpty) return;

    isLoadingOngoingEvents = true;
    ongoingEventsError = null;
    notifyListeners();

    try {
      ongoingEvents = await _service.fetchUserOngoingEvents(userId: userId);
      print('[VolunteerEventProvider] Loaded ${ongoingEvents.length} ongoing events');
    } catch (e) {
      ongoingEventsError = 'Gagal memuat event: $e';
      print('[VolunteerEventProvider] Error: $ongoingEventsError');
    }

    isLoadingOngoingEvents = false;
    notifyListeners();
  }

  // Load user's past events
  Future<void> loadUserPastEvents({
    required String userId,
  }) async {
    if (userId.isEmpty) return;

    isLoadingPastEvents = true;
    pastEventsError = null;
    notifyListeners();

    try {
      pastEvents = await _service.fetchUserPastEvents(userId: userId);
      print('[VolunteerEventProvider] Loaded ${pastEvents.length} past events');
    } catch (e) {
      pastEventsError = 'Gagal memuat event: $e';
      print('[VolunteerEventProvider] Error: $pastEventsError');
    }

    isLoadingPastEvents = false;
    notifyListeners();
  }

  // Load event details and check registration status
  Future<void> loadEventDetails({
    required String eventId,
    required String userId,
  }) async {
    try {
      selectedEvent = await _service.getEventById(eventId);
      
      if (selectedEvent != null) {
        isCheckingRegistration = true;
        notifyListeners();

        isUserRegistered = await _service.isUserRegistered(
          eventId: eventId,
          userId: userId,
        );

        print('[VolunteerEventProvider] Event registered: $isUserRegistered');
      }
    } catch (e) {
      print('[VolunteerEventProvider] Error loading event details: $e');
    }

    isCheckingRegistration = false;
    notifyListeners();
  }

  // Clear selected event
  void clearSelectedEvent() {
    selectedEvent = null;
    isUserRegistered = false;
    notifyListeners();
  }

  // Clear messages
  void clearMessage() {
    lastMessage = null;
    notifyListeners();
  }

  // Get ongoing events by status
  List<EventRegistration> getOngoingByStatus(String status) {
    if (status == 'all') return ongoingEvents;
    return ongoingEvents.where((event) => event.status == status).toList();
  }

  // Get past events by status
  List<EventRegistration> getPastByStatus(String status) {
    if (status == 'all') return pastEvents;
    return pastEvents.where((event) => event.status == status).toList();
  }
}