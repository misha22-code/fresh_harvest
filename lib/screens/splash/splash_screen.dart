// lib/screens/splash/splash_splash.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_harvest/providers/auth_provider.dart';
import 'package:fresh_harvest/screens/customer/customer_home_screen.dart';
import 'package:fresh_harvest/screens/owner/owner_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isOwnerLoginPressed = false;

  @override
  void initState() {
    super.initState();
    _navigateToCustomer();
  }

  // ✅ Customer automatically goes to home screen after 2 seconds
  Future<void> _navigateToCustomer() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // ✅ Only navigate if owner login button was NOT pressed
    if (!_isOwnerLoginPressed) {
      final authProvider = context.read<AuthProvider>();
      authProvider.autoLoginAsCustomer();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/customerHome');
      }
    }
  }

  void _onOwnerLoginPressed() {
    setState(() {
      _isOwnerLoginPressed = true;
    });
    Navigator.pushNamed(context, '/ownerLogin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // ─── Center Content ────────────────────────────────────────────
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco_rounded, size: 80, color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Fresh Harvest',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Fresh Vegetables & Fruits',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // ─── Owner Login Button (Bottom) ──────────────────────────────
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _onOwnerLoginPressed,
                  icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
                  label: const Text(
                    '👤 Owner Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}