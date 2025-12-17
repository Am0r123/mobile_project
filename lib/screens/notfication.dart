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
        primaryColor: Color(0xFF34495E),
        appBarTheme: AppBarTheme(
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

  static final List<Widget> _widgetOptions = <Widget>[
    NotificationScreen(),

    Center(
      child: Text(
        'Your Steps Today',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ),

    Center(
      child: Text(
        'New',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: _widgetOptions[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF34495E)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Notfications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: Icon(Icons.home),
              title: const Text('New Day Workouts'),
              selected: _selectedIndex == 0,
              selectedColor: Colors.red,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.notifications),
              title: const Text('Your Steps Today'),
              selected: _selectedIndex == 1,
              selectedColor: Colors.red,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.settings),
              title: const Text('New Notifications'),
              selected: _selectedIndex == 2,
              selectedColor: Colors.red,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Notification Details",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 40),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "New day Workouts",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),

                Text(
                  "Todays Workouts",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 5),

                InkWell(
                  onTap: () {
                    print("Link clicked");
                  },
                  child: Text(
                    "click here",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 10),

                Text(
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
