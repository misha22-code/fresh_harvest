// lib/screens/customer/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fresh_harvest/config/app_constants.dart';
import 'package:fresh_harvest/config/app_routes.dart';
import 'package:fresh_harvest/models/order.dart';
import 'package:fresh_harvest/models/payment_method.dart';
import 'package:fresh_harvest/providers/auth_provider.dart';
import 'package:fresh_harvest/providers/order_provider.dart';
import 'package:fresh_harvest/screens/customer/customer_cart_manager.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CustomerCartManager _cartManager = CustomerCartManager.instance;
  final _formKey          = GlobalKey<FormState>();
  final _nameController   = TextEditingController();
  final _phoneController  = TextEditingController();
  final _streetController = TextEditingController();

  bool             _isProcessing     = false;
  String           _selectedTimeSlot = '10:00 AM - 12:00 PM';
  String?          _selectedArea;
  PaymentMethod    _paymentMethod    = PaymentMethod.cod;

  // Location fields
  double? _latitude;
  double? _longitude;
  bool    _locationLoading = false;

  final List<String> _deliverySlots = [
    '10:00 AM - 12:00 PM',
    '12:00 PM - 02:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
  ];

  final List<String> kohatAreas = [
    'Kohat Cantt', 'KDA', 'Jungle Khel', 'Tirah Bazaar',
    'Muslimabad', 'Dhoda', 'Jarma', 'Bahadar Kot',
    'Muhammadzai', 'Nusrat Khel', 'Usterzai Bala', 'Usterzai Payan',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> _selectLocation() async {
    setState(() => _locationLoading = true);

    try {
      // Check / request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required.')),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude  = pos.latitude;
        _longitude = pos.longitude;
      });

      // Open Google Maps so user can verify / drop pin
      final mapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}',
      );
      if (await canLaunchUrl(mapsUri)) await launchUrl(mapsUri);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: $e')),
      );
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  // ── WhatsApp order ────────────────────────────────────────────────────────

  Future<void> _orderOnWhatsApp() async {
    final items = _cartManager.items;
    final itemLines = items
        .map((i) =>
            '• ${i.product.name} x${i.quantity} — Rs ${i.lineTotal.toStringAsFixed(0)}')
        .join('\n');

    final message =
        'Hello, I would like to order fresh vegetables.\n\n'
        '$itemLines\n\n'
        'Total: Rs ${_cartManager.totalAmount.toStringAsFixed(0)}\n'
        'Delivery Area: ${_selectedArea ?? 'N/A'}\n'
        'Time Slot: $_selectedTimeSlot\n'
        'Payment: ${_paymentMethod.label}';

    // Replace with your actual WhatsApp business number (international format, no +)
    const phoneNumber = '923001234567';
    final encoded    = Uri.encodeComponent(message);
    final uri        = Uri.parse('https://wa.me/$phoneNumber?text=$encoded');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp is not installed.')),
      );
    }
  }

  // ── Place order ───────────────────────────────────────────────────────────

  Future<void> _placeOrder() async {
    if (_cartManager.items.isEmpty) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final customerId = context.read<AuthProvider>().currentUser?.id ?? 'u1';
    final deliveryAddress = Address(
      street: _streetController.text.trim(),
      city:   _selectedArea ?? '',
      state:  'KP',
      postalCode: '26000',
    );

    // ✅ FIXED: Using correct placeOrder parameters
    await context.read<OrderProvider>().placeOrder(
      _cartManager.items,                          // List<CartItem>
      deliveryAddress,                             // Address
      customerId,                                  // customerId
      _nameController.text.trim(),                 // customerName
      _phoneController.text.trim(),                // phoneNumber
      _selectedArea ?? '',                         // city
      _selectedTimeSlot,                           // deliveryTimeSlot
      deliveryNotes: null,                         // deliveryNotes
      latitude: _latitude,                         // latitude
      longitude: _longitude,                       // longitude
    );

    _cartManager.clear();
    if (!mounted) return;

    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully! 🎉')),
    );

    Navigator.pushReplacementNamed(context, AppRoutes.orderHistory);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final items = _cartManager.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: items.isEmpty
          ? const Center(
              child: Text('Your cart is empty. Add items before checkout.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(kPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Delivery Details ──────────────────────────────────
                    _SectionCard(
                      icon: Icons.local_shipping_outlined,
                      title: 'Delivery Details',
                      child: Column(
                        children: [
                          _FormField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter your name.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _FormField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter your phone number.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _FormField(
                            controller: _streetController,
                            label: 'Street / Landmark',
                            icon: Icons.home_outlined,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter a delivery address.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedArea,
                            decoration: const InputDecoration(
                              labelText: 'Delivery Area',
                              prefixIcon: Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Select area'),
                            items: kohatAreas
                                .map((a) => DropdownMenuItem(
                                    value: a, child: Text(a)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedArea = v),
                            validator: (v) =>
                                (v == null || v.isEmpty)
                                    ? 'Please select a delivery area.'
                                    : null,
                          ),
                          const SizedBox(height: 12),

                          // Select Location button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _locationLoading
                                  ? null
                                  : _selectLocation,
                              icon: _locationLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.map_rounded),
                              label: Text(
                                _latitude != null
                                    ? 'Location saved ✓'
                                    : 'Select Location on Map',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kPrimaryColor,
                                side: BorderSide(
                                  color: _latitude != null
                                      ? Colors.green
                                      : kPrimaryColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          // Show saved coordinates
                          if (_latitude != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              '📍 ${_latitude!.toStringAsFixed(5)}, '
                              '${_longitude!.toStringAsFixed(5)}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.green.shade700),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Time slot ─────────────────────────────────────────
                    _SectionCard(
                      icon: Icons.access_time_rounded,
                      title: 'Delivery Time Slot',
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedTimeSlot,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.schedule_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: _deliverySlots
                            .map((s) => DropdownMenuItem(
                                value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedTimeSlot = v);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Payment Method ────────────────────────────────────
                    _SectionCard(
                      icon: Icons.payment_rounded,
                      title: 'Payment Method',
                      child: Column(
                        children: PaymentMethod.values.map((method) {
                          final isSelected = _paymentMethod == method;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.green.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.green
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: RadioListTile<PaymentMethod>(
                              value: method,
                              groupValue: _paymentMethod,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _paymentMethod = value);
                                }
                              },
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: method.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(method.icon,
                                        color: method.color, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    method.label,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? Colors.green.shade800
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              secondary: isSelected
                                  ? const Icon(Icons.check_circle_rounded,
                                      color: Colors.green)
                                  : null,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              activeColor: Colors.green,
                              controlAffinity:
                                  ListTileControlAffinity.trailing,
                              dense: true,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Order summary ─────────────────────────────────────
                    _SectionCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'Order Summary',
                      child: Column(
                        children: [
                          ...items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        item.product.imageUrl,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) =>
                                            Container(
                                          width: 48,
                                          height: 48,
                                          color: kBorderColor,
                                          child: const Icon(
                                              Icons.broken_image,
                                              color: kTextSecondary),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                          Text(
                                            '${item.quantity} × Rs ${item.product.price.toStringAsFixed(0)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: kTextSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Rs ${item.lineTotal.toStringAsFixed(0)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: kPrimaryColor),
                                    ),
                                  ],
                                ),
                              )),

                          const Divider(height: 20),
                          _TotalRow(
                            label: 'Subtotal',
                            value: 'Rs ${_cartManager.subtotal.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 6),
                          _TotalRow(
                            label: 'Delivery Fee',
                            value: 'Rs ${_cartManager.deliveryCharge.toStringAsFixed(0)}',
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Rs ${_cartManager.totalAmount.toStringAsFixed(0)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Total banner ──────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(kCardRadius),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rs ${_cartManager.totalAmount.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Place Order button ────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: _isProcessing ? null : _placeOrder,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Icon(Icons.check_circle_outline_rounded),
                        label: _isProcessing
                            ? const Text('Placing Order…')
                            : const Text(
                                'Place Order',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                        style: FilledButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kButtonRadius),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Order on WhatsApp button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: _orderOnWhatsApp,
                        icon: const Icon(Icons.chat_rounded),
                        label: const Text(
                          'Order on WhatsApp',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF25D366),
                          side: const BorderSide(
                              color: Color(0xFF25D366), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kButtonRadius),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String   title;
  final Widget   child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kPrimaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Form field ────────────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController       controller;
  final String                      label;
  final IconData                    icon;
  final TextInputType?              keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

// ── Total row ─────────────────────────────────────────────────────────────────

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: kTextSecondary)),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}