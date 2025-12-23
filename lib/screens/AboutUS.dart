import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AboutUsPage extends ConsumerWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final gradientEndColor = isDark ? Colors.black : Colors.white; 

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO IMAGE WITH FADE GRADIENT
            Stack(
              children: [
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
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        gradientEndColor.withOpacity(0.0),
                        gradientEndColor.withOpacity(0.6),
                        gradientEndColor,
                      ],
                      stops: const [0.5, 0.8, 1.0], 
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
                  Text(
                    "IMPROVING LIVES",
                    style: TextStyle(color: textColor, fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                  ),
                  const Text(
                    "THROUGH FITNESS",
                    style: TextStyle(color: Colors.red, fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                  ),
                  
                  const SizedBox(height: 24),

                  Text(
                    "We believe fitness is not just about the body, but the mind. Our goal is to provide an intuitive tracking experience that keeps you motivated.",
                    style: TextStyle(color: subTextColor, fontSize: 16, height: 1.5),
                  ),
                  
                  const SizedBox(height: 16),

                  Text(
                    "Join us to log exercises, track real-time progress, and crush your goals with a community that cares.",
                    style: TextStyle(color: subTextColor.withOpacity(0.7), fontSize: 14, height: 1.5),
                  ),

                  const SizedBox(height: 40),

                  // 3. FOUNDER SECTION
                  Container(
                    padding: const EdgeInsets.only(left: 16),
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.red, width: 3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mohsen Samer", 
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "CEO & FOUNDER",
                          style: TextStyle(color: subTextColor, fontSize: 12, letterSpacing: 2),
                        ),
                        const SizedBox(height: 12),
                         Text(
                          '"Our purpose is to give everyone the opportunity to live a fit and healthy life."',
                          style: TextStyle(color: subTextColor, fontStyle: FontStyle.italic, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

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