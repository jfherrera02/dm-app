import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/calendar_repository.dart';
import '../domain/calendar_event.dart';
import 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final CalendarRepository _repo;
  StreamSubscription<List<CalendarEvent>>? _sub;
  final String calendarId;

  // list of UIDs who can see this calendar
  final List<String> participants;

  CalendarCubit({
    required this.calendarId,
    required CalendarRepository repository,
    List<String>? participants,
  })  : _repo = repository,
        // if participants are not passed explicitly, assume a 1-person (self) calendar
        participants = participants ?? [calendarId],
        super(CalendarState.initial()) {
    // ENSURE the calendar doc exists with the correct participants
    _repo.initCalendar(calendarId, this.participants);

    // THEN start listening for its events
    _sub = _repo.watchEvents(calendarId).listen(_onEventsUpdated);
  }

  void _onEventsUpdated(List<CalendarEvent> allEvents) {
    final Map<DateTime, List<CalendarEvent>> byDay = {};
    for (final ev in allEvents) {
      final key = DateTime(ev.date.year, ev.date.month, ev.date.day);
      byDay.putIfAbsent(key, () => []).add(ev);
    }
    emit(state.copyWith(eventsByDay: byDay));
  }

  void selectDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    emit(state.copyWith(selectedDate: key));
  }

  Future<void> addEvent(String title) async {
    final date = state.selectedDate;
    final newEvent = CalendarEvent(
      id: '',
      date: date,
      title: title,
    );
    await _repo.addEvent(calendarId, newEvent);
  }

  Future<void> deleteEvent(String eventId) {
    return _repo.deleteEvent(calendarId, eventId);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
