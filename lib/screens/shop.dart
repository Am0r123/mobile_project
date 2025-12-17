import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SupplementsPage(),
  ));
}

class SupplementsPage extends StatefulWidget {
  const SupplementsPage({super.key});

  @override
  State<SupplementsPage> createState() => _SupplementsPageState();
}

class _SupplementsPageState extends State<SupplementsPage> {
  late YoutubePlayerController _videoController;
  final ScrollController _scrollController = ScrollController();

  // Your products list
  final List<Map<String, String>> products = [
    { "title": "Whey Protein", "image": "https://placehold.co/200x200/png?text=Whey+Protein" },
    { "title": "Creatine", "image": "https://placehold.co/200x200/png?text=Creatine" },
    { "title": "Omega-3", "image": "https://placehold.co/200x200/png?text=Omega-3" },
    { "title": "BCAA", "image": "https://placehold.co/200x200/png?text=BCAA" },
    { "title": "Pre-Workout", "image": "https://placehold.co/200x200/png?text=Pre-Workout" },
    { "title": "Multivitamin", "image": "https://placehold.co/200x200/png?text=Multivitamin" },
    { "title": "L-Carnitine", "image": "https://placehold.co/200x200/png?text=L-Carnitine" },
  ];

  @override
  void initState() {
    super.initState();
    // Using a valid video ID as per Lecture 3 (Assets/Network) concepts
    _videoController = YoutubePlayerController(
      initialVideoId: 'gDRhZF6Ko7k',
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false, enableCaption: false),
    );
  }

  // Simple scroll functions
  void moveLeft() {
    _scrollController.animateTo(_scrollController.offset - 200, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }
  void moveRight() {
    _scrollController.animateTo(_scrollController.offset + 200, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. EXTEND BODY: Lets the background image show behind the AppBar (Lecture 2 Design)
      extendBodyBehindAppBar: true, 

      // 2. APP BAR: Replaces your complex Row.
      // It automatically handles the "Menu Icon" and centers the title.
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make it invisible to show background
        elevation: 0, // Remove shadow
        title: const Text("FGYM", style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        // The Menu icon appears automatically because we added a 'drawer' below!
        iconTheme: const IconThemeData(color: Colors.white, size: 30), 
      ),

      // 4. STACK: Layering widgets as per Lecture 4 (Slide 114)[cite: 822].
      body: Stack(
        children: [
          // Layer 1: Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          // Layer 2: Dark Overlay
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.7))),

          // Layer 3: Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // No manual header needed here anymore!
                  
                  const SizedBox(height: 10),
                  const Text('Supplements Store', style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Video Player
                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: YoutubePlayer(
                        controller: _videoController,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.red,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Products List with Arrows (Lecture 4: ListView & Row) [cite: 704, 827]
                  SizedBox(
                    height: 300,
                    child: Row(
                      children: [
                        IconButton(onPressed: moveLeft, icon: const Icon(Icons.arrow_back_ios, color: Colors.red)),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              return ProductCard(
                                title: products[index]['title']!,
                                imageUrl: products[index]['image']!,
                              );
                            },
                          ),
                        ),
                        IconButton(onPressed: moveRight, icon: const Icon(Icons.arrow_forward_ios, color: Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Product Card Widget (Stateless Widget as per Lecture 2) [cite: 562]
class ProductCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const ProductCard({super.key, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Image.network(imageUrl, height: 100, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50, color: Colors.grey)),
          const SizedBox(height: 10),
          const Text("Premium Quality", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}