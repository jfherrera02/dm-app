import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Store events as a map where the key is the date and the value is the event description
  final Map<DateTime, String> _events = {};

  // Current month and year
  DateTime _currentDate = DateTime.now();

  // Function to add an event
  void _addEvent(DateTime date, String event) {
    setState(() {
      _events[date] = event;
    });
  }

  // Function to navigate to the previous month
  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    });
  }

  // Function to navigate to the next month
  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    });
  }

  // Function to build the calendar grid
  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday;

    List<TableRow> rows = [];
    List<Widget> currentRow = [];

    // Add empty cells for days before the first day of the month
    for (int i = 1; i < startingWeekday; i++) {
      currentRow.add(const TableCell(child: SizedBox()));
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentDate.year, _currentDate.month, day);
      final event = _events[date];

      currentRow.add(
        TableCell(
          child: GestureDetector(
            onTap: () {
              _showEventDialog(date);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    day.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (event != null)
                    Text(
                      event,
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      // Start a new row after every 7 days
      if ((day + startingWeekday - 1) % 7 == 0) {
        rows.add(TableRow(children: currentRow));
        currentRow = [];
      }
    }

    // Add remaining empty cells for the last row
    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(const TableCell(child: SizedBox()));
      }
      rows.add(TableRow(children: currentRow));
    }

    return Table(
      children: rows,
    );
  }

  // Function to show a dialog for adding an event
  void _showEventDialog(DateTime date) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Event on ${date.day}/${date.month}/${date.year}"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Event description"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _addEvent(date, controller.text);
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${_currentDate.year}-${_currentDate.month}",
          style: const TextStyle(fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _previousMonth,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _nextMonth,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Weekday headers
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Mon", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Tue", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Wed", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Thu", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Fri", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Sat", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Sun", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            // Calendar grid
            Expanded(child: _buildCalendar()),
          ],
        ),
      ),
    );
  }
}