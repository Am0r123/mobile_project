import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_project/main.dart';
import 'package:mobile_project/screens/admin.dart'; // Admin Dashboard
import 'package:mobile_project/screens/trainer.dart';
import 'package:mobile_project/screens/trainer.dart'; // <--- MAKE SURE TO IMPORT YOUR TRAINER PAGE
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Authenticate with Supabase Auth
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // 2. If Auth Successful, Check Role
      if (response.user != null) {
        
        // Fetch the user's role from the public 'users' table
        // We use .maybeSingle() to avoid crashing if the user record is missing
        final data = await Supabase.instance.client
            .from('users')
            .select('role')
            .eq('id', response.user!.id)
            .maybeSingle();

        // Default to 'user' if no role is found
        final role = data != null ? data['role'] as String : 'user';

        if (!mounted) return;

        // 3. Navigate based on Role
        if (role == 'admin') {
          // --- Navigate to ADMIN ---
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardHome()),
          );
        } else if (role == 'trainer') {
          // --- Navigate to TRAINER ---
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TrainerPage()),
          );
        } else {
          // --- Navigate to USER (Main App) ---
          // Run your provider refresh logic for normal users
          await ref.read(subscriptionProvider.notifier).refresh();

          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainLayout()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String message = 'Login failed';
        if (e is AuthApiException) {
          message = e.message;
        } else {
          message = e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF34495E),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "SIGN IN",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              _buildInput("EMAIL", emailController),
              const SizedBox(height: 20),
              _buildInput("PASSWORD", passwordController, isPassword: true),
              const SizedBox(height: 40),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "LOGIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                ),
                child: const Text(
                  "Create an account",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController(); // Added Name Controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signUp() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;

    setState(() => isLoading = true);
    try {
      // 1. Create Auth User (Secure Login)
      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2. Insert into Public Database (So we know their role)
      if (response.user != null) {
        await Supabase.instance.client.from('users').insert({
          'id': response.user!.id,  // Links Auth to DB
          'name': nameController.text.trim().isEmpty ? 'New User' : nameController.text.trim(),
          'email': emailController.text.trim(),
          'role': 'user', // <--- Public Signups are ALWAYSr 'user'
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF34495E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "SIGN UP",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 40),
              // ADDED NAME INPUT
              _buildInput("FULL NAME", nameController),
              const SizedBox(height: 20),
              _buildInput("EMAIL", emailController),
              const SizedBox(height: 20),
              _buildInput("PASSWORD", passwordController, isPassword: true),
              const SizedBox(height: 40),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SIGN UP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildInput(
  String label,
  TextEditingController controller, {
  bool isPassword = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 8),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF5D768B),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    ],
  );
}