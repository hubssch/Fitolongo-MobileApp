import 'package:supabase_flutter/supabase_flutter.dart';

class CaloriesService {
  final supabase = Supabase.instance.client;

  // Dodanie kalorii przypisanych do użytkownika
  Future<void> addCalories(int kcal, DateTime date) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await supabase.from('Calories').insert({
      'user_id': user.id,
      'kcal_amount': kcal,
      'date': date.toIso8601String().split('T').first,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Pobranie kalorii dla konkretnego dnia
  Future<int> getCaloriesForDate(DateTime date) async {
    final user = supabase.auth.currentUser;
    if (user == null) return 0;

    final response = await supabase
        .from('Calories')
        .select('kcal_amount')
        .eq('user_id', user.id)
        .eq('date', date.toIso8601String().split('T').first);

    if (response.isEmpty) return 0;

    return response.fold<int>(
      0,
          (sum, row) => sum + (row['kcal_amount'] as int),
    );
  }

  // Ustawienie celu (w tabeli UserSettings)
  Future<void> setDailyGoal(int kcal) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await supabase.from('usersettings').upsert({
      'user_id': user.id,
      'daily_goal': kcal,
      'created_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  // Pobranie celu
  Future<int?> getDailyGoal() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('usersettings')
        .select('daily_goal')
        .eq('user_id', user.id)
        .maybeSingle();

    return response?['daily_goal'] as int?;
  }

  // Sprawdzenie czy cel osiągnięty
  Future<bool> isGoalAchieved(DateTime date) async {
    final total = await getCaloriesForDate(date);
    final goal = await getDailyGoal() ?? 0;
    return total >= goal && goal > 0;
  }
}
