import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplementsPage extends ConsumerStatefulWidget {
  const SupplementsPage({super.key});

  @override
  ConsumerState<SupplementsPage> createState() => _SupplementsPageState();
}

class _SupplementsPageState extends ConsumerState<SupplementsPage> {
  late YoutubePlayerController _videoController;
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> products = [
    { "title": "Whey Protein", "image": "assets/images/Whey Protein.jpg", "isFavorite": false },
    { "title": "Creatine", "image": "assets/images/creatine.jpg", "isFavorite": false },
    { "title": "Omega-3", "image": "assets/images/Omega-3.jpg", "isFavorite": false },
    { "title": "BCAA", "image": "assets/images/BCAA.jpg", "isFavorite": false },
    { "title": "Pre-Workout", "image": "assets/images/Pre-Workout.jpg", "isFavorite": false },
    { "title": "Multivitamin", "image": "assets/images/Multivitamin.jpg", "isFavorite": false },
    { "title": "L-Carnitine", "image": "assets/images/L-Carnitine.jpg", "isFavorite": false },
  ];

  @override
  void initState() {
    super.initState();
    _videoController = YoutubePlayerController(
      initialVideoId: 'bWOX3hN_rLw',
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false, enableCaption: false),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop',
              fit: BoxFit.cover,
              errorBuilder: (c,e,s) => Container(color: Colors.black),
            ),
          ),
          
          Positioned.fill(
            child: Container(
              color: isDark 
                  ? Colors.black.withOpacity(0.8) 
                  : Colors.white.withOpacity(0.85),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Supplements Store', 
                          style: TextStyle(
                            color: Colors.red, 
                            fontSize: 28, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
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
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                         BoxShadow(
                           color: isDark ? Colors.black45 : Colors.grey.withOpacity(0.5), 
                           blurRadius: 10, offset: const Offset(0,5)
                         )
                      ]
                    ),
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
                                imagePath: products[index]['image'],
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

class ProductCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isFavorite;
  final VoidCallback onHeartTap;

  const ProductCard({
    super.key, 
    required this.title, 
    required this.imagePath,
    required this.isFavorite,
    required this.onHeartTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      width: 180,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 5)
          )
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent)
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                title, 
                style: TextStyle(
                  color: textColor, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath, 
                  height: 120, 
                  width: 120,
                  fit: BoxFit.cover, 
                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              const Text("Premium Quality", style: TextStyle(color: Colors.red)),
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

class FavoritesPage extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> favoriteItems;
  final Function(String) onRemove;

  const FavoritesPage({
    super.key, 
    required this.favoriteItems,
    required this.onRemove,
  });

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("My Favorites", style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: widget.favoriteItems.isEmpty 
          ? Center(child: Text("No favorites yet!", style: TextStyle(color: textColor, fontSize: 20)))
          : ListView.builder(
              itemCount: widget.favoriteItems.length,
              itemBuilder: (context, index) {
                final item = widget.favoriteItems[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        item['image'], 
                        width: 60, 
                        height: 60, 
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported),
                      ),
                    ),
                    title: Text(item['title'], style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        widget.onRemove(item['title']);
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