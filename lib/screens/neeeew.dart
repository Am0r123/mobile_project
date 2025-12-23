import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

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

  final List<Map<String, dynamic>> products = [
    { "title": "Whey Protein", "image": "https://placehold.co/200x200/png?text=Whey+Protein", "isFavorite": false },
    { "title": "Creatine", "image": "https://placehold.co/200x200/png?text=Creatine", "isFavorite": false },
    { "title": "Omega-3", "image": "https://placehold.co/200x200/png?text=Omega-3", "isFavorite": false },
    { "title": "BCAA", "image": "https://placehold.co/200x200/png?text=BCAA", "isFavorite": false },
    { "title": "Pre-Workout", "image": "https://placehold.co/200x200/png?text=Pre-Workout", "isFavorite": false },
    { "title": "Multivitamin", "image": "https://placehold.co/200x200/png?text=Multivitamin", "isFavorite": false },
    { "title": "L-Carnitine", "image": "https://placehold.co/200x200/png?text=L-Carnitine", "isFavorite": false },
  ];

  @override
  void initState() {
    super.initState();
    _videoController = YoutubePlayerController(
      initialVideoId: 'bWOX3hN_rLw',
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false, enableCaption: false),
    );
    loadFavorites();
  }

  void loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedNames = prefs.getStringList('my_favs') ?? [];

    setState(() {
      for (var item in products) {
        if (savedNames.contains(item['title'])) {
          item['isFavorite'] = true;
        }
      }
    });
  }

  // --- SAVE/REMOVE LOGIC ---
  void toggleFavorite(int index) async {
    setState(() {
      products[index]['isFavorite'] = !products[index]['isFavorite'];
    });
    _saveToStorage();
  }

  void _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> namesToSave = [];
    for (var item in products) {
      if (item['isFavorite'] == true) {
        namesToSave.add(item['title']);
      }
    }
    await prefs.setStringList('my_favs', namesToSave);
  }

  // --- Handle removal from the Favorites Page ---
  void handleRemoveByTitle(String title) {
    final index = products.indexWhere((item) => item['title'] == title);
    if (index != -1) {
      toggleFavorite(index);
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void moveLeft() {
    _scrollController.animateTo(_scrollController.offset - 200, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }
  void moveRight() {
    _scrollController.animateTo(_scrollController.offset + 200, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("FGYM", style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              final favs = products.where((p) => p['isFavorite'] == true).toList();
              
              Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritesPage(
                favoriteItems: favs,
                onRemove: handleRemoveByTitle, 
              ))).then((_) {
                 setState(() {});
              });
            },
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Center(child: Text('FGYM Menu', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
            ),
            ListTile(leading: const Icon(Icons.home, color: Colors.white), title: const Text('Home', style: TextStyle(color: Colors.white)), onTap: () {}),
            ListTile(leading: const Icon(Icons.shopping_cart, color: Colors.white), title: const Text('Shop', style: TextStyle(color: Colors.white)), onTap: () {}),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.7))),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text('Supplements Store', style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

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

                  SizedBox(
                    height: 320, 
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
                                title: products[index]['title'],
                                imageUrl: products[index]['image'],
                                isFavorite: products[index]['isFavorite'],
                                onHeartTap: () => toggleFavorite(index),
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

// Product Card
class ProductCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback onHeartTap;

  const ProductCard({
    super.key, 
    required this.title, 
    required this.imageUrl,
    required this.isFavorite,
    required this.onHeartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Image.network(imageUrl, height: 100, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50, color: Colors.grey)),
              const SizedBox(height: 10),
              const Text("Premium Quality", style: TextStyle(color: Colors.grey)),
            ],
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: onHeartTap,
            ),
          )
        ],
      ),
    );
  }
}

// --- UPDATED FAVORITES PAGE ---
class FavoritesPage extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteItems;
  final Function(String) onRemove;

  const FavoritesPage({
    super.key, 
    required this.favoriteItems,
    required this.onRemove,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("My Favorites", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: widget.favoriteItems.isEmpty 
          ? const Center(child: Text("No favorites yet!", style: TextStyle(color: Colors.white, fontSize: 20)))
          : ListView.builder(
              itemCount: widget.favoriteItems.length,
              itemBuilder: (context, index) {
                final item = widget.favoriteItems[index];
                return ListTile(
                  leading: Image.network(item['image'], width: 50),
                  title: Text(item['title'], style: const TextStyle(color: Colors.white, fontSize: 18)),
                  
                  // --- CHANGED HERE: Red Heart Icon ---
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red), // Shows Red Heart
                    onPressed: () {
                      // 1. Update Parent Logic (un-favorite)
                      widget.onRemove(item['title']);
                      
                      // 2. Remove from THIS list immediately
                      setState(() {
                        widget.favoriteItems.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}