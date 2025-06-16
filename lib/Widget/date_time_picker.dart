import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DateTimePicker extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;
  String? className;

  DateTimePicker({
    super.key,
    required this.onDateSelected,
    this.className,
  });

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  DateTime today = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<DateTime> _markedDates = [];

  @override
  void initState() {
    super.initState();
    _fetchMarkedDates();
  }

  void _fetchMarkedDates() async {
    await FirebaseFirestore.instance
      .collection('reports')
      .where('className', isEqualTo: widget.className)
      .get()
      .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        DateTime date = DateTime.parse(document['selectedDate']);
        print('Adding date to _markedDates: $date');
        if (!_markedDates.contains(date)) {
          _markedDates.add(date);
        }
      });
      setState(() {});
    });
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _selectedDay = day;
    });
    widget.onDateSelected(day); // Call the onDateSelected callback
  }

  void _confirmDateSelection() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 2, 88, 96),
        title: Text(
          "Select Date",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'en_us',
            rowHeight: 100,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            onDaySelected: _onDaySelected,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            focusedDay: _selectedDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            firstDay: DateTime.utc(2000, 01, 01),
            lastDay: DateTime.utc(2100, 01, 01),
            eventLoader: (day) {
              return _markedDates.any((markedDay) => isSameDay(markedDay, day)) ? [{}] : [];
            },
            availableGestures: AvailableGestures.all,
            enabledDayPredicate: (day) => day.isBefore(today) || isSameDay(day, today),
          ),
          Spacer(), // This will take up the remaining space
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _confirmDateSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 88, 96),
                ),
                child: Text(
                  "Confirm",
                  style: TextStyle(
                    color: Colors.white, // White text
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}