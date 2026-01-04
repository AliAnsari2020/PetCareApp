import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:userpanel/onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<Offset> _textAnimation;
  late AnimationController _logoController;

  @override
  void initState() {
    super.initState();

    // Logo scaling animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.9,
      upperBound: 1.05,
    )..repeat(reverse: true);

    // Text slide animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _textAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Delay before starting text animation
    Timer(const Duration(milliseconds: 1200), () {
      _textController.forward();
    });

    // Navigate to Onboarding after 3.5s
    Timer(const Duration(milliseconds: 3500), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => OnboardingPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (more professional look)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0f2027),
                  Color(0xFF203a43),
                  Color(0xFF2c5364),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Floating circles (animated)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: 0.12,
              duration: const Duration(seconds: 2),
              child: CustomPaint(painter: _FloatingCirclesPainter()),
            ),
          ),

          // Center content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie Animation with scaling effect
                  ScaleTransition(
                    scale: _logoController,
                    child: SizedBox(
                      height: 200,
                      child: Lottie.asset(
                        'images/petsworld.json',
                        repeat: true,
                        animate: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // App Name with glow
                  FadeTransition(
                    opacity: _textController,
                    child: Text(
                      "Pet Care",
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            blurRadius: 12,
                            color: Colors.black.withOpacity(0.4),
                            offset: const Offset(2, 3),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  SlideTransition(
                    position: _textAnimation,
                    child: Text(
                      "Wellness • Adoption • Love",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Progress Indicator
                  const SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.white24,
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Floating circles background painter
class _FloatingCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.06);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 60, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.4), 80, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 120, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
