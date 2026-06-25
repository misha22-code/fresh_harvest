import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import 'package:fresh_harvest/config/app_constants.dart';
import 'package:fresh_harvest/config/app_routes.dart';
import 'package:fresh_harvest/models/app_user.dart';
import 'package:fresh_harvest/models/category.dart';
import 'package:fresh_harvest/models/product.dart';
import 'package:fresh_harvest/providers/auth_provider.dart';
import 'package:fresh_harvest/providers/language_provider.dart';
import 'package:fresh_harvest/screens/customer/cart_screen.dart';
import 'package:fresh_harvest/screens/customer/categories_screen.dart';
import 'package:fresh_harvest/screens/customer/customer_cart_manager.dart';
import 'package:fresh_harvest/screens/customer/order_history_screen.dart';
import 'package:fresh_harvest/screens/customer/profile_screen.dart';
import 'package:fresh_harvest/services/mock_data_service.dart';
import 'package:fresh_harvest/providers/product_provider.dart';
import 'package:fresh_harvest/widgets/bottom_nav_bar.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 4);
    CustomerCartManager.instance.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CustomerCartManager.instance.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _onTabSelected(int index) => setState(() => _selectedIndex = index);

  void _openProductDetails(Product product) =>
      Navigator.pushNamed(context, AppRoutes.productDetails, arguments: product);

  void _openCheckout() => Navigator.pushNamed(context, AppRoutes.checkout);

  void _handleLogout() {
    context.read<AuthProvider>().logout();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _handleSwitchRole() {
    context.read<AuthProvider>().logout();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Future<void> _orderOnWhatsApp() async {
    final isUrdu = context.read<LanguageProvider>().isUrdu;
    final cartItems = CustomerCartManager.instance.items;

    String message;
    if (cartItems.isNotEmpty) {
      final lines = cartItems.map((entry) {
        final product = entry.product;
        final qty = entry.quantity;
        return '- ${product.name} x$qty (Rs ${(product.price * qty).toStringAsFixed(0)})';
      }).join('\n');

      final total = CustomerCartManager.instance.subtotal
          .toStringAsFixed(0);

      message = isUrdu
          ? 'السلام علیکم، میں یہ آرڈر کرنا چاہتا ہوں:\n\n$lines\n\nکل: Rs $total'
          : 'Hello, I would like to order the following:\n\n$lines\n\nTotal: Rs $total';
    } else {
      message = isUrdu
          ? 'سلام، میں تازہ سبزیاں آرڈر کرنا چاہتا ہوں۔'
          : 'Hello, I would like to order fresh vegetables.';
    }

    const String whatsAppNumber = '923001234567';
    
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$whatsAppNumber?text=$encoded');

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isUrdu
                  ? 'واٹس ایپ کھولنے میں ناکامی۔'
                  : 'Could not open WhatsApp.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isUrdu
                  ? 'واٹس ایپ کھولنے میں ناکامی: $e'
                  : 'Could not open WhatsApp: $e',
            ),
          ),
        );
      }
    }
  }

  static const _titles = ['Home', 'Categories', 'Cart', 'Orders', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeContent(onProductTap: _openProductDetails),
      CategoriesScreen(onProductTap: _openProductDetails),
      CartScreen(onCheckout: _openCheckout),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];

    final cs = Theme.of(context).colorScheme;
    final isUrdu = context.watch<LanguageProvider>().isUrdu;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 52,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco_rounded, color: cs.primary, size: 20),
            const SizedBox(width: 6),
            Text(
              _titles[_selectedIndex],
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                iconSize: 22,
                tooltip: 'Cart',
                onPressed: () => _onTabSelected(2),
              ),
              if (CustomerCartManager.instance.totalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: cs.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${CustomerCartManager.instance.totalItems}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 22),
            onSelected: (v) {
              if (v == 'switch') _handleSwitchRole();
              if (v == 'logout') _handleLogout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'switch',
                child: Row(children: [
                  Icon(Icons.swap_horiz_rounded, size: 18),
                  SizedBox(width: 10),
                  Text('Switch Role'),
                ]),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout_rounded, size: 18),
                  SizedBox(width: 10),
                  Text('Logout'),
                ]),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _orderOnWhatsApp,
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.chat_bubble_rounded, size: 20),
              label: Text(
                isUrdu ? 'واٹس ایپ پر آرڈر کریں' : 'Order on WhatsApp',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            )
          : null,
      bottomNavigationBar: FreshHarvestBottomNavBar(
        role: UserRole.customer,
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        cartBadge: CustomerCartManager.instance.totalItems > 0
            ? CustomerCartManager.instance.totalItems
            : null,
      ),
    );
  }
}

// ─── Home Content ─────────────────────────────────────────────────────────────

class _HomeContent extends StatefulWidget {
  const _HomeContent({required this.onProductTap});

