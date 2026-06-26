// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_harvest/providers/auth_provider.dart';
import 'package:fresh_harvest/providers/product_provider.dart';
import 'package:fresh_harvest/providers/order_provider.dart';
import 'package:fresh_harvest/providers/cart_provider.dart';
import 'package:fresh_harvest/providers/language_provider.dart';
import 'package:fresh_harvest/screens/splash/splash_screen.dart';
import 'package:fresh_harvest/screens/customer/customer_home_screen.dart';
import 'package:fresh_harvest/screens/customer/product_details_screen.dart';
import 'package:fresh_harvest/screens/customer/cart_screen.dart';
import 'package:fresh_harvest/screens/customer/checkout_screen.dart';
import 'package:fresh_harvest/screens/customer/order_history_screen.dart';
import 'package:fresh_harvest/screens/customer/profile_screen.dart';
import 'package:fresh_harvest/screens/customer/categories_screen.dart';
import 'package:fresh_harvest/screens/owner/owner_dashboard_screen.dart';
import 'package:fresh_harvest/screens/owner/owner_login_screen.dart';
import 'package:fresh_harvest/screens/owner/owner_products_screen.dart';
import 'package:fresh_harvest/screens/owner/owner_orders_screen.dart';
import 'package:fresh_harvest/screens/owner/owner_delivery_screen.dart';
import 'package:fresh_harvest/screens/owner/owner_reports_screen.dart';
import 'package:fresh_harvest/models/product.dart';

void main() {
  runApp(const FreshHarvestApp());
}

class FreshHarvestApp extends StatelessWidget {
  const FreshHarvestApp({super.key});

  void _openProductDetails(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MaterialApp(
        title: 'Fresh Harvest',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/customerHome': (context) => const CustomerHomeScreen(),
          '/ownerLogin': (context) => const OwnerLoginScreen(),
          '/ownerDashboard': (context) => const OwnerDashboardScreen(),
          '/categories': (context) => CategoriesScreen(
            onProductTap: (product) => _openProductDetails(context, product),
          ),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/orderHistory': (context) => const OrderHistoryScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/ownerProducts': (context) => const OwnerProductsScreen(),
          '/ownerOrders': (context) => const OwnerOrdersScreen(),
          '/ownerDelivery': (context) => const OwnerDeliveryScreen(),
          '/ownerReports': (context) => const OwnerReportsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/productDetails') {
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product),
            );
          }
          return null;
        },
      ),
    );
  }
}