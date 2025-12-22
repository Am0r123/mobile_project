import 'package:flutter/material.dart';

void main() => runApp(const NotificationPage());

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const appTitle = 'Notifications';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF34495E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF34495E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // The screens to swap between
  static final List<Widget> _widgetOptions = <Widget>[
    NotificationScreen(), // Index 0
    const Center(
      child: Text(
        'Your Steps Today',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ), // Index 1
    const Center(
      child: Text(
        'New Notifications',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ), // Index 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: _widgetOptions[_selectedIndex],
      
      // Added BottomNavigationBar instead of Drawer
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk), // Changed icon to match "Steps"
            label: 'Steps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'New',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red, // Keeps your red selection style
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- Your existing NotificationScreen code remains unchanged below ---

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Notification Details",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "New day Workouts",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Todays Workouts",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 5),
                InkWell(
                  onTap: () {
                    print("Link clicked");
                  },
                  child: const Text(
                    "click here",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "12/14/2025, 4:39:30 PM",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}