import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/calendar_event.dart';

class CalendarRepository {
  final FirebaseFirestore _firestore;
  CalendarRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;


  // Initialize calendar when we know the calendarId and userId
  Future<void> initCalendar(String calendarId, List<String> participants) {
    return _firestore
        .collection('sharedCalendars')
        .doc(calendarId)
        .set({
      'participants': participants,
    });
  }
  // Stream of all events for the given calendarId.
  Stream<List<CalendarEvent>> watchEvents(String calendarId) {
    return _firestore
        .collection('sharedCalendars')
        .doc(calendarId)
        .collection('events')
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  // Add a new event under calendarId (auto‐generated ID).
  Future<void> addEvent(String calendarId, CalendarEvent event) {
    final ref = _firestore
        .collection('sharedCalendars')
        .doc(calendarId)
        .collection('events')
        .doc();
    return ref.set({
      'date': event.date.toIso8601String(),
      'title': event.title,
    });
  }

  // Delete an event by its document ID.
  Future<void> deleteEvent(String calendarId, String eventId) {
    return _firestore
        .collection('sharedCalendars')
        .doc(calendarId)
        .collection('events')
        .doc(eventId)
        .delete();
  }

  // Update an existing event (must have a valid id).
  Future<void> updateEvent(String calendarId, CalendarEvent event) {
    return _firestore
        .collection('sharedCalendars')
        .doc(calendarId)
        .collection('events')
        .doc(event.id)
        .update({
      'date': event.date.toIso8601String(),
      'title': event.title,
    });
  }

  // convert a Firestore doc to the Event model.
  CalendarEvent _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final date = DateTime.parse(data['date'] as String);
    return CalendarEvent(
      id: doc.id,
      date: date,
      title: data['title'] as String,
    );
  }
}
