import 'package:supabase_flutter/supabase_flutter.dart';

class CaloriesService {
  final supabase = Supabase.instance.client;

  // --- ENTRIES (tabela: Calories) --------------------------------------------

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

  Future<List<Map<String, dynamic>>> getEntriesForDate(DateTime date) async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('Calories')
        .select('id, kcal_amount')
        .eq('user_id', user.id)
        .eq('date', date.toIso8601String().split('T').first);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deleteEntry(int id) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await supabase.from('Calories').delete().eq('id', id).eq('user_id', user.id);
  }

  // --- GOAL (tabela: usersettings) -------------------------------------------

  Future<void> setDailyGoalWithType(int kcal, String goalType) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      await supabase.from('usersettings').upsert({
        'user_id': user.id,
        'daily_goal': kcal,
        'goal_type': goalType,
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
    } catch (_) {
      await supabase.from('usersettings').upsert({
        'user_id': user.id,
        'daily_goal': kcal,
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
    }
  }

  Future<Map<String, dynamic>?> getDailyGoalWithType() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('usersettings')
        .select('*')
        .eq('user_id', user.id)
        .maybeSingle();

    return response;
  }

  Future<bool> isGoalAchieved(DateTime date) async {
    final entries = await getEntriesForDate(date);
    final total =
    entries.fold<int>(0, (sum, e) => sum + (e['kcal_amount'] as int));

    final data = await getDailyGoalWithType();
    if (data == null) return false;

    final goal = (data['daily_goal'] as int?) ?? 0;
    final type = (data['goal_type'] as String?) ?? 'greater';

    if (goal <= 0) return false;

    if (type == 'less') {
      // ✅ NOWE: tylko jeśli są wpisy
      if (entries.isEmpty) return false;
      return total <= goal;
    }

    return total >= goal;
  }
}
