import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/plans_provider.dart';

class DurationPage extends ConsumerWidget {
  final String planName;
  const DurationPage({super.key, required this.planName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(plansProvider);
    // Find the plan safely
    final plan = plans.firstWhere(
      (p) => p.title == planName, 
      orElse: () => Plan(title: 'Unknown', features: [], price: 0)
    );

    return Scaffold(
      appBar: AppBar(title: Text(planName), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Choose Duration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            DurationCard(
              duration: '1 Month', 
              price: '\$${plan.price.toStringAsFixed(0)}', 
              planName: planName
            ),
            DurationCard(
              duration: '3 Months', 
              price: '\$${(plan.price * 3).toStringAsFixed(0)}', 
              planName: planName
            ),
            DurationCard(
              duration: '12 Months', 
              price: '\$${(plan.price * 12).toStringAsFixed(0)}', 
              planName: planName
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

  const DurationCard({super.key, required this.duration, required this.price, required this.planName});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(duration, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(price, style: const TextStyle(color: Colors.red, fontSize: 18)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Save to Supabase 'subscriptions' table
                  await Supabase.instance.client.from('subscriptions').insert({
                    'plan_name': planName,
                    'duration': duration,
                    'price': price,
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Subscription Saved!"), backgroundColor: Colors.green),
                    );
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text("Join Now"),
            )
          ],
        ),
      ),
    );
  }
}