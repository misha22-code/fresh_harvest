import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_harvest/config/app_constants.dart';
import 'package:fresh_harvest/models/product.dart';
import 'package:fresh_harvest/models/app_user.dart';
import 'package:fresh_harvest/models/review.dart';
import 'package:fresh_harvest/providers/auth_provider.dart';
import 'package:fresh_harvest/providers/language_provider.dart';
import 'package:fresh_harvest/screens/customer/customer_cart_manager.dart';
import 'package:fresh_harvest/services/mock_data_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<List<Review>> _reviewsFuture = Future.value([]);
  Review? _existingReview;
  int _selectedRating = 5;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmittingReview = false;

  // Quantity selector state
  int _quantity = 1;

  // Weight selector state
  static const List<String> _weightOptions = [
    '250g (1 Pao)',
    '500g (Half Kg)',
    '1 Kg',
    '2 Kg',
  ];
  String _selectedWeight = _weightOptions.first;

  bool get _isInCart => CustomerCartManager.instance.contains(widget.product);

  @override
  void initState() {
    super.initState();
    _refreshReviews();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _refreshReviews() async {
    final currentUser = context.read<AuthProvider>().currentUser;
    final reviews =
        await MockDataService.instance.getReviewsForProduct(widget.product.id);
    final existingReview = currentUser != null
        ? await MockDataService.instance.getReviewForProductByCustomer(
            widget.product.id,
            currentUser.id,
          )
        : null;
    if (!mounted) return;
    setState(() {
      _reviewsFuture = Future.value(reviews);
      _existingReview = existingReview;
    });
  }

  Future<void> _addReview() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null || currentUser.role != UserRole.customer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login as a customer to submit a review.')),
      );
      return;
    }
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a review before submitting.')),
      );
      return;
    }
    if (_existingReview != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already submitted a review.')),
      );
      return;
    }

    setState(() => _isSubmittingReview = true);
    try {
      final review = Review(
        id: 'r${DateTime.now().millisecondsSinceEpoch}',
        productId: widget.product.id,
        customerId: currentUser.id,
        customerName: currentUser.name,
        rating: _selectedRating,
        comment: _reviewController.text.trim(),
        createdAt: DateTime.now(),
      );
      await MockDataService.instance.addReview(review);
      _reviewController.clear();
      await _refreshReviews();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSubmittingReview = false);
    }
  }

  Widget _buildStarRow(int rating, {double iconSize = 20}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
          size: iconSize,
          color: Colors.amber.shade700,
        );
      }),
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      children: List.generate(5, (index) {
        final value = index + 1;
        return IconButton(
          onPressed: () => setState(() => _selectedRating = value),
          icon: Icon(
            value <= _selectedRating
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: Colors.amber.shade700,
          ),
          iconSize: 28,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        );
      }),
    );
  }

  Widget _buildWeightSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _weightOptions.map((weight) {
        final isSelected = weight == _selectedWeight;
        return ChoiceChip(
          label: Text(weight),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedWeight = weight),
          showCheckmark: false,
          backgroundColor: Colors.white,
          selectedColor: kPrimaryColor.withAlpha(25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? kPrimaryColor : kBorderColor,
            ),
          ),
          labelStyle: TextStyle(
            color: isSelected ? kPrimaryColor : kTextSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        );
      }).toList(),
    );
  }

  void _addToCart() {
    for (int i = 0; i < _quantity; i++) {
      CustomerCartManager.instance.addProduct(widget.product);
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '$_quantity × ${widget.product.name} ($_selectedWeight) added to cart.'),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final product      = widget.product;
    final isUrdu       = context.watch<LanguageProvider>().isUrdu;
    final cs           = Theme.of(context).colorScheme;
    final tt           = Theme.of(context).textTheme;

    final String origin  = _safeField(product, 'origin')  ?? '—';
    final String quality = _safeField(product, 'quality') ?? '—';
    final String usage   = _safeField(product, 'usage')   ?? '—';

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? product.urduName : product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Large product image ────────────────────────────────────────
            AspectRatio(
              aspectRatio: 1 / 1,
              child: Container(
                color: cs.surfaceContainerHighest,
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (_, _, _) => Center(
                    child: Icon(Icons.image_not_supported_rounded,
                        size: 64, color: kTextSecondary),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(kPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Urdu name (large) ────────────────────────────────────
                  Text(
                    product.urduName,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 2),

                  // ── English name (smaller) ───────────────────────────────
                  Text(
                    product.name,
                    style: tt.bodyMedium?.copyWith(color: kTextSecondary),
                  ),
                  const SizedBox(height: 12),

                  // ── Price + stock badge ──────────────────────────────────
                  Row(
                    children: [
                      Text(
                        'Rs ${product.price.toStringAsFixed(0)} / ${product.unit}',
                        style: tt.titleLarge?.copyWith(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StockBadge(stock: product.stockQuantity),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Weight selector ───────────────────────────────────────
                  Text('Weight',
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  _buildWeightSelector(),
                  const SizedBox(height: 20),

                  // ── Origin / Quality / Usage ─────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withAlpha(120),
                      borderRadius: BorderRadius.circular(kCardRadius),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Column(
                      children: [
                        _MetaInfoRow(
                            emoji: '📍', label: 'Origin',  value: origin),
                        const Divider(height: 18),
                        _MetaInfoRow(
                            emoji: '⭐', label: 'Quality', value: quality),
                        const Divider(height: 18),
                        _MetaInfoRow(
                            emoji: '🥤', label: 'Usage',   value: usage),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Description ──────────────────────────────────────────
                  if (product.description.isNotEmpty) ...[
                    Text('About this product',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(product.description,
                        style: tt.bodyMedium
                            ?.copyWith(height: 1.5)),
                    const SizedBox(height: 20),
                  ],

                  // ── Quantity selector ────────────────────────────────────
                  Row(
                    children: [
                      Text('Quantity',
                          style: tt.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      // [ - ]  n  [ + ]
                      _QtyButton(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                      ),
                      Container(
                        width: 44,
                        alignment: Alignment.center,
                        child: Text(
                          '$_quantity',
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.add_rounded,
                        onTap: () {
                          if (_quantity < product.stockQuantity) {
                            setState(() => _quantity++);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Available stock hint
                  Text(
                    'Available: ${product.stockQuantity} ${product.unit}',
                    style: tt.bodySmall?.copyWith(color: kTextSecondary),
                  ),
                  const SizedBox(height: 20),

                  // ── Large Add to Cart button ─────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: (_isInCart ||
                              product.stockQuantity <= 0)
                          ? null
                          : _addToCart,
                      icon: Icon(
                        _isInCart
                            ? Icons.check_circle_rounded
                            : Icons.shopping_cart_rounded,
                        size: 22,
                      ),
                      label: Text(
                        _isInCart
                            ? 'Added to Cart ✓'
                            : 'Add to Cart  ($_quantity)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isInCart ? kAccentColor : kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(kButtonRadius),
                        ),
                        elevation: _isInCart ? 0 : 3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Reviews ──────────────────────────────────────────────
                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Text('Unable to load product reviews.');
                      }

                      final reviews = snapshot.data ?? [];
                      final averageRating = reviews.isEmpty
                          ? 0.0
                          : reviews
                                  .map((r) => r.rating)
                                  .reduce((a, b) => a + b) /
                              reviews.length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer Reviews',
                              style: tt.titleLarge),
                          const SizedBox(height: 12),
                          if (reviews.isEmpty)
                            Text(
                                'No reviews yet. Be the first to rate this product.',
                                style: tt.bodyMedium),
                          if (reviews.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  averageRating.toStringAsFixed(1),
                                  style: tt.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 8),
                                _buildStarRow(averageRating.round(),
                                    iconSize: 22),
                                const SizedBox(width: 12),
                                Text('(${reviews.length} reviews)',
                                    style: tt.bodyMedium),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (authProvider.currentUser?.role ==
                              UserRole.customer) ...[
                            if (_existingReview != null)
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        kCardRadius)),
                                child: Padding(
                                  padding: const EdgeInsets.all(kPadding),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Your Review',
                                          style: tt.titleMedium),
                                      const SizedBox(height: 8),
                                      _buildStarRow(_existingReview!.rating,
                                          iconSize: 22),
                                      const SizedBox(height: 8),
                                      Text(_existingReview!.comment),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        kCardRadius)),
                                child: Padding(
                                  padding: const EdgeInsets.all(kPadding),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Leave a Rating',
                                          style: tt.titleMedium),
                                      const SizedBox(height: 12),
                                      _buildRatingSelector(),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: _reviewController,
                                        maxLines: 4,
                                        decoration: const InputDecoration(
                                          hintText:
                                              'Share your thoughts about this product',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 44,
                                        child: FilledButton(
                                          onPressed: _isSubmittingReview
                                              ? null
                                              : _addReview,
                                          child: _isSubmittingReview
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                )
                                              : const Text('Submit Review'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
                          if (authProvider.currentUser?.role !=
                              UserRole.customer)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                authProvider.currentUser == null
                                    ? 'Login as a customer to write a review.'
                                    : 'Only customers can submit product reviews.',
                                style: tt.bodyMedium,
                              ),
                            ),
                          ...reviews.map(
                            (review) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      kCardRadius)),
                              child: Padding(
                                padding: const EdgeInsets.all(kPadding),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(review.customerName,
                                            style: tt.titleMedium),
                                        _buildStarRow(review.rating,
                                            iconSize: 18),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(review.comment),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Reviewed on ${review.createdAt.toLocal().toString().split(' ').first}',
                                      style: tt.bodySmall?.copyWith(
                                          color: kTextSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String? _safeField(Product product, String field) {
    try {
      switch (field) {
        case 'origin':  return (product as dynamic).origin  as String?;
        case 'quality': return (product as dynamic).quality as String?;
        case 'usage':   return (product as dynamic).usage   as String?;
      }
    } catch (_) {}
    return null;
  }
}

// ─── Quantity button ──────────────────────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData     icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: kPrimaryColor.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kPrimaryColor.withAlpha(70)),
        ),
        child: Icon(icon, size: 20, color: kPrimaryColor),
      ),
    );
  }
}

// ─── Meta info row ────────────────────────────────────────────────────────────

class _MetaInfoRow extends StatelessWidget {
  const _MetaInfoRow({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: tt.bodySmall?.copyWith(
              color: kTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ─── Stock badge ──────────────────────────────────────────────────────────────

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    if (stock <= 0) {
      bg = Colors.red.shade100;
      fg = Colors.red.shade700;
      label = 'Out of stock';
    } else if (stock <= 5) {
      bg = Colors.orange.shade100;
      fg = Colors.orange.shade700;
      label = 'Low stock';
    } else {
      bg = Colors.green.shade100;
      fg = Colors.green.shade700;
      label = 'In stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          style: TextStyle(
              color: fg, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}