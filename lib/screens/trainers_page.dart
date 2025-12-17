import 'dart:async';
import 'package:flutter/material.dart';

class TrainersPage extends StatefulWidget {
  const TrainersPage({super.key});

  @override
  State<TrainersPage> createState() => _TrainersPageState();
}

class _TrainersPageState extends State<TrainersPage> {
  late final PageController _pageController;
  late final Timer _autoSlideTimer;
  int _currentPage = 0;

  final List<Map<String, String>> trainers = [
    {
      'image': 'assets/images/female_trainer.png',
      'title': 'Female Trainers',
      'subtitle': 'Strength, Confidence, Community',
    },
    {
      'image': 'assets/images/fitness_trainer.jpg',
      'title': 'Fitness Trainers',
      'subtitle': 'Unlock Your Full Potential',
    },
    {
      'image': 'assets/images/sport_trainer.jpg',
      'title': 'Sport Trainers',
      'subtitle': 'Master Your Game',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoSlide();
    });
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageController.hasClients) return;

      _currentPage = (_currentPage + 1) % trainers.length;

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/trainers_bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 260,
                  color: Colors.black.withOpacity(0.6),
                ),
                Positioned.fill(
                  child: Center(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'Our ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'Trainers',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'What We Provide',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'At our gym, we offer specialized trainers for every category, '
                    'including basketball, strength training, and general fitness. '
                    'Whether you prefer a male or female trainer, our diverse team '
                    'is dedicated to helping you achieve your personal goals.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Join a community that celebrates fitness, health, and well-being. '
                    'Our gym fosters a positive atmosphere where members support each other.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                ],
              ),
            ),

            Divider(
              color: isDark ? Colors.white24 : Colors.black26,
              thickness: 1,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trainers',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: trainers.length,
                      itemBuilder: (context, index) {
                        final trainer = trainers[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TrainerCard(
                            image: trainer['image']!,
                            title: trainer['title']!,
                            subtitle: trainer['subtitle']!,
                            isDark: isDark,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: isDark ? Colors.black : Colors.grey.shade200,
              child: Text(
                '© All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrainerCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final bool isDark;

  const TrainerCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final borderColor = isDark ? Colors.white24 : Colors.grey.shade300;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(14),
            ),
            child: Image.asset(
              image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
