import 'package:dmessages/calendar/domain/calendar_cubit.dart';
import 'package:dmessages/calendar/domain/calendar_state.dart';
import 'package:dmessages/calendar/domain/calendar_event.dart';
import 'package:dmessages/calendar/presentation/friends_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class PersonalCalendarPage extends StatefulWidget {
  const PersonalCalendarPage({super.key});

  @override
  PersonalCalendarPageState createState() => PersonalCalendarPageState();
}

class PersonalCalendarPageState extends State<PersonalCalendarPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  // Format for the calendar
  CalendarFormat calendarFormat = CalendarFormat.month;

  // Controllers for user input
  final TextEditingController eventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() { setState(() {}); });
  }

  @override
  void dispose() {
    _tabController.dispose();
    eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        // the currently selected day from cubit
        final selectedDay = state.selectedDate;
        final eventsForDay = state.eventsByDay[selectedDay] ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Calendar'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Personal'),
                Tab(text: 'Shared'),
              ],
            ),
          ),
          floatingActionButton: _tabController.index == 0
              ? FloatingActionButton(
                  onPressed: () {
                    final parentContext = context;
                    showDialog(
                      context: parentContext,
                      builder: (dialogContext) {
                        return AlertDialog(
                          scrollable: true,
                          title: const Text('Add Event'),
                          content: TextField(
                            controller: eventController,
                            decoration: const InputDecoration(
                              hintText: 'Enter event title',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                eventController.clear();
                              },
                              child: const Text('Cancel'),
                            ),
                            // Save button to add the event
                            TextButton(
                              onPressed: () {
                                final title = eventController.text.trim();
                                if (title.isNotEmpty) {
                                  parentContext
                                      .read<CalendarCubit>()
                                      .addEvent(title);
                                }
                                Navigator.of(dialogContext).pop();
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
                )
              : null,
          body: TabBarView(
            controller: _tabController,
            children: [
              Column(
                children: [
                  TableCalendar<CalendarEvent>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: state.selectedDate,
                    selectedDayPredicate: (day) =>
                        isSameDay(day, state.selectedDate),
                    onDaySelected: (selected, focused) {
                      // tell cubit we selected a new date
                      context
                          .read<CalendarCubit>()
                          .selectDate(selected);
                    },
                    calendarFormat: calendarFormat,
                    onFormatChanged: (format) {
                      setState(() => calendarFormat = format);
                    },
                    onPageChanged: (focused) {
                      // no-op or update the focused day
                    },
                    eventLoader: (day) {
                      final key =
                          DateTime(day.year, day.month, day.day);
                      return state.eventsByDay[key] ?? [];
                    },
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
                        // stacked bars per event
                        return Positioned(
                          bottom: 4,
                          child: Column(
                            children: List.generate(
                              events.length,
                              (_) => Container(
                                width: 20,
                                height: 4,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius:
                                      BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    // show which day we’re looking at
                    'Events for ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: eventsForDay.length,
                      itemBuilder: (context, index) {
                        final ev = eventsForDay[index];
                        return Container(
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.event),
                            title: Text(ev.title),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // delete via cubit
                                context
                                    .read<CalendarCubit>()
                                    .deleteEvent(ev.id);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              FriendsList(context),
            ],
          ),
        );
      },
    );
  }
}
