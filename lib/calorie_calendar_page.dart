import 'package:flutter/material.dart';
import 'calendar_view.dart';

class CalorieCalendarPage extends StatelessWidget {
  const CalorieCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CalendarView(
        title: 'Calorie Calendar',
        canAddCalories: true,   // <-- to dodajemy
      ),
    );
  }
}
