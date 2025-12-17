class EventRegistration {
  final String id;
  final String eventId;
  final String userId;
  final String status; // 'pending', 'approved', 'rejected', 'attended', 'cancelled'
  final DateTime registeredAt;
  final String? eventTitle;
  final DateTime? eventStartTime;
  final DateTime? eventEndTime;
  final String? eventLocation;
  final String? coverImageUrl;
  final String? organizationName;

  EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.registeredAt,
    this.eventTitle,
    this.eventStartTime,
    this.eventEndTime,
    this.eventLocation,
    this.coverImageUrl,
    this.organizationName,
  });

  factory EventRegistration.fromMap(Map<String, dynamic> map) {
    return EventRegistration(
      id: map['id'] ?? '',
      eventId: map['event_id'] ?? '',
      userId: map['user_id'] ?? '',
      status: map['status'] ?? 'pending',
      registeredAt: DateTime.parse(map['registered_at'] ?? DateTime.now().toIso8601String()),
      eventTitle: map['event_title'] ?? map['title'],
      eventStartTime: map['start_time'] != null ? DateTime.parse(map['start_time']) : null,
      eventEndTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      eventLocation: map['location'],
      coverImageUrl: map['cover_image_url'],
      organizationName: map['organization_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'status': status,
      'registered_at': registeredAt.toIso8601String(),
    };
  }

  bool get isActive {
    final now = DateTime.now();
    return (eventEndTime == null || now.isBefore(eventEndTime!)) && 
           (status == 'approved' || status == 'pending');
  }

  bool get isPast {
    final now = DateTime.now();
    return eventEndTime != null && now.isAfter(eventEndTime!);
  }

  String get displayStatus {
    switch (status) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'attended':
        return 'Hadir';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}