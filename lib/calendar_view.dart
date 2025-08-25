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
                onPressed: () => _showSetGoalDialog(),
              ),
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
      spacing: 12,
      runSpacing: 12,
      children: List.generate(totalDays, (index) {
        final day = index + 1;
        final date = DateTime(currentDate.year, currentDate.month, day);

        return FutureBuilder<bool>(
          future: _service.isGoalAchieved(date),
          builder: (context, goalSnapshot) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _service.getEntriesForDate(date),
              builder: (context, entriesSnapshot) {
                final entries = entriesSnapshot.data ?? [];
                final total = entries.fold<int>(0, (sum, e) => sum + (e['kcal_amount'] as int));

                final achieved = goalSnapshot.data ?? false;

                return GestureDetector(
                  onTap: widget.canAddCalories
                      ? () => _showDayDetailsDialog(date, entries)
                      : null,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: achieved
                          ? Colors.green[400] // ✅ cel osiągnięty
                          : Colors.transparent, // ✅ tylko wartości bez tła
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      total > 0 ? "$day\n$total" : "$day",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, fontFamily: 'ComicSans'),
                    ),
                  ),
                );
              },
            );
          },
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

  void _showDayDetailsDialog(DateTime date, List<Map<String, dynamic>> entries) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Entries for ${date.day}.${date.month}"),
          content: entries.isEmpty
              ? const Text("No entries yet.")
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: entries.map((e) {
              return ListTile(
                title: Text("${e['kcal_amount']} kcal"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _service.deleteEntry(e['id']);
                    if (mounted) {
                      Navigator.pop(ctx);
                      setState(() {}); // odśwież kalendarz
                    }
                  },
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showAddCaloriesDialog(date.day);
              },
              child: const Text("Add calories"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSetGoalDialog() async {
    int? currentGoal;
    try {
      currentGoal = await _service.getDailyGoal();
    } catch (_) {}

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
      if (mounted) setState(() {});
    }
  }
}
