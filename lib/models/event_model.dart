class Event {
  final String id;
  final String organizationId;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final String category; // 'volunteer' or 'donation'
  final String? location;
  final String? city;
  final DateTime startTime;
  final DateTime endTime;
  final int? quota;
  final String status; // 'draft', 'open', 'closed', 'completed'
  final DateTime createdAt;
  final String? organizationName;
  final int? registeredCount;

  Event({
    required this.id,
    required this.organizationId,
    required this.title,
    this.description,
    this.coverImageUrl,
    required this.category,
    this.location,
    this.city,
    required this.startTime,
    required this.endTime,
    this.quota,
    required this.status,
    required this.createdAt,
    this.organizationName,
    this.registeredCount,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      organizationId: map['organization_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      coverImageUrl: map['cover_image_url'],
      category: map['category'] ?? 'volunteer',
      location: map['location'],
      city: map['city'],
      startTime: DateTime.parse(map['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(map['end_time'] ?? DateTime.now().toIso8601String()),
      quota: map['quota'],
      status: map['status'] ?? 'open',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      organizationName: map['organization_name'],
      registeredCount: map['registered_count'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organization_id': organizationId,
      'title': title,
      'description': description,
      'cover_image_url': coverImageUrl,
      'category': category,
      'location': location,
      'city': city,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'quota': quota,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isUpcoming => DateTime.now().isBefore(startTime);
  bool get isOngoing => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isCompleted => DateTime.now().isAfter(endTime);
  bool get isFull => (registeredCount ?? 0) >= (quota ?? 999);
  bool get canRegister => status == 'open' && !isFull && isUpcoming;
}