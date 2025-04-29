// Create a calendar page for the rest of the users 
// so users can share their calendar with other users - 1 on 1

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

Widget buildFriendsCalendar(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Friends Calendar'),
    ),
    body: Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: DateTime.now(),
          calendarFormat: CalendarFormat.month,
          onFormatChanged: (format) {},
          onPageChanged: (focusedDay) {},
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Add more widgets here as needed
      ],
    ),
  );
}