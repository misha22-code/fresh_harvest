// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_harvest/providers/auth_provider.dart';
import 'package:fresh_harvest/providers/product_provider.dart';
import 'package:fresh_harvest/providers/order_provider.dart';
import 'package:fresh_harvest/providers/cart_provider.dart';
import 'package:fresh_harvest/screens/splash/splash_screen.dart';
import 'package:fresh_harvest/screens/customer/customer_home_screen.dart';
import 'package:fresh_harvest/screens/owner/owner_dashboard_screen.dart';
import 'package:fresh_harvest/screens/owner/owner_login_screen.dart';

void main() {
  runApp(const FreshHarvestApp());
}

class FreshHarvestApp extends StatelessWidget {
  const FreshHarvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Fresh Harvest',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/customerHome': (context) => const CustomerHomeScreen(),
          '/ownerLogin': (context) => const OwnerLoginScreen(),
          '/ownerDashboard': (context) => const OwnerDashboardScreen(),
        },
      ),
    );
  }
}