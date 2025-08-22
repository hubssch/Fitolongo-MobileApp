import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'calories_service.dart';

class CalendarView extends StatefulWidget {
  final String title;
  final bool canAddCalories;

  const CalendarView({
    super.key,
    required this.title,
    this.canAddCalories = false,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final CaloriesService _service = CaloriesService();
  DateTime currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontFamily: 'ComicSans')),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          if (user != null) ...[
            if (widget.canAddCalories)
              IconButton(
                icon: const Icon(Icons.flag),
                tooltip: 'Set Daily Goal',
                onPressed: () => _showSetGoalDialog(), // ważne: wywołanie
              ),
            // Pokaż kto jest zalogowany
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  user.email ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) setState(() {});
              },
            ),
          ] else ...[
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login')
                  .then((_) => setState(() {})),
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register')
                  .then((_) => setState(() {})),
              child: const Text('Register', style: TextStyle(color: Colors.white)),
            ),
          ]
        ],
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
          FutureBuilder<int?>(
            future: _service.getDailyGoal(),
            builder: (context, snapshot) {
              final goal = snapshot.data;
              return Container(
                padding: const EdgeInsets.all(12),
                color: Colors.green[800],
                width: double.infinity,
                child: Center(
                  child: Text(
                    goal != null
                        ? 'Your daily goal: $goal kcal'
                        : 'No daily goal set',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              );
            },
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
        final date = DateTime(currentDate.year, currentDate.month, day);

        return GestureDetector(
          onTap: widget.canAddCalories ? () => _showAddCaloriesDialog(day) : null,
          child: FutureBuilder<bool>(
            future: _service.isGoalAchieved(date),
            builder: (context, snapshot) {
              final achieved = snapshot.data ?? false;

              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: achieved ? Colors.green : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  day.toString(),
                  style: const TextStyle(fontFamily: 'ComicSans'),
                ),
              );
            },
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
                final int? kcal = int.tryParse(controller.text);
                if (kcal == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid number')),
                  );
                  return;
                }
                await _service.addCalories(kcal, selected);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {}); // odśwież kalendarz
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSetGoalDialog() async {
    // Pobierz aktualny goal, ale nie blokuj wyświetlenia dialogu jeśli coś się wysypie
    int? currentGoal;
    try {
      currentGoal = await _service.getDailyGoal();
    } catch (_) {
      // ignorujemy – pokażemy puste pole
    }

    final controller = TextEditingController(text: currentGoal?.toString() ?? '');

    final kcal = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Daily Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter daily kcal goal',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx, int.tryParse(controller.text));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (kcal != null) {
      await _service.setDailyGoal(kcal);
      if (mounted) setState(() {}); // odśwież widok po zapisaniu celu
    }
  }
}
