/*
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
  });

  @override
  String toString() {
    return 'CalendarEvent{id: $id, title: $title, description: $description, startTime: $startTime, endTime: $endTime}';
  }
}
*/ 

class Event {
  final String title;
  Event(this.title);
}