import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/AboutUS.dart';
import 'screens/notfication.dart';
import 'screens/shop.dart';
import 'screens/setup_page.dart';
import 'screens/trainers_page.dart';
import 'screens/workout_page.dart';
import 'screens/Login.dart';
import 'screens/plans_page.dart';
import 'screens/ContactPage.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: 'https://cueajqxtidewvduxjlvi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN1ZWFqcXh0aWRld3ZkdXhqbHZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3MTE0MjMsImV4cCI6MjA4MTI4NzQyM30._454zHSeliyJPzb43dUySzXlPRjWBsVvo6qkdhJDv8I',
  );

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  Future<bool> _isSetupDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('setupDone') ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. WATCH THEME PROVIDER
    final currentThemeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111111),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: currentThemeMode, // Use state from Riverpod
      home: FutureBuilder<bool>(
        future: _isSetupDone(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If setup not done, show SetupPage
          if (!(snapshot.data ?? false)) {
            return const SetupPage(); // No arguments needed now!
          }

          return const MainLayout();
        },
      ),
    );
  }
}

/* ============================= MAIN LAYOUT ============================= */

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];
  List<String> _titles = [];

  @override
  Widget build(BuildContext context) {
    // 3. WATCH SUBSCRIPTION PROVIDER
    // This automatically rebuilds when permissions change!
    final subState = ref.watch(subscriptionProvider);

    if (subState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Build pages based on provider state
    _buildPages(subState.showDashboard, subState.showTrainers);

    // Safety check
    if (_selectedIndex >= _pages.length) _selectedIndex = 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme(!isDark);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: Text(
                    'FGYM',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _titles.length,
                  itemBuilder: (context, index) {
                    return _DrawerItem(
                      icon: _getIconForTitle(_titles[index]),
                      title: _titles[index],
                      isActive: _selectedIndex == index,
                      onTap: () => _onSelectPage(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  void _buildPages(bool showDashboard, bool showTrainers) {
    _pages = [];
    _titles = [];

    // 1. Home
    _pages.add(const HomePage());
    _titles.add('Home');

    // 2. Trainers (Controlled by Riverpod)
    if (showTrainers) {
      _pages.add(TrainersPage());
      _titles.add('Trainers');
    }

    // 3. Dashboard (Controlled by Riverpod)
    if (showDashboard) {
      _pages.add(WorkoutPage());
      _titles.add('Dashboard');
    }

    // 4. Standard Pages
    _pages.add(PlansPage());
    _titles.add('Plans');

    _pages.add(SupplementsPage());
    _titles.add('Shop');

    _pages.add(ContactPage());
    _titles.add('Contact Us');

    _pages.add(AboutUsPage());
    _titles.add('About Us');

    _pages.add(NotificationPage());
    _titles.add('Notification');
  }

  void _onSelectPage(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Home': return Icons.home;
      case 'Trainers': return Icons.people;
      case 'Dashboard': return Icons.dashboard;
      case 'Plans': return Icons.fitness_center;
      case 'Shop': return Icons.shopping_bag;
      case 'Contact Us': return Icons.contact_mail;
      case 'About Us': return Icons.info;
      case 'Notification': return Icons.notifications;
      default: return Icons.circle;
    }
  }
}

/* ============================= HOME PAGE ============================= */

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=700&auto=format&fit=crop&q=60'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.9),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                'NO MORE EXCUSES |',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6FF3F),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'DO IT NOW',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Achieve your fitness goals with our expert trainers!',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // --- UPDATED NAVIGATION ---
                        // Removed 'toggleTheme' argument
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(), 
                          ),
                        );
                      },
                      child: const Text('SIGN IN'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                         // --- UPDATED NAVIGATION ---
                        // Removed 'toggleTheme' argument
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6FF3F),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('SIGN UP'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

/* ============================= DRAWER ITEM ============================= */

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.red : Theme.of(context).iconTheme.color;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}