import 'package:flutter/material.dart';
import 'package:userpanel/auth/login.dart';
import 'package:userpanel/auth/signup.dart';
import 'package:userpanel/onboarding.dart';

class GetStartedScreen extends StatelessWidget {
  final Color primaryColor = const Color(0xFF2E86C1); // Royal Blue
  final Color secondaryColor = const Color(0xFF28B463); // Green
  final Color accentColor = const Color(0xFFF39C12); // Orange
  final Color backgroundColor = const Color(0xFFF4F6F7); // Light Grey
  final Color fontDark = const Color(0xFF2C3E50); // Dark Grey
  final Color fontWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Logo + Sign in Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'images/petcarelogo.png',
                    height: 80,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),

              Center(
                child: Image.asset(
                  "images/getstart.png",
                  height: 400,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OnboardingPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Find Pet Care",
                  style: TextStyle(
                    fontSize: 16,
                    color: fontWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SignupScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: secondaryColor,
                  side: BorderSide(color: secondaryColor, width: 2),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: secondaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Center(
                child: Text(
                  "Trusted pet care right around the corner 🐾",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: accentColor,
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
}
