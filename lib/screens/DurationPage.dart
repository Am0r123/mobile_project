import 'package:flutter/material.dart';
import 'PAY.dart';

class DurationPage extends StatelessWidget {
  final String planName;

  const DurationPage({super.key, required this.planName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(planName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Our Duration',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a plan that fits your fitness journey',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  DurationCard(
                    duration: '3 Months',
                    price: '\$30 / Month',
                    planName: planName,
                  ),
                  DurationCard(
                    duration: '6 Months',
                    price: '\$50 / Month',
                    planName: planName,
                  ),
                  DurationCard(
                    duration: '12 Months',
                    price: '\$80 / Month',
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
  final String price;
  final String planName;

  const DurationCard({
    super.key,
    required this.duration,
    required this.price,
    required this.planName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD6FF3F),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            duration,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            price,
            style: const TextStyle(
              color: Color(0xFFD6FF3F),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6FF3F),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}