import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'training_calendar_page.dart';
import 'calorie_calendar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Column(
        children: [
          // Nagłówek
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.green[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fitolongo',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'ComicSans',
                  ),
                ),
                Row(
                  children: [
                    if (user == null) ...[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login').then((_) {
                            setState(() {});
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Login'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register').then((_) {
                            setState(() {});
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Register'),
                      ),
                    ] else ...[
                      Text(
                        'Hello, ${user.email}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await supabase.auth.signOut();
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[300],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Kafelki
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MenuTile(
                    title: 'Training Calendar',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TrainingCalendarPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _MenuTile(
                    title: 'Calorie Calendar',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CalorieCalendarPage(),
                        ),
                      );
                    },
                  ),
                ],
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
}

class _MenuTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _MenuTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'ComicSans',
            ),
          ),
        ),
      ),
    );
  }
}
