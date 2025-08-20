import 'package:flutter/material.dart';
import 'calories_service.dart';

class CalendarView extends StatefulWidget {
  final String title;
  final bool canAddCalories; // <-- NEW

  const CalendarView({
    super.key,
    required this.title,
    this.canAddCalories = false, // default false (np. dla treningów)
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final CaloriesService _service = CaloriesService();

  DateTime currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontFamily: 'ComicSans')),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[400],
      body: Column(
        children: [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              currentDate = DateTime(
                                currentDate.year,
                                currentDate.month - 1,
                              );
                            });
                          },
                        ),
                        Text(
                          "${_monthName(currentDate.month)} ${currentDate.year}",
                          style: const TextStyle(
                            fontSize: 28,
                            fontFamily: 'ComicSans',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              currentDate = DateTime(
                                currentDate.year,
                                currentDate.month + 1,
                              );
                            });
                          },
                        ),
                      ],
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
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green[800],
            width: double.infinity,
            child: const Center(
              child: Text(
                'Stay fit for a long time',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Widget _buildWeekDays() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((d) => Text(d)).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final totalDays = DateTime(currentDate.year, currentDate.month + 1, 0).day;

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: List.generate(totalDays, (index) {
        final day = index + 1;

        return GestureDetector(
          onTap: widget.canAddCalories ? () => _showAddCaloriesDialog(day) : null,
          child: Text(
            day.toString(),
            style: const TextStyle(fontFamily: 'ComicSans'),
          ),
        );
      }),
    );
  }

  void _showAddCaloriesDialog(int day) {
    final TextEditingController controller = TextEditingController();
    final selected = DateTime(currentDate.year, currentDate.month, day);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add calories for $day'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Calories'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final int kcal = int.parse(controller.text);
                await _service.addCalories(kcal, selected);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