  final ValueChanged<Product> onProductTap;

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  late final Future<List<Category>> _categoriesFuture;
  final _searchController = TextEditingController();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = MockDataService.instance.getCategories();
    context.read<ProductProvider>().loadProducts();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  Future<void> _toggleListening() async {
    final isUrdu = context.read<LanguageProvider>().isUrdu;

    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUrdu
                ? 'صوتی تلاش دستیاب نہیں ہے۔'
                : 'Voice search is not available on this device.',
          ),
        ),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);

    await _speech.listen(
      localeId: isUrdu ? 'ur_PK' : 'en_US',
      onResult: (result) {
        _searchController.text = result.recognizedWords;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchController.text.length),
        );
        // ✅ Use provider's search which now supports Urdu
        context.read<ProductProvider>().search(result.recognizedWords);

        if (result.finalResult && mounted) {
          setState(() => _isListening = false);
        }
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.stop();
    super.dispose();
  }

  static const _categoryEmojis = <String, String>{
    'cat1': '🍎',
    'cat2': '🥦',
    'cat3': '🥬',
    'cat4': '🥭',
    'cat5': '🌿',
    'cat6': '🌱',
  };

  @override
  Widget build(BuildContext context) {
    final isUrdu = context.watch<LanguageProvider>().isUrdu;

    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load home content.'));
        }

        final categories = snapshot.data ?? [];

        return Consumer<ProductProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: kPadding, vertical: kPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const _WelcomeCard(),
                    const SizedBox(height: 16),

                    // ── Search bar with mic ──────────────────────────────────
                    TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        // ✅ Use provider's search which supports Urdu
                        if (query.isEmpty) {
                          provider.search('');
                        } else {
                          provider.search(query);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: _isListening
                            ? (isUrdu ? 'سن رہا ہے…' : 'Listening…')
                            : (isUrdu
                                ? 'پھل یا سبزی تلاش کریں…'
                                : 'Search products…'),
                        prefixIcon:
                            const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isListening
                                ? Icons.mic_rounded
                                : Icons.mic_none_rounded,
                            size: 20,
                            color: _isListening
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                          tooltip: isUrdu ? 'صوتی تلاش' : 'Voice search',
                          onPressed: _toggleListening,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Category chips ──────────────────────────────────────
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length + 1,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            final isAll =
                                provider.selectedCategoryId == null;
                            return _CategoryChip(
                              emoji: '🛒',
                              label: isUrdu ? 'سب' : 'All',
                              isSelected: isAll,
                              onTap: () {
                                _searchController.clear();
                                provider.filterByCategory(null);
                              },
                            );
                          }
                          final cat = categories[index - 1];
                          return _CategoryChip(
                            emoji: _categoryEmojis[cat.id] ?? '🌿',
                            label: cat.name,
                            isSelected:
                                provider.selectedCategoryId == cat.id,
                            onTap: () {
                              _searchController.clear();
                              provider.filterByCategory(cat.id);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Products grid ───────────────────────────────────────
                    if (provider.products.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            isUrdu
                                ? 'کوئی پروڈکٹ نہیں ملی'
                                : 'No products found.',
                            style:
                                Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          final product = provider.products[index];
                          return _ProductTile(
                            product: product,
                            isUrdu: isUrdu,
                            onTap: () => widget.onProductTap(product),
                            onAddToCart: () {
                              CustomerCartManager.instance
                                  .addProduct(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${product.name} added to cart.'),
                                  duration:
                                      const Duration(milliseconds: 900),
                                ),
                              );
                            },
                            isInCart: CustomerCartManager.instance
                                .contains(product),
                          );
                        },
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Welcome Card ─────────────────────────────────────────────────────────────

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isUrdu = context.watch<LanguageProvider>().isUrdu;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withAlpha(70),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUrdu ? '👋 السلام علیکم' : '👋 Welcome Back',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  isUrdu
                      ? 'تازہ پھل اور سبزیاں'
                      : 'Fresh Fruits & Vegetables',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onPrimary.withAlpha(220),
                        height: 1.5,
                        fontSize: 12,
                      ),
                ),
                Text(
                  isUrdu
                      ? 'آپ کے دروازے تک ڈیلیوری'
                      : 'Delivered to your doorstep',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onPrimary.withAlpha(220),
                        height: 1.5,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.categories),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.onPrimary,
                    foregroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    minimumSize: const Size(0, 32),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Text(
                    isUrdu ? 'خریداری کریں' : 'Shop Now',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.onPrimary.withAlpha(38),
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Text('🥦', style: TextStyle(fontSize: 34))),
          ),
        ],
      ),
    );
  }
}

// ─── Category Chip ────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String       emoji;
  final String       label;
  final bool         isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withAlpha(70),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? cs.onPrimary : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product Tile ─────────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.isInCart,
    required this.isUrdu,
  });

  final Product      product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final bool         isInCart;
  final bool         isUrdu;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1.5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kCardRadius)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Product image ──────────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (_, _, _) => Container(
                      color: kAccentColor.withAlpha(30),
                      child: const Icon(Icons.eco_rounded,
                          color: kPrimaryColor, size: 36),
                    ),
                  ),
                  if (isInCart)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: kPrimaryColor,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 10),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info panel ─────────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // Urdu name (primary) + English name (secondary)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.urduName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                          style: tt.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurface.withAlpha(140),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),

                    // Price
                    Text(
                      'Rs ${product.price.toStringAsFixed(0)}/${product.unit}',
                      style: tt.bodySmall?.copyWith(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),

                    // Add to Cart button
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: ElevatedButton(
                        onPressed: onAddToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isInCart ? kAccentColor : kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                          textStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                        child: Text(
                          isInCart
                              ? (isUrdu ? 'شامل ✓' : 'Added ✓')
                              : (isUrdu ? '+ ٹوکری' : '+ Cart'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}