import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final inputFillColor =
        isDark ? Colors.white.withOpacity(0.15) : Colors.grey.shade200;
    final hintColor = isDark ? Colors.white54 : Colors.grey.shade500;
    final inputTextColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1590487988256-9ed24133863e?w=700&auto=format&fit=crop&q=60',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.85),
                      ]
                    : [
                        Colors.white.withOpacity(0.6),
                        Colors.white,
                      ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Text(
                    'Get In Touch',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Have questions? Contact us and start your fitness journey today.',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _inputField(
                      'Full Name', inputFillColor, inputTextColor, hintColor),
                  const SizedBox(height: 16),

                  _inputField(
                      'Email', inputFillColor, inputTextColor, hintColor),
                  const SizedBox(height: 16),

                  _inputField('Message', inputFillColor, inputTextColor,
                      hintColor,
                      maxLines: 4),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'SEND MESSAGE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Divider(color: isDark ? Colors.white24 : Colors.black12),
                  const SizedBox(height: 20),

                  Text(
                    'FGYM\nEmail: info@fgym.com\nPhone: +20 123 456 789',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ================= MAP SECTION =================
                  Text(
                    'Our Location',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const SizedBox(
                    height: 250,
                    child: _CurrentLocationMap(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String hint, Color fillColor, Color textColor,
      Color hintColor,
      {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}

// ===================== MAP CODE =====================

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
