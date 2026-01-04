import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:userpanel/auth/login.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController(); // Added username
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = "Pet Owner"; // Default role
  bool _isLoading = false;

  final Color primaryColor = const Color(0xFF2E86C1);
  final Color secondaryColor = const Color(0xFF28B463);
  final Color accentColor = const Color(0xFFF39C12);
  final Color backgroundColor = const Color(0xFFF4F6F7);
  final Color fontDark = const Color(0xFF2C3E50);
  final Color fontWhite = Colors.white;

  // 🔹 Signup Function
  void _signupWithEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // 🔹 Create user in Firebase Auth
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // 🔹 Store user data in Firestore
        await FirebaseFirestore.instance
            .collection("users")
            .doc(credential.user!.uid)
            .set({
              "name": _nameController.text.trim(),
              "username": _usernameController.text.trim(),
              "phone": _phoneController.text.trim(),
              "email": _emailController.text.trim(),
              "password": _passwordController.text.trim(), // Added password
              "role": _selectedRole,
              "createdAt": DateTime.now(),
            });

        setState(() => _isLoading = false);

        // 🔹 Show Success Modal
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    "images/Trailloading.json",
                    height: 120,
                    repeat: false,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Account Created Successfully 🎉",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: fontDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text("Go to Login"),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            ),
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed: ${e.toString()}")),
        );
      }
    }
  }

  // 🔹 Input Validator
  String? _validateField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }
    if (fieldName == "Email" &&
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Enter a valid email";
    }
    if (fieldName == "Password" && value.length < 6) {
      return "Password must be at least 6 characters";
    }
    if (fieldName == "Phone Number" &&
        !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
      return "Enter a valid phone number";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset("images/signup.json", height: 180),
              Text(
                "Join Pet Care 🐾",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: fontDark,
                ),
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInput("Full Name", _nameController),
                    const SizedBox(height: 16),
                    _buildInput("Username", _usernameController), // Added
                    const SizedBox(height: 16),
                    _buildInput("Phone Number", _phoneController),
                    const SizedBox(height: 16),
                    _buildInput("Email", _emailController),
                    const SizedBox(height: 16),
                    _buildInput("Password", _passwordController, obscure: true),
                    const SizedBox(height: 16),

                    // 🔹 Role Selector
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: "Select Role",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ["Pet Owner", "Veterinarian", "Shelter Admin"]
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedRole = value!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _isLoading
                  ? CircularProgressIndicator(color: secondaryColor)
                  : ElevatedButton(
                      onPressed: _signupWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: fontWhite,
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: Text(
                  "Already have an account? Log in",
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Custom Input Field
  Widget _buildInput(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (value) => _validateField(value, label),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
