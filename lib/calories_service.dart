import 'package:supabase_flutter/supabase_flutter.dart';

class CaloriesService {
  final supabase = Supabase.instance.client;

  // Add new calories entry
  Future<void> addCalories(int kcal, DateTime date) async {
    await supabase.from('Calories').insert({
      'kcal_amount': kcal,
      'date': date.toIso8601String().substring(0, 10),
    });
  }

  // Get calories by date
  Future<List<Map<String, dynamic>>> getCaloriesByDate(DateTime date) async {
    final String day = date.toIso8601String().substring(0, 10);
    final response = await supabase
        .from('Calories')
        .select()
        .eq('date', day)
        .order('created_at', ascending: true);

    return response;
  }

  // Delete entry by id
  Future<void> deleteCaloriesById(String id) async {
    await supabase.from('Calories').delete().eq('id', id);
  }
}
