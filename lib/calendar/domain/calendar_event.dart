
// A single calendar event
class CalendarEvent {
  /// Firestore document ID
  final String id;

  // The date of the event
  final DateTime date;

  // A short title or description
  final String title;

  CalendarEvent({
    required this.id,
    required this.date,
    required this.title,
  });

  // Convert to a Map to use .set() or .update() in Firestore
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'title': title,
    };
  }

  // Create from Firestore document data, using the doc ID as `id`.
  factory CalendarEvent.fromJson(String id, Map<String, dynamic> json) {
    return CalendarEvent(
      id: id,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
    );
  }

  @override
  String toString() => title;
}
