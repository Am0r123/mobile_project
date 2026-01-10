import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupplementsPage extends ConsumerStatefulWidget {
  const SupplementsPage({super.key});

  @override
  ConsumerState<SupplementsPage> createState() => _SupplementsPageState();
}

class _SupplementsPageState extends ConsumerState<SupplementsPage> {
  late YoutubePlayerController _videoController;
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _videoController = YoutubePlayerController(
      initialVideoId: 'bWOX3hN_rLw',
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false, enableCaption: false),
    );
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await Supabase.instance.client
          .from('supplements')
          .select()
          .order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          products = List<Map<String, dynamic>>.from(response);
          for (var p in products) { p['isFavorite'] = false; }
          isLoading = false;
        });
        loadFavorites();
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
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

  // Toggle favorite on/off
  void toggleFavorite(int index) async {
    setState(() {
      products[index]['isFavorite'] = !products[index]['isFavorite'];
    });
    _saveToStorage();
  }

  // Save list to phone storage
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

  // Handle removing from the Favorites Page
  void handleRemoveByTitle(String title) {
    final index = products.indexWhere((item) => item['title'] == title);
    if (index != -1) {
      toggleFavorite(index); // This will turn it off
    }
  }

  void moveLeft() {
    _scrollController.animateTo(_scrollController.offset - 200, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }
  void moveRight() {
    _scrollController.animateTo(_scrollController.offset + 200, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  void dispose() {
    _videoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER with Favorites Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Supplements Store', style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold)),
                    
                    // FAVORITES BUTTON
                    Container(
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          // Filter only favorite items to pass to the next page
                          final favs = products.where((p) => p['isFavorite'] == true).toList();
                          
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritesPage(
                            favoriteItems: favs,
                            onRemove: handleRemoveByTitle, // Pass the remove function
                          ))).then((_) {
                             // Refresh when coming back
                             setState(() {});
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),

              // YOUTUBE VIDEO
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: YoutubePlayer(controller: _videoController, showVideoProgressIndicator: true),
                ),
              ),

              const SizedBox(height: 30),

              // PRODUCTS LIST
              SizedBox(
                height: 320,
                child: isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : products.isEmpty 
                    ? const Center(child: Text("Shop is empty"))
                    : Row(
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
                                  imagePath: products[index]['image_url'],
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
    );
  }
}

// PRODUCT CARD WIDGET
class ProductCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isFavorite;
  final VoidCallback onHeartTap;

  const ProductCard({super.key, required this.title, required this.imagePath, required this.isFavorite, required this.onHeartTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 5))],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imagePath, height: 120, width: 120, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  loadingBuilder: (c, child, progress) {
                    if (progress == null) return child;
                    return Container(height: 120, width: 120, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator()));
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 5, right: 5,
            child: IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey),
              onPressed: onHeartTap,
            ),
          )
        ],
      ),
    );
  }
}

// NEW: FAVORITES PAGE
class FavoritesPage extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteItems;
  final Function(String) onRemove;

  const FavoritesPage({super.key, required this.favoriteItems, required this.onRemove});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: widget.favoriteItems.isEmpty 
          ? const Center(child: Text("No favorites yet!", style: TextStyle(fontSize: 20)))
          : ListView.builder(
              itemCount: widget.favoriteItems.length,
              itemBuilder: (context, index) {
                final item = widget.favoriteItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['image_url'], 
                        width: 60, height: 60, fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported),
                      ),
                    ),
                    title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // 1. Remove from Parent State
                        widget.onRemove(item['title']);
                        // 2. Remove from Local List so UI updates instantly
                        setState(() {
                          widget.favoriteItems.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}