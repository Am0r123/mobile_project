import 'package:flutter/material.dart';
import 'package:mobile_project/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notfication.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const LoginPage({super.key, required this.toggleTheme});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (response.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainLayout(toggleTheme: (_) => widget.toggleTheme()),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
              Text(
                "SIGN IN",
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                  MaterialPageRoute(
                    builder: (_) =>
                        SignUpPage(toggleTheme: widget.toggleTheme),
                  ),
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
  const SignUpPage({super.key, required this.toggleTheme});

  final VoidCallback toggleTheme;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signUp() async {
    setState(() => isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please login.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
                  onPressed: isLoading ? null : signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SIGN UP",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
