import 'package:equatable/equatable.dart';
import '../domain/calendar_event.dart';

class CalendarState extends Equatable {
  // events grouped by day
  final Map<DateTime, List<CalendarEvent>> eventsByDay;

  // Which day is currently selected in the UI
  final DateTime selectedDate;

  const CalendarState({
    required this.eventsByDay,
    required this.selectedDate,
  });

  // Start with no events, today selected
  factory CalendarState.initial() {
    final today = DateTime.now();
    final key = DateTime(today.year, today.month, today.day);
    return CalendarState(eventsByDay: {}, selectedDate: key);
  }

  CalendarState copyWith({
    Map<DateTime, List<CalendarEvent>>? eventsByDay,
    DateTime? selectedDate,
  }) {
    return CalendarState(
      eventsByDay: eventsByDay ?? this.eventsByDay,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [eventsByDay, selectedDate];
}
