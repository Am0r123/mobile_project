import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- THEME PROVIDER ---
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system; // Default state
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

// --- SUBSCRIPTION PROVIDER ---
class SubscriptionState {
  final bool showDashboard;
  final bool showTrainers;
  final bool isLoading;

  SubscriptionState({
    this.showDashboard = false,
    this.showTrainers = false,
    this.isLoading = true,
  });
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() {
    _checkSubscription();
    return SubscriptionState();
  }

  Future<void> _checkSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final planName = prefs.getString('user_plan');

    bool showDashboard = false;
    bool showTrainers = false;

    if (planName == 'Pro') {
      showDashboard = true;
      showTrainers = false;
    } else if (planName == 'Nutrition') {
      showDashboard = true;
      showTrainers = true;
    }

    state = SubscriptionState(
      showDashboard: showDashboard,
      showTrainers: showTrainers,
      isLoading: false,
    );
  }

  // Call this to force a refresh after payment
  Future<void> refresh() async {
    state = SubscriptionState(isLoading: true, showDashboard: state.showDashboard, showTrainers: state.showTrainers);
    await _checkSubscription();
  }
}

final subscriptionProvider = 
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(SubscriptionNotifier.new);