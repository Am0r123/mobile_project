import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PaymentPage(),
  ));
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  int selectedMonth = 1;
  int selectedYear = 2026;

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
        title: const Text("FGYM", style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 1. Background
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.6))),

          // 2. Form Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("PAYMENT", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                      const Divider(color: Colors.indigo, thickness: 3, endIndent: 200),
                      const SizedBox(height: 20),

                      // --- Name Field ---
                      const CustomLabel(text: "Name on Card"),
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(hintText: "Enter Name", border: OutlineInputBorder()),
                        validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
                      ),
                      const SizedBox(height: 15),

                      // --- Card Number Field ---
                      const CustomLabel(text: "Credit Card Number"),
                      TextFormField(
                        controller: numberController,
                        keyboardType: TextInputType.number,
                        maxLength: 19,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardNumberFormatter()],
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: "1111-2222-3333-4444",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                          counterText: "",
                        ),
                        validator: (value) {
                          if (value == null || value.length != 19) return "Invalid card number";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // --- Date Selectors (Using Extracted Widget) ---
                      Row(
                        children: [
                          Expanded(
                            child: CounterSelector(
                              title: "Exp Month",
                              value: selectedMonth,
                              min: 1,
                              max: 12,
                              onChanged: (val) => setState(() => selectedMonth = val),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: CounterSelector(
                              title: "Exp Year",
                              value: selectedYear,
                              min: 2026,
                              max: 2040,
                              onChanged: (val) => setState(() => selectedYear = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // --- CVV Field ---
                      const CustomLabel(text: "CVV"),
                      TextFormField(
                        controller: cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 3,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(hintText: "123", border: OutlineInputBorder(), counterText: ""),
                        validator: (val) => (val == null || val.length != 3) ? "3 digits required" : null,
                      ),
                      const SizedBox(height: 20),

                      // --- Pay Button ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // 1. Show Processing Message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Processing Payment..."),
                                  duration: Duration(seconds: 2), 
                                  backgroundColor: Colors.orange,
                                ),
                              );

                              // 2. Wait 2 seconds, then show Completed Message
                              Future.delayed(const Duration(seconds: 2), () {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Payment Completed Successfully!"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              });
                            }
                          },
                          child: const Text("Pay Now", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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

// ==========================================
//           EXTRACTED WIDGETS
// ==========================================

// 1. Simple Label Widget
class CustomLabel extends StatelessWidget {
  final String text;
  const CustomLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }
}

// 2. Counter Selector Widget
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
        CustomLabel(text: title), // Reuse our CustomLabel
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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

// 3. Card Formatter
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
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
