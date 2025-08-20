import 'package:flutter/material.dart';
import 'calendar_view.dart';

class TrainingCalendarPage extends StatelessWidget {
  const TrainingCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CalendarView(
        title: 'Training Calendar',
      ),
    );
  }
}
