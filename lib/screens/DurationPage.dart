import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/plans_provider.dart';
import 'PAY.dart'; // ✅ Restored the import for your Payment Page

class DurationPage extends ConsumerWidget {
  final String planName;

  const DurationPage({super.key, required this.planName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Theme Logic (From Old Code)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    // 2. Dynamic Data Logic (From New Code)
    final plans = ref.watch(plansProvider);
    final plan = plans.firstWhere(
      (p) => p.title == planName,
      orElse: () => Plan(title: 'Unknown', features: [], price: 0),
    );

    return Scaffold(
      // 3. Visuals (From Old Code)
      appBar: AppBar(
        title: Text(planName, style: TextStyle(color: textColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Duration',
              style: TextStyle(
                color: textColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a plan that fits your fitness journey',
              style: TextStyle(color: subTextColor),
            ),
            const SizedBox(height: 24),
            
            // 4. Dynamic List Generation
            Expanded(
              child: ListView(
                children: [
                  DurationCard(
                    duration: '1 Month',
                    // Calculate price dynamically
                    price: '\$${plan.price.toStringAsFixed(0)}', 
                    displayPrice: '\$${plan.price.toStringAsFixed(0)} / Month',
                    planName: planName,
                  ),
                  DurationCard(
                    duration: '3 Months',
                    price: '\$${(plan.price * 3).toStringAsFixed(0)}',
                    displayPrice: '\$${(plan.price * 3).toStringAsFixed(0)} / 3 Months',
                    planName: planName,
                  ),
                  DurationCard(
                    duration: '12 Months',
                    price: '\$${(plan.price * 12).toStringAsFixed(0)}',
                    displayPrice: '\$${(plan.price * 12).toStringAsFixed(0)} / Year',
                    planName: planName,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DurationCard extends StatelessWidget {
  final String duration;
  final String price; // The raw value (e.g. "$30") to pass to payment
  final String displayPrice; // The pretty value (e.g. "$30 / Month") to show on card
  final String planName;

  const DurationCard({
    super.key,
    required this.duration,
    required this.price,
    required this.displayPrice,
    required this.planName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final shadowColor = isDark ? Colors.transparent : Colors.black12;
    final borderColor = isDark ? Colors.white10 : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            duration,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayPrice,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(
                      planName: planName,
                      duration: duration,
                    ),
                  ),
                );
              },
              child: const Text(
                'Join Now',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}