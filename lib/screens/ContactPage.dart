import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  // ===================== CONTROLLERS =====================
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _sending = false;

  // ===================== SEND TO SUPABASE =====================
  Future<void> _sendMessage() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      _showSnack('Please fill all fields');
      return;
    }

    setState(() => _sending = true);

    try {
      final supabase = Supabase.instance.client;

      await supabase.from('contact_messages').insert({
        'full_name': name,
        'email': email,
        'message': message,
      });

      _nameController.clear();
      _emailController.clear();
      _messageController.clear();

      _showSnack('Message sent successfully');
    } catch (e) {
      _showSnack('Error: $e');
    }

    setState(() => _sending = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Contact Us'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Text(
              'Get In Touch',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Have questions? Contact us and start your fitness journey today.',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),

            const SizedBox(height: 25),

            _inputField(
              controller: _nameController,
              hint: 'Full Name',
            ),
            const SizedBox(height: 16),

            _inputField(
              controller: _emailController,
              hint: 'Email',
            ),
            const SizedBox(height: 16),

            _inputField(
              controller: _messageController,
              hint: 'Message',
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _sending ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _sending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SEND MESSAGE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            const Text(
              'Our Location',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const SizedBox(
              height: 220,
              child: _CurrentLocationMap(),
            ),

            const SizedBox(height: 20),

            const Text(
              'FGYM\nEmail: info@fgym.com\nPhone: +20 123 456 789',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

// =================================================================
// ===================== CURRENT LOCATION MAP =======================
// =================================================================

class _CurrentLocationMap extends StatefulWidget {
  const _CurrentLocationMap();

  @override
  State<_CurrentLocationMap> createState() => _CurrentLocationMapState();
}

class _CurrentLocationMapState extends State<_CurrentLocationMap> {
  final Location _location = Location();
  StreamSubscription<LocationData>? _sub;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    if (!await _location.serviceEnabled()) {
      if (!await _location.requestService()) return;
    }

    if (await _location.requestPermission() != PermissionStatus.granted) return;

    _sub = _location.onLocationChanged.listen((loc) {
      if (loc.latitude == null || loc.longitude == null) return;

      setState(() {
        _currentLocation = LatLng(loc.latitude!, loc.longitude!);
      });

      _sub?.cancel(); // first valid fix only
    });

    // Emulator fallback (prevents infinite loading)
    Future.delayed(const Duration(seconds: 5), () {
      if (_currentLocation == null && mounted) {
        setState(() {
          _currentLocation = const LatLng(30.0444, 31.2357);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: _currentLocation!,
          initialZoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.flutter_application_5',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
