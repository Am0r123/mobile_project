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
        title: const Text("FGYM", style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const Drawer(child: Center(child: Text("Menu"))),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.6))),

          // Form
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
                      const Text("PAYMENT", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const Divider(color: Colors.indigo, thickness: 3, endIndent: 200),
                      const SizedBox(height: 20),

                      // Name
                      _buildLabel("Name on Card"),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(hintText: "Enter Name", border: OutlineInputBorder()),
                        validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
                      ),
                      const SizedBox(height: 15),

                      // Card Number
                      _buildLabel("Credit Card Number"),
                      TextFormField(
                        controller: numberController,
                        keyboardType: TextInputType.number,
                        maxLength: 19,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CardNumberFormatter(),
                        ],
                        // HERE IS THE CHANGE:
                        decoration: const InputDecoration(
                          hintText: "1111-2222-3333-4444", // Updated Placeholder
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

                      // Date Selectors
                      Row(
                        children: [
                          Expanded(child: _buildCounter("Exp Month", selectedMonth, 1, 12, (val) => setState(() => selectedMonth = val))),
                          const SizedBox(width: 15),
                          Expanded(child: _buildCounter("Exp Year", selectedYear, 2026, 2040, (val) => setState(() => selectedYear = val))),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // CVV
                      _buildLabel("CVV"),
                      TextFormField(
                        controller: cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 3,
                        decoration: const InputDecoration(hintText: "123", border: OutlineInputBorder(), counterText: ""),
                        validator: (val) => (val == null || val.length != 3) ? "3 digits required" : null,
                      ),
                      const SizedBox(height: 20),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Processing Payment...")));
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

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));

  Widget _buildCounter(String title, int value, int min, int max, Function(int) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildLabel(title),
      Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: const Icon(Icons.remove), onPressed: () => value > min ? onChanged(value - 1) : null),
          Text(value.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.add), onPressed: () => value < max ? onChanged(value + 1) : null),
        ]),
      ),
    ]);
  }
}

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
    return TextEditingValue(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.length));
  }
}