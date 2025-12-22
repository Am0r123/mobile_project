import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // REQUIRED IMPORT
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../providers.dart'; // Import providers

class PaymentPage extends ConsumerStatefulWidget {
  final String planName;
  final String duration;

  const PaymentPage({
    super.key,
    required this.planName,
    required this.duration,
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  int selectedMonth = 1;
  int selectedYear = 2026;
  bool isSaving = false;

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      // 1. Simulate Delay
      await Future.delayed(const Duration(seconds: 2));

      // 2. Save Data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_plan', widget.planName);
      await prefs.setString('plan_duration', widget.duration);
      await prefs.setBool('is_subscribed', true);

      // 3. TRIGGER RIVERPOD REFRESH
      // This tells MainLayout to re-check permissions immediately
      await ref.read(subscriptionProvider.notifier).refresh();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Successful! Plan Activated."),
          backgroundColor: Colors.green,
        ),
      );

      // 4. Navigate back to MainApp
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainApp()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("FGYM",
            style: TextStyle(
                color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.6))),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("PAYMENT",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const Divider(
                          color: Colors.indigo, thickness: 3, endIndent: 200),
                      const SizedBox(height: 20),

                      // --- Summary ---
                      Text(
                        "Buying: ${widget.planName} Plan (${widget.duration})",
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),

                      const CustomLabel(text: "Name on Card"),
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                            hintText: "Enter Name",
                            border: OutlineInputBorder()),
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Required"
                            : null,
                      ),
                      const SizedBox(height: 15),

                      const CustomLabel(text: "Credit Card Number"),
                      TextFormField(
                        controller: numberController,
                        keyboardType: TextInputType.number,
                        maxLength: 19,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CardNumberFormatter()
                        ],
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: "1111-2222-3333-4444",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                          counterText: "",
                        ),
                        validator: (value) {
                          if (value == null || value.length != 19)
                            return "Invalid card number";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: CounterSelector(
                              title: "Exp Month",
                              value: selectedMonth,
                              min: 1,
                              max: 12,
                              onChanged: (val) =>
                                  setState(() => selectedMonth = val),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: CounterSelector(
                              title: "Exp Year",
                              value: selectedYear,
                              min: 2026,
                              max: 2040,
                              onChanged: (val) =>
                                  setState(() => selectedYear = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      const CustomLabel(text: "CVV"),
                      TextFormField(
                        controller: cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 3,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                            hintText: "123",
                            border: OutlineInputBorder(),
                            counterText: ""),
                        validator: (val) => (val == null || val.length != 3)
                            ? "3 digits required"
                            : null,
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB71C1C)),
                          onPressed: isSaving ? null : _processPayment,
                          child: isSaving
                              ? const SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                )
                              : const Text("Pay Now",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... Keep CustomLabel, CounterSelector, and CardNumberFormatter the same ...
class CustomLabel extends StatelessWidget {
  final String text;
  const CustomLabel({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }
}

class CounterSelector extends StatelessWidget {
  final String title;
  final int value;
  final int min;
  final int max;
  final Function(int) onChanged;

  const CounterSelector({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabel(text: title),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.black),
                onPressed: () => value > min ? onChanged(value - 1) : null,
              ),
              Text(
                value.toString().padLeft(2, '0'),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () => value < max ? onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 16) text = text.substring(0, 16);

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != text.length) buffer.write("-");
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}