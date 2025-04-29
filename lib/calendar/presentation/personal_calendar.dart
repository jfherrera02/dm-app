// Placeholder for the personal calendar page
import 'package:dmessages/calendar/domain/calendar_event.dart';
import 'package:dmessages/calendar/presentation/friends_calendar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PersonalCalendarPage extends StatefulWidget {
  const PersonalCalendarPage({super.key});

  @override
  PersonalCalendarPageState createState() => PersonalCalendarPageState();
}

class PersonalCalendarPageState extends State<PersonalCalendarPage> {
  // Format for the calendar
  CalendarFormat calendarFormat = CalendarFormat.month;
  // This is the selected day in the calendar
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  // State Notifier for the calendar
  late final ValueNotifier<List<Event>> selectedEvents;
  // Controllers for user input
  TextEditingController eventController = TextEditingController();

  // Map to hold events for each day
  Map<DateTime, List<Event>> events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));    
  }

  @override
  void dispose() {
    eventController.dispose();
    selectedEvents.dispose();
    super.dispose();
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // Update the selected day and focused day
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    // Update the events for the selected day
    selectedEvents.value = _getEventsForDay(selectedDay);
  }

  // Function to get events for a specific day
  List<Event> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return events[key] ?? [];
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calendar'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Personal'),
              Tab(text: 'Shared'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Handle the action for adding a new event
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  scrollable: true,
                  title: const Text('Add Event'),
                  content: TextField(
                    controller: eventController,
                    decoration: const InputDecoration(hintText: 'Event Title'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Add the event to the selected day
                        if (_selectedDay != null && eventController.text.isNotEmpty) {
                          final key = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                          setState(() {
                            events[key] = [
                              ..._getEventsForDay(_selectedDay!),
                              Event(eventController.text),
                            ];
                            selectedEvents.value = _getEventsForDay(_selectedDay!);
                          });
                        }
                        Navigator.of(context).pop();
                        eventController.clear();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                TableCalendar<Event>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: onDaySelected,
                  calendarFormat: calendarFormat,
                  onFormatChanged: (format) {
                    setState(() => calendarFormat = format);
                  },
                  onPageChanged: (focused) => _focusedDay = focused,
                  eventLoader: _getEventsForDay,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                    CalendarFormat.twoWeeks: '2 Weeks',
                    CalendarFormat.week: 'Week',
                  },
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: true,
                    formatButtonShowsNext: false,
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox();
                      return Positioned(
                        bottom: 4,
                        child: Column(
                          children: events.map((e) {
                            return Container(
                              width: 20,
                              height: 4,
                              margin: const EdgeInsets.symmetric(vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  // convert the selected day to a string format
                  _selectedDay != null
                      ? 'Events for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                      : 'Select a day',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ValueListenableBuilder<List<Event>>(
                    valueListenable: selectedEvents,
                    builder: (context, value, _) {
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
                              onTap: () => print('Event tapped: ${value[index]}'),
                              title: Text(value[index].title),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Handle delete event action
                                  setState(() {
                                    final key = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                                    events[key]!.removeAt(index);
                                    selectedEvents.value = _getEventsForDay(_selectedDay!);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            buildFriendsCalendar(context),
          ],
        ),
      ),
    );
  }
}
