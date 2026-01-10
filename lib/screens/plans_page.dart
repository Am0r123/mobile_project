import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'DurationPage.dart'; // <--- Correct import matching your file name
import '../providers/plans_provider.dart';

class PlansPage extends ConsumerWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the real data from provider
    final plans = ref.watch(plansProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final appBarColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'Our Plans',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: plans.isEmpty 
          ? const Center(child: CircularProgressIndicator()) // Show loader if empty
          : Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: plans.map((plan) {
            return PlanCard(
              title: plan.title,
              features: plan.features,
              price: plan.price,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class PlanCard extends ConsumerWidget {
  final String title;
  final List<String> features;
  final double price;

  const PlanCard({
    super.key,
    required this.title,
    required this.features,
    required this.price,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[700];
    final borderColor = isDark ? Colors.white10 : Colors.grey[300]!;

    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 20, bottom: 20, top: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '\$${price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DurationPage(planName: title)),
                );
              },
              child: const Text('Apply Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}