import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AboutUsPage(),
  ));
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      
      // --- MENU DRAWER ---
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Center(child: Text('FGYM Menu', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
            ),
            ListTile(leading: Icon(Icons.home, color: Colors.white), title: Text('Home', style: TextStyle(color: Colors.white))),
            ListTile(leading: Icon(Icons.info, color: Colors.white), title: Text('About', style: TextStyle(color: Colors.white))),
          ],
        ),
      ),

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), 
        centerTitle: true,
        title: const Text("FGYM", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        actions: [
          IconButton(icon: const Icon(Icons.person, color: Colors.white), onPressed: () {}),
        ],
      ),

      // --- BODY ---
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1. HERO IMAGE WITH FADE GRADIENT
            Stack(
              children: [
                // The Image
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=2070&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // The Fade Effect (Gradient from transparent to black)
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black,
                      ],
                      stops: const [0.6, 0.8, 1.0], 
                    ),
                  ),
                ),
              ],
            ),

            // 2. CONTENT SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Headline
                  const Text(
                    "IMPROVING LIVES",
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                  ),
                  const Text(
                    "THROUGH FITNESS",
                    style: TextStyle(color: Colors.red, fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                  ),
                  
                  const SizedBox(height: 24),

                  // Description Text
                  Text(
                    "We believe fitness is not just about the body, but the mind. Our goal is to provide an intuitive tracking experience that keeps you motivated.",
                    style: TextStyle(color: Colors.grey[400], fontSize: 16, height: 1.5),
                  ),
                  
                  const SizedBox(height: 16),

                  Text(
                    "Join us to log exercises, track real-time progress, and crush your goals with a community that cares.",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.5),
                  ),

                  const SizedBox(height: 40),

                  // 3. FOUNDER SECTION (Minimalist)
                  Container(
                    padding: const EdgeInsets.only(left: 16),
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.red, width: 3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Mohsen Samer", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "CEO & FOUNDER",
                          style: TextStyle(color: Colors.grey[600], fontSize: 12, letterSpacing: 2),
                        ),
                        const SizedBox(height: 12),
                         Text(
                          '"Our purpose is to give everyone the opportunity to live a fit and healthy life."',
                          style: TextStyle(color: Colors.grey[300], fontStyle: FontStyle.italic, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Bottom padding for scrolling
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}