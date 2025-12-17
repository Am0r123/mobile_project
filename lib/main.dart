import 'package:flutter/material.dart';
import 'package:mobile_project/screens/AboutUS.dart';
import 'package:mobile_project/screens/notfication.dart';
import 'package:mobile_project/screens/shop.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/setup_page.dart';
import 'screens/trainers_page.dart';
import 'screens/workout_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_project/screens/Login.dart';
import 'screens/plans_page.dart';
import 'screens/ContactPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: 'https://cueajqxtidewvduxjlvi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN1ZWFqcXh0aWRld3ZkdXhqbHZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3MTE0MjMsImV4cCI6MjA4MTI4NzQyM30._454zHSeliyJPzb43dUySzXlPRjWBsVvo6qkdhJDv8I',
  );
  runApp(const MainApp());
}

/* ============================= APP ============================= */

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void toggleTheme(bool isDark) async {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  Future<bool> _isSetupDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('setupDone') ?? false;
  }

  @override
  Widget build(BuildContext context) {
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
      themeMode: _themeMode,
      home: FutureBuilder<bool>(
        future: _isSetupDone(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!(snapshot.data ?? false)) {
            return const SetupPage();
          }

          return MainLayout(toggleTheme: toggleTheme);
        },
      ),
    );
  }
}

/* ============================= MAIN LAYOUT ============================= */

class MainLayout extends StatefulWidget {
  final Function(bool) toggleTheme;
  const MainLayout({super.key, required this.toggleTheme});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    TrainersPage(),
    WorkoutPage(),
    PlansPage(),
    SupplementsPage(),
    ContactPage(),
    AboutUsPage(),
    NotificationPage(),
  ];

  final List<String> _titles = [
    'Home',
    'Trainers',
    'Dashboard',
    'Plans',
    'Shop',
    'Contact Us',
    'About Us',
    'Notfication',
  ];

  void _onSelectPage(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(!isDark),
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

              _DrawerItem(
                icon: Icons.home,
                title: 'Home',
                isActive: _selectedIndex == 0,
                onTap: () => _onSelectPage(0),
              ),
              _DrawerItem(
                icon: Icons.people,
                title: 'Trainers',
                isActive: _selectedIndex == 1,
                onTap: () => _onSelectPage(1),
              ),
              _DrawerItem(
                icon: Icons.dashboard,
                title: 'Dashboard',
                isActive: _selectedIndex == 2,
                onTap: () => _onSelectPage(2),
              ),
              _DrawerItem(
                icon: Icons.fitness_center,
                title: 'Plans',
                isActive: _selectedIndex == 3,
                onTap: () => _onSelectPage(3),
              ),
              _DrawerItem(
                icon: Icons.shopping_bag,
                title: 'Shop',
                isActive: _selectedIndex == 4,
                onTap: () => _onSelectPage(4),
              ),
              _DrawerItem(
                icon: Icons.contact_mail,
                title: 'Contact Us',
                isActive: _selectedIndex == 5,
                onTap: () => _onSelectPage(5),
              ),
              _DrawerItem(
                icon: Icons.info,
                title: 'About Us',
                isActive: _selectedIndex == 6,
                onTap: () => _onSelectPage(6),
              ),
              _DrawerItem(
                icon: Icons.notifications,
                title: 'Notification',
                isActive: _selectedIndex == 7,
                onTap: () => _onSelectPage(7),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),

      body: _pages[_selectedIndex],
    );
  }
}

/* ============================= HOME PAGE ============================= */

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=700&auto=format&fit=crop&q=60',
              ),
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
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.9),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                      child: const Text('SIGN IN'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
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
