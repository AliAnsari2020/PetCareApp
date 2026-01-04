import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

// 👇 Aapke project ke imports
import 'package:userpanel/auth/ForgotPasswordScreen.dart';
import 'package:userpanel/auth/signup.dart';
import 'package:userpanel/pet_owner/dashboard.dart';
import 'package:userpanel/shelter/ShelterDashboard.dart';
import 'package:userpanel/veterinarian/screens/vet_dashboard_screen.dart';
import 'package:userpanel/AdminDashboard/AdminDashboard.dart'; // 👈 Admin dashboard import

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> loginUser() async {
    setState(() => _isLoading = true);

    try {
      // 👇 Admin special case check
      if (emailController.text.trim() == "admin@gmail.com" &&
          passwordController.text.trim() == "admin123") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardPage()),
        );
        return; // Stop execution here
      }

      // 👇 Otherwise Firebase login
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .get();

      String role = userDoc["role"];

      if (role == "Pet Owner") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PetOwnerDashboard()),
        );
      } else if (role == "Veterinarian") {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VetDashboardScreen(vetId: uid)),
        );
      } else if (role == "Shelter Admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ShelterDashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Role not found. Contact admin.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: ${e.message}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Lottie Animation
              Lottie.asset("images/login.json", height: 200, repeat: true),

              const SizedBox(height: 10),

              const Text(
                "Welcome Back 👋",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Log in to your account to continue",
                style: TextStyle(color: Colors.grey[700], fontSize: 15),
              ),

              const SizedBox(height: 40),

              // 🔹 Input Fields
              _buildInputField(
                controller: emailController,
                label: "Email",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              _buildInputField(
                controller: passwordController,
                label: "Password",
                icon: Icons.lock_outline,
                obscure: true,
              ),

              const SizedBox(height: 24),

              // 🔹 Login Button
              _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF2E86C1))
                  : ElevatedButton(
                      onPressed: loginUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF2E86C1),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

              const SizedBox(height: 16),

              // 🔹 Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Color(0xFF2E86C1)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🔹 Signup Redirect
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => SignupScreen()),
                  );
                },
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2E86C1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Custom Input
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E86C1)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF39C12), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
