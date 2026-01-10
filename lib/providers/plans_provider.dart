import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. The Data Model
class Plan {
  final String title;
  final List<String> features;
  final double price;

  Plan({
    required this.title,
    required this.features,
    required this.price,
  });

  // Convert Database JSON to Plan Object (Safe Version)
  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      title: map['title'] as String? ?? 'Unknown',
      // Safely handle price (int or double)
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      // Safely handle features list
      features: (map['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Plan copyWith({String? title, List<String>? features, double? price}) {
    return Plan(
      title: title ?? this.title,
      features: features ?? this.features,
      price: price ?? this.price,
    );
  }
}

// 2. The Logic (StateNotifier)
class PlansNotifier extends StateNotifier<List<Plan>> {
  PlansNotifier() : super([]) {
    loadPlans(); // Auto-load when app starts
  }

  Future<void> loadPlans() async {
    try {
      final response = await Supabase.instance.client
          .from('plans')
          .select()
          .order('id', ascending: true);

      final data = response as List<dynamic>;
      state = data.map((item) => Plan.fromMap(item)).toList();
    } catch (e) {
      // print('Error loading plans: $e');
    }
  }

  Future<void> updatePrice(String planTitle, double newPrice) async {
    try {
      // 1. Update Database
      await Supabase.instance.client
          .from('plans')
          .update({'price': newPrice})
          .eq('title', planTitle);

      // 2. Update App State Instantly
      state = [
        for (final plan in state)
          if (plan.title == planTitle) plan.copyWith(price: newPrice) else plan
      ];
    } catch (e) {
      // print('Error updating price: $e');
    }
  }
}

// 3. The Provider
final plansProvider = StateNotifierProvider<PlansNotifier, List<Plan>>((ref) {
  return PlansNotifier();
});