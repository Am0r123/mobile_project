import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrainerPage extends StatefulWidget {
  const TrainerPage({super.key});

  @override
  _TrainerPageState createState() => _TrainerPageState();
}

class _TrainerPageState extends State<TrainerPage> {
  List<Map<String, dynamic>> _myStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  // ====================================================
  // LOGIC: FETCH ONLY "USERS"
  // ====================================================
  Future<void> _fetchStudents() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('users')
          .select()
          .eq('role', 'user')
          .order('name', ascending: true);

      if (mounted) {
        setState(() {
          _myStudents = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("My Users"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _myStudents.isEmpty
              ? const Center(child: Text("No Users found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _myStudents.length,
                  itemBuilder: (context, index) {
                    final student = _myStudents[index];
                    
                    // Grab the plan, default to 'None' if empty
                    final String plan = student['plan'] ?? 'None';

                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.person),
                        ),
                        title: Text(student['name'] ?? 'Unknown'),
                        subtitle: Text(student['email'] ?? 'No Email'),
                        
                        // --- NEW: DISPLAY PLAN HERE ---
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.5))
                          ),
                          child: Text(
                            plan.toUpperCase(), // e.g. "GOLD" or "BASIC"
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}