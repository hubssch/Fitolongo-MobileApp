import 'package:flutter/material.dart';

class CalendarView extends StatelessWidget {
  final String title;

  const CalendarView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'ComicSans',
          ),
        ),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[400],
      body: Column(
        children: [
          // Główna zawartość kalendarza
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'July',
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'ComicSans',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildWeekDays(),
                    const SizedBox(height: 12),
                    _buildCalendarGrid(),
                  ],
                ),
              ),
            ),
          ),

          // Stopka
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green[800],
            width: double.infinity,
            child: const Center(
              child: Text(
                'Stay fit for a long time',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'ComicSans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map((d) => Text(
        d,
        style: const TextStyle(fontFamily: 'ComicSans'),
      ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    const daysInMonth = 31;
    List<Widget> dayWidgets = [];

    for (int i = 1; i <= daysInMonth; i++) {
      dayWidgets.add(Text(
        i.toString(),
        style: const TextStyle(fontFamily: 'ComicSans'),
      ));
    }

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: dayWidgets,
    );
  }
}
