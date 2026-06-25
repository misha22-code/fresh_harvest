// lib/services/mock_data_service.dart
import 'package:fresh_harvest/config/app_constants.dart';
import 'package:fresh_harvest/models/app_user.dart';
import 'package:fresh_harvest/models/cart_item.dart';
import 'package:fresh_harvest/models/category.dart';
import 'package:fresh_harvest/models/delivery_assignment.dart' as da;
import 'package:fresh_harvest/models/order.dart';
import 'package:fresh_harvest/models/product.dart';
import 'package:fresh_harvest/models/review.dart';

class MockDataService {
  // Singleton
  static final MockDataService instance = MockDataService._();
  MockDataService._();

  // ─── Private password store ───────────────────────────────────────────────
  final Map<String, String> _passwords = {
    'alice@freshh.com':    'password123',
    'vendor@freshh.com':   'password123',
    'delivery@freshh.com': 'password123',
    'admin@freshh.com':    'password123',
    'admin@fresh.com':    '123456',
    'vendor@fresh.com':   '123456',
    'customer@fresh.com': '123456',
    'delivery@fresh.com': '123456',
  };

  // ─── Users ────────────────────────────────────────────────────────────────
  final List<AppUser> _users = [
    AppUser(
      id: 'u1',
      name: 'Admin',
      email: 'admin@fresh.com',
      phoneNumber: '03000000001',
      role: UserRole.owner,
      avatarUrl: 'https://i.pravatar.cc/150?img=7',
      region: 'Peshawar',
      area: 'Saddar',
    ),
    AppUser(
      id: 'u2',
      name: 'Vendor',
      email: 'vendor@fresh.com',
      phoneNumber: '03000000002',
      role: UserRole.owner,
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      region: 'Peshawar',
      area: 'Hayatabad',
    ),
    AppUser(
      id: 'u3',
      name: 'Customer',
      email: 'customer@fresh.com',
      phoneNumber: '03000000003',
      role: UserRole.customer,
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      region: 'Peshawar',
      area: 'University Town',
    ),
    AppUser(
      id: 'u4',
      name: 'Delivery Rider',
      email: 'delivery@fresh.com',
      phoneNumber: '03000000004',
      role: UserRole.owner,
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      region: 'Peshawar',
      area: 'Saddar',
    ),
    AppUser(
      id: 'u5',
      name: 'Alice Johnson',
      email: 'alice@freshh.com',
      phoneNumber: '+1 555-0101',
      role: UserRole.customer,
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      region: 'Peshawar',
      area: 'University Town',
    ),
    AppUser(
      id: 'u6',
      name: 'Green Farms',
      email: 'vendor@freshh.com',
      phoneNumber: '+1 555-0102',
      role: UserRole.owner,
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      region: 'Peshawar',
      area: 'Hayatabad',
    ),
    AppUser(
      id: 'u7',
      name: 'Bob Martinez',
      email: 'delivery@freshh.com',
      phoneNumber: '+1 555-0103',
      role: UserRole.owner,
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      region: 'Peshawar',
      area: 'Saddar',
    ),
    AppUser(
      id: 'u8',
      name: 'Sarah Admin',
      email: 'admin@freshh.com',
      phoneNumber: '+1 555-0104',
      role: UserRole.owner,
      avatarUrl: 'https://i.pravatar.cc/150?img=7',
      region: 'Peshawar',
      area: 'Saddar',
    ),
  ];

  // ─── Categories ───────────────────────────────────────────────────────────
  final List<Category> _categories = const [
    Category(id: 'cat1', name: 'Fruits',       iconAsset: '🍎', itemCount: 8),
    Category(id: 'cat2', name: 'Vegetables',   iconAsset: '🥦', itemCount: 7),
    Category(id: 'cat3', name: 'Leafy Greens', iconAsset: '🥬', itemCount: 5),
    Category(id: 'cat4', name: 'Exotic',       iconAsset: '🥭', itemCount: 4),
    Category(id: 'cat5', name: 'Herbs',        iconAsset: '🌿', itemCount: 3),
    Category(id: 'cat6', name: 'Organic',      iconAsset: '🌱', itemCount: 6),
  ];

  // ─── Products ─────────────────────────────────────────────────────────────
  final List<Product> _products = [
    Product(
      id: 'p1',
      vendorId: 'u2',
      categoryId: 'cat1',
      name: 'Organic Apples',
      urduName: 'سیب',
      description: 'Fresh red apples sourced daily from trusted Kohat orchards and delivered across Kohat.',
      origin: 'Kohat',
      quality: 'Premium',
      usage: 'Best for eating fresh, making juices, and baking pies',
      price: 3.99,
      unit: 'kg',
      stockQuantity: 50,
      imageUrl: 'assets/images/apple.jpg',
    ),
    Product(
      id: 'p2',
      vendorId: 'u2',
      categoryId: 'cat3',
      name: 'Baby Spinach',
      urduName: 'پالک',
      description: 'Farm-fresh baby spinach sourced from trusted suppliers and delivered daily across Kohat.',
      origin: 'Swat Valley',
      quality: 'Fresh',
      usage: 'Best for salads, smoothies, and sautéed dishes',
      price: 2.49,
      unit: 'bunch',
      stockQuantity: 30,
      imageUrl: 'assets/images/spinach.jpg',
    ),
    Product(
      id: 'p3',
      vendorId: 'u2',
      categoryId: 'cat2',
      name: 'Cherry Tomatoes',
      urduName: 'چیری ٹماٹر',
      description: 'Sweet cherry tomatoes sourced from trusted Sindh growers and delivered fresh across Kohat.',
      origin: 'Sindh',
      quality: 'Premium',
      usage: 'Best for salads, pasta, and roasting',
      price: 4.99,
      unit: 'kg',
      stockQuantity: 25,
      imageUrl: 'assets/images/tomato.jpg',
    ),
    Product(
      id: 'p4',
      vendorId: 'u2',
      categoryId: 'cat4',
      name: 'Mangoes',
      urduName: 'آم',
      description: 'Premium Chaunsa mangoes sourced from Multan\'s finest orchards and delivered at peak ripeness across Kohat.',
      origin: 'Multan',
      quality: 'Premium',
      usage: 'Best for eating fresh, smoothies, and desserts',
      price: 5.99,
      unit: 'kg',
      stockQuantity: 15,
      imageUrl: 'assets/images/mango.jpg',
    ),
    Product(
      id: 'p5',
      vendorId: 'u2',
      categoryId: 'cat5',
      name: 'Fresh Basil',
      urduName: 'تلسی',
      description: 'Aromatic fresh basil picked the same morning and delivered to kitchens across Kohat.',
      origin: 'Lahore',
      quality: 'Fresh',
      usage: 'Best for pasta sauces, garnishing, and herbal teas',
      price: 1.99,
      unit: 'bunch',
      stockQuantity: 20,
      imageUrl: 'assets/images/basil.jpg',
    ),
    Product(
      id: 'p6',
      vendorId: 'u2',
      categoryId: 'cat2',
      name: 'Broccoli Crown',
      urduName: 'بروکولی',
      description: 'Crisp nutrient-rich broccoli crowns sourced from trusted suppliers and delivered fresh across Kohat.',
      origin: 'Swat Valley',
      quality: 'Fresh',
      usage: 'Best for steaming, stir-frying, and soups',
      price: 3.49,
      unit: 'piece',
      stockQuantity: 18,
      imageUrl: 'assets/images/broccoli.jpg',
    ),
    Product(
      id: 'p7',
      vendorId: 'u2',
      categoryId: 'cat1',
      name: 'Strawberries',
      urduName: 'اسٹرابیری',
      description: 'Hand-picked Quetta strawberries sourced from trusted farms and available for same-day delivery across Kohat.',
      origin: 'Quetta',
      quality: 'Premium',
      usage: 'Best for eating fresh, jams, and desserts',
      price: 6.99,
      unit: 'punnet',
      stockQuantity: 12,
      imageUrl: 'assets/images/strawberry.jpg',
    ),
    Product(
      id: 'p8',
      vendorId: 'u2',
      categoryId: 'cat3',
      name: 'Kale',
      urduName: 'کیل ساگ',
      description: 'Organically grown kale sourced from certified farms and carefully delivered fresh across Kohat.',
      origin: 'Islamabad',
      quality: 'Organic',
      usage: 'Best for smoothies, salads, and sautéed sides',
      price: 2.99,
      unit: 'bunch',
      stockQuantity: 22,
      imageUrl: 'assets/images/kale.jpg',
    ),
    Product(
      id: 'p9',
      vendorId: 'u2',
      categoryId: 'cat4',
      name: 'Dragon Fruit',
      urduName: 'ڈریگن فروٹ',
      description: 'Exotic dragon fruit sourced from trusted Sindh growers — now available for delivery across Kohat.',
      origin: 'Sindh',
      quality: 'Exotic',
      usage: 'Best for eating fresh, fruit bowls, and smoothies',
      price: 8.99,
      unit: 'piece',
      stockQuantity: 8,
      imageUrl: 'assets/images/dragonfruit.jpg',
    ),
    Product(
      id: 'p10',
      vendorId: 'u2',
      categoryId: 'cat5',
      name: 'Cilantro',
      urduName: 'دھنیا',
      description: 'Fresh dhaniya sourced daily from trusted Punjab farms and delivered to Kohat homes in time for cooking.',
      origin: 'Punjab',
      quality: 'Fresh',
      usage: 'Best for chutneys, curries, and garnishing',
      price: 1.49,
      unit: 'bunch',
      stockQuantity: 35,
      imageUrl: 'assets/images/cilantro.jpg',
    ),
    Product(
      id: 'p11',
      vendorId: 'u2',
      categoryId: 'cat1',
      name: 'Bananas',
      urduName: 'کیلا',
      description: 'Perfectly ripened bananas sourced from trusted Sindh suppliers and delivered fresh across Kohat every day.',
      origin: 'Sindh',
      quality: 'Standard',
      usage: 'Best for eating fresh, smoothies, and baking',
      price: 1.99,
      unit: 'kg',
      stockQuantity: 60,
      imageUrl: 'assets/images/banana.jpg',
    ),
    Product(
      id: 'p12',
      vendorId: 'u2',
      categoryId: 'cat2',
      name: 'Cucumber',
      urduName: 'کھیرا',
      description: 'Cool and crisp cucumbers sourced from trusted Multan farms and delivered fresh to your doorstep across Kohat.',
      origin: 'Multan',
      quality: 'Fresh',
      usage: 'Best for salads, raita, and fresh snacking',
      price: 1.29,
      unit: 'piece',
      stockQuantity: 40,
      imageUrl: 'assets/images/cucumber.jpg',
    ),
    Product(
      id: 'p13',
      vendorId: 'u2',
      categoryId: 'cat3',
      name: 'Romaine Lettuce',
      urduName: 'رومین لیٹش',
      description: 'Crisp romaine lettuce heads sourced from trusted growers and delivered fresh to all areas of Kohat.',
      origin: 'Islamabad',
      quality: 'Fresh',
      usage: 'Best for Caesar salads, wraps, and sandwiches',
      price: 2.79,
      unit: 'head',
      stockQuantity: 16,
      imageUrl: 'assets/images/lettuce.jpg',
    ),
    Product(
      id: 'p14',
      vendorId: 'u2',
      categoryId: 'cat6',
      name: 'Organic Carrots',
      urduName: 'گاجر',
      description: 'Pesticide-free organic carrots sourced from certified Okara farms and delivered fresh across Kohat.',
      origin: 'Okara',
      quality: 'Organic',
      usage: 'Best for juicing, curries, and stir-frying',
      price: 3.29,
      unit: 'kg',
      stockQuantity: 28,
      imageUrl: 'assets/images/carrot.jpg',
    ),
    Product(
      id: 'p15',
      vendorId: 'u2',
      categoryId: 'cat4',
      name: 'Avocado',
      urduName: 'ایواکاڈو',
      description: 'Creamy ripe avocados sourced from trusted suppliers — now delivered fresh across Kohat.',
      origin: 'Sindh',
      quality: 'Premium',
      usage: 'Best for guacamole, toast, and salads',
      price: 2.49,
      unit: 'piece',
      stockQuantity: 20,
      imageUrl: 'assets/images/avocado.jpg',
    ),
    Product(
      id: 'p16',
      vendorId: 'u2',
      categoryId: 'cat2',
      name: 'Bell Peppers',
      urduName: 'شملہ مرچ',
      description: 'Colourful shimla mirch sourced from trusted Balochistan farms and delivered fresh to every corner of Kohat.',
      origin: 'Balochistan',
      quality: 'Premium',
      usage: 'Best for stir-frying, stuffing, and salads',
      price: 3.99,
      unit: '3-pack',
      stockQuantity: 14,
      imageUrl: 'assets/images/bellpepper.jpg',
    ),
    Product(
      id: 'p17',
      vendorId: 'u2',
      categoryId: 'cat1',
      name: 'Blueberries',
      urduName: 'بلیو بیری',
      description: 'Antioxidant-rich blueberries sourced from trusted Swat Valley farms and delivered to your home across Kohat.',
      origin: 'Swat Valley',
      quality: 'Premium',
      usage: 'Best for eating fresh, smoothies, and baking',
      price: 7.49,
      unit: 'punnet',
      stockQuantity: 10,
      imageUrl: 'assets/images/blueberry.jpg',
    ),
    Product(
      id: 'p18',
      vendorId: 'u2',
      categoryId: 'cat5',
      name: 'Mint',
      urduName: 'پودینہ',
      description: 'Fresh pudina cut daily from trusted Punjab herb gardens and delivered to Kohat kitchens in perfect condition.',
      origin: 'Punjab',
      quality: 'Fresh',
      usage: 'Best for raita, chutneys, teas, and mojitos',
      price: 1.79,
      unit: 'bunch',
      stockQuantity: 25,
      imageUrl: 'assets/images/mint.jpg',
    ),
    Product(
      id: 'p19',
      vendorId: 'u2',
      categoryId: 'cat6',
      name: 'Organic Tomatoes',
      urduName: 'ٹماٹر',
      description: 'Chemical-free organic tomatoes sourced from trusted Sindh farms and delivered fresh across Kohat.',
      origin: 'Sindh',
      quality: 'Organic',
      usage: 'Best for curries, sauces, and salads',
      price: 4.49,
      unit: 'kg',
      stockQuantity: 18,
      imageUrl: 'assets/images/organictomato.jpg',
    ),
    Product(
      id: 'p20',
      vendorId: 'u2',
      categoryId: 'cat1',
      name: 'Watermelon',
      urduName: 'تربوز',
      description: 'Large juicy tarbooz sourced from trusted Rahim Yar Khan farms — the perfect summer refreshment delivered across Kohat.',
      origin: 'Rahim Yar Khan',
      quality: 'Premium',
      usage: 'Best for eating fresh, juices, and summer desserts',
      price: 8.99,
      unit: 'piece',
      stockQuantity: 5,
      imageUrl: 'assets/images/watermelon.jpg',
    ),
    Product(
      id: 'p21',
      vendorId: 'u2',
      categoryId: 'cat6',
      name: 'Organic Zucchini',
      urduName: 'توری',
      description: 'Tender chemical-free tori sourced from trusted Swat Valley farms and delivered fresh across Kohat.',
      origin: 'Swat Valley',
      quality: 'Organic',
      usage: 'Best for grilling, stir-frying, and soups',
      price: 2.99,
      unit: 'kg',
      stockQuantity: 22,
      imageUrl: 'assets/images/zucchini.jpg',
    ),
    Product(
      id: 'p22',
      vendorId: 'u2',
      categoryId: 'cat2',
      name: 'Garlic',
      urduName: 'لہسن',
      description: 'Pungent fresh lehsan sourced daily from trusted Punjab fields — a kitchen essential delivered across Kohat.',
      origin: 'Punjab',
      quality: 'Standard',
      usage: 'Best for curries, marinades, and stir-frying',
      price: 1.49,
      unit: 'piece',
      stockQuantity: 55,
      imageUrl: 'assets/images/garlic.jpg',
    ),
  ];

  // ─── Helper to convert CartItem to OrderItem ─────────────────────────────
  OrderItem _toOrderItem(CartItem cartItem) {
    return OrderItem(
      product: cartItem.product,
      quantity: cartItem.quantity,
      price: cartItem.product.price,
    );
  }

  // ─── Orders ───────────────────────────────────────────────────────────────
  late final List<Order> _orders = _buildInitialOrders();

  List<Order> _buildInitialOrders() {
    final address = Address(
      street: '123 Main St',
      city: 'Springfield',
      state: 'IL',
      postalCode: '62701',
    );
    final now = DateTime.now();

    return [
      Order(
        id: 'ord1',
        customerId: 'u3',
        vendorId: 'u2',
        deliveryPersonnelId: 'u4',
        customerName: 'Customer',
        phoneNumber: '03000000003',
        items: [
          _toOrderItem(CartItem(product: _products[0], quantity: 2)),
          _toOrderItem(CartItem(product: _products[2], quantity: 1)),
        ],
        deliveryAddress: address,
        deliveryArea: 'Peshawar',
        deliveryTime: 'Morning (8am - 10am)',
        deliveryNotes: 'Leave at the porch',
        status: OrderStatus.delivered,
        deliveryStatus: DeliveryStatus.delivered,
        createdAt: now.subtract(const Duration(days: 7)),
        total: 13.97,
      ),
      Order(
        id: 'ord2',
        customerId: 'u3',
        vendorId: 'u2',
        deliveryPersonnelId: 'u4',
        customerName: 'Customer',
        phoneNumber: '03000000003',
        items: [
          _toOrderItem(CartItem(product: _products[6], quantity: 1)),
          _toOrderItem(CartItem(product: _products[1], quantity: 2)),
        ],
        deliveryAddress: address,
        deliveryArea: 'Peshawar',
        deliveryTime: 'Afternoon (2pm - 4pm)',
        deliveryNotes: 'Ring the doorbell once',
        status: OrderStatus.outForDelivery,
        deliveryStatus: DeliveryStatus.pickedUp,
        createdAt: now.subtract(const Duration(days: 2)),
        total: 11.97,
      ),
      Order(
        id: 'ord3',
        customerId: 'u3',
        vendorId: 'u2',
        customerName: 'Customer',
        phoneNumber: '03000000003',
        items: [
          _toOrderItem(CartItem(product: _products[3], quantity: 1)),
          _toOrderItem(CartItem(product: _products[4], quantity: 2)),
        ],
        deliveryAddress: address,
        deliveryArea: 'Peshawar',
        deliveryTime: 'Evening (5pm - 7pm)',
        status: OrderStatus.preparing,
        createdAt: now.subtract(const Duration(days: 1)),
        total: 9.97,
      ),
      Order(
        id: 'ord4',
        customerId: 'u3',
        vendorId: 'u2',
        customerName: 'Customer',
        phoneNumber: '03000000003',
        items: [
          _toOrderItem(CartItem(product: _products[10], quantity: 3)),
        ],
        deliveryAddress: address,
        deliveryArea: 'Peshawar',
        deliveryTime: 'Midday (11am - 1pm)',
        status: OrderStatus.confirmed,
        createdAt: now.subtract(const Duration(hours: 18)),
        total: 5.97,
      ),
      Order(
        id: 'ord5',
        customerId: 'u3',
        vendorId: 'u2',
        customerName: 'Customer',
        phoneNumber: '03000000003',
        items: [
          _toOrderItem(CartItem(product: _products[14], quantity: 2)),
          _toOrderItem(CartItem(product: _products[7], quantity: 1)),
        ],
        deliveryAddress: address,
        deliveryArea: 'Peshawar',
        deliveryTime: 'Morning (8am - 10am)',
        status: OrderStatus.pending,
        createdAt: now.subtract(const Duration(hours: 3)),
        total: 7.97,
      ),
      Order(
        id: 'ord6',
        customerId: 'u3',
        vendorId: 'u2',
        deliveryPersonnelId: 'u4',
        customerName: 'Customer',
        phoneNumber: '03000000003',
        items: [
          _toOrderItem(CartItem(product: _products[16], quantity: 1)),
          _toOrderItem(CartItem(product: _products[8], quantity: 1)),
        ],
        deliveryAddress: address,
        deliveryArea: 'Peshawar',
        deliveryTime: 'Evening (5pm - 7pm)',
        status: OrderStatus.delivered,
        deliveryStatus: DeliveryStatus.delivered,
        createdAt: now.subtract(const Duration(days: 14)),
        total: 16.48,
      ),
      Order(
        id: 'ord7',
        customerId: 'u3',
        vendorId: 'u2',
        customerName: 'Customer',
        phoneNumber: '03000000003',
        items: [
          _toOrderItem(CartItem(product: _products[11], quantity: 4)),
          _toOrderItem(CartItem(product: _products[12], quantity: 1)),
        ],
        deliveryAddress: address,
        deliveryArea: 'Peshawar',
        deliveryTime: 'Midday (11am - 1pm)',
        status: OrderStatus.cancelled,
        createdAt: now.subtract(const Duration(days: 10)),
        total: 7.95,
      ),
      Order(
        id: 'ord8',
        customerId: 'u3',
        vendorId: 'u2',
        deliveryPersonnelId: 'u4',
        customerName: 'Customer',
        phoneNumber: '03000000003',
        items: [
          _toOrderItem(CartItem(product: _products[13], quantity: 2)),
          _toOrderItem(CartItem(product: _products[18], quantity: 1)),
        ],
        deliveryAddress: address,
        deliveryArea: 'Peshawar',
        deliveryTime: 'Afternoon (2pm - 4pm)',
        status: OrderStatus.delivered,
        deliveryStatus: DeliveryStatus.delivered,
        createdAt: now.subtract(const Duration(days: 5)),
        total: 11.07,
      ),
      Order(
        id: 'ord9',
        customerId: 'u3',
        vendorId: 'u2',
        customerName: 'Customer',
        phoneNumber: '03000000003',
        items: [
          _toOrderItem(CartItem(product: _products[15], quantity: 1)),
          _toOrderItem(CartItem(product: _products[17], quantity: 2)),
        ],
        deliveryAddress: address,
        deliveryArea: 'Peshawar',
        deliveryTime: 'Morning (8am - 10am)',
        status: OrderStatus.confirmed,
        createdAt: now.subtract(const Duration(hours: 30)),
        total: 7.57,
      ),
      Order(
        id: 'ord10',
        customerId: 'u3',
        vendorId: 'u2',
        customerName: 'Customer',
        phoneNumber: '03000000003',
        items: [
          _toOrderItem(CartItem(product: _products[19], quantity: 1)),
          _toOrderItem(CartItem(product: _products[5], quantity: 2)),
        ],
        deliveryAddress: address,
        deliveryArea: 'Peshawar',
        deliveryTime: 'Afternoon (2pm - 4pm)',
        status: OrderStatus.preparing,
        createdAt: now.subtract(const Duration(hours: 10)),
        total: 15.97,
      ),
    ];
  }

  // ─── Delivery Assignments ─────────────────────────────────────────────────
  final List<da.DeliveryAssignment> _assignments = [
    da.DeliveryAssignment(
      id: 'a1',
      orderId: 'ord2',
      personnelId: 'u4',
      status: da.DeliveryStatus.pickedUp,
      estimatedDeliveryTime: '30 min',
      assignedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    da.DeliveryAssignment(
      id: 'a2',
      orderId: 'ord1',
      personnelId: 'u4',
      status: da.DeliveryStatus.delivered,
      estimatedDeliveryTime: '45 min',
      assignedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    da.DeliveryAssignment(
      id: 'a3',
      orderId: 'ord8',
      personnelId: 'u4',
      status: da.DeliveryStatus.delivered,
      estimatedDeliveryTime: '50 min',
      assignedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // ─── Review storage ───────────────────────────────────────────────────────
  final List<Review> _reviews = [
    Review(
      id: 'r1',
      productId: 'p1',
      customerId: 'u3',
      customerName: 'Customer',
      rating: 5,
      comment: 'Great apples — sweet and crisp. Perfect for pies.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Review(
      id: 'r2',
      productId: 'p3',
      customerId: 'u3',
      customerName: 'Customer',
      rating: 4,
      comment: 'Tomatoes are juicy and fresh. Very tasty.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  // ─── ID counter ───────────────────────────────────────────────────────────
  int _nextUserId = 9;
  int _nextOrderId = 11;

  // ─── Public API ───────────────────────────────────────────────────────────

  Future<List<Product>> getProducts() =>
      Future.delayed(kMockDelay, () => List.unmodifiable(_products));

  Future<List<Category>> getCategories() =>
      Future.delayed(kMockDelay, () => List.unmodifiable(_categories));

  Future<List<AppUser>> getAllUsers() =>
      Future.delayed(kMockDelay, () => List.unmodifiable(_users));

  Future<List<Order>> getOrdersForCustomer(String customerId) =>
      Future.delayed(kMockDelay,
          () => _orders.where((o) => o.customerId == customerId).toList());

  Future<List<Order>> getOrdersForVendor(String vendorId) =>
      Future.delayed(kMockDelay,
          () => _orders.where((o) => o.vendorId == vendorId).toList());

  Future<List<Order>> getOrdersForDeliveryPersonnel(String personnelId) =>
      Future.delayed(
          kMockDelay,
          () => _orders
              .where((o) => o.deliveryPersonnelId == personnelId)
              .toList());

  Future<List<Order>> getAllOrders() =>
      Future.delayed(kMockDelay, () => List.unmodifiable(_orders));

  Future<List<Review>> getReviewsForProduct(String productId) =>
      Future.delayed(
        kMockDelay,
        () => _reviews
            .where((review) => review.productId == productId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );

  Future<Review?> getReviewForProductByCustomer(
          String productId, String customerId) =>
      Future.delayed(kMockDelay, () {
        try {
          return _reviews.firstWhere((review) =>
              review.productId == productId &&
              review.customerId == customerId);
        } catch (_) {
          return null;
        }
      });

  Future<List<Review>> getReviewsForVendor(String vendorId) =>
      Future.delayed(kMockDelay, () {
        final vendorProductIds = _products
            .where((product) => product.vendorId == vendorId)
            .map((product) => product.id)
            .toSet();
        return _reviews
            .where((review) => vendorProductIds.contains(review.productId))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });

  Future<void> addReview(Review review) => Future.delayed(kMockDelay, () {
        final existingIndex = _reviews.indexWhere((existing) =>
            existing.productId == review.productId &&
            existing.customerId == review.customerId);
        if (existingIndex != -1) {
          throw Exception('Duplicate review not allowed');
        }
        _reviews.add(review);
      });

  Future<AppUser?> getUserByCredentials(String email, String password) =>
      Future.delayed(kMockDelay, () {
        final storedPassword = _passwords[email];
        if (storedPassword == null || storedPassword != password) return null;
        try {
          return _users.firstWhere((u) => u.email == email);
        } catch (_) {
          return null;
        }
      });

  Future<AppUser?> getUserById(String id) =>
      Future.delayed(kMockDelay, () {
        try {
          return _users.firstWhere((user) => user.id == id);
        } catch (_) {
          return null;
        }
      });

  Future<void> updateOrder(Order order) => Future.delayed(kMockDelay, () {
        final idx = _orders.indexWhere((o) => o.id == order.id);
        if (idx != -1) _orders[idx] = order;
      });

  Future<AppUser> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String region,
    required String area,
    String phoneNumber = '',
  }) {
    return Future.delayed(kMockDelay, () {
      final id = 'u${_nextUserId++}';
      final user = AppUser(
        id: id,
        name: name,
        email: email,
        phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
        role: role,
        avatarUrl: 'https://i.pravatar.cc/150?img=$_nextUserId',
        region: region,
        area: area,
      );
      _users.add(user);
      _passwords[email] = password;
      return user;
    });
  }

  Future<void> updateUser(AppUser user) => Future.delayed(kMockDelay, () {
        final idx = _users.indexWhere((u) => u.id == user.id);
        if (idx != -1) _users[idx] = user;
      });

  Future<void> updateProduct(Product product) =>
      Future.delayed(kMockDelay, () {
        final idx = _products.indexWhere((p) => p.id == product.id);
        if (idx != -1) _products[idx] = product;
      });

  Future<void> deleteProduct(String id) => Future.delayed(kMockDelay, () {
        _products.removeWhere((p) => p.id == id);
      });

  Future<Order> createOrder(
    List<CartItem> items,
    Address address,
    String customerId,
    String customerName,
    String phoneNumber,
    String city,
    String deliveryTimeSlot, {
    String? deliveryNotes,
    double? latitude,
    double? longitude,
  }) {
    return Future.delayed(kMockDelay, () {
      final total = items.fold<double>(0.0, (sum, e) => sum + e.lineTotal);
      
      // ✅ Convert CartItems to OrderItems
      final orderItems = items.map((item) => _toOrderItem(item)).toList();
      
      final order = Order(
        id: 'ord${_nextOrderId++}',
        customerId: customerId,
        vendorId: 'u2',
        customerName: customerName,
        phoneNumber: phoneNumber,
        items: orderItems,
        deliveryAddress: address,
        deliveryArea: city,
        deliveryTime: deliveryTimeSlot,
        deliveryNotes: deliveryNotes,
        latitude: latitude,
        longitude: longitude,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        total: total,
      );
      _orders.add(order);
      return order;
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) =>
      Future.delayed(kMockDelay, () {
        final idx = _orders.indexWhere((o) => o.id == orderId);
        if (idx != -1) {
          _orders[idx] = _orders[idx].copyWith(status: status);
        }
      });

  Future<void> toggleUserActive(String userId) =>
      Future.delayed(kMockDelay, () {
        final idx = _users.indexWhere((u) => u.id == userId);
        if (idx != -1) {
          _users[idx] = _users[idx].copyWith(isActive: !_users[idx].isActive);
        }
      });

  Future<void> toggleProductActive(String id) =>
      Future.delayed(kMockDelay, () {
        final idx = _products.indexWhere((p) => p.id == id);
        if (idx != -1) {
          _products[idx] = _products[idx].copyWith(isActive: !_products[idx].isActive);
        }
      });

  Future<List<da.DeliveryAssignment>> getAssignmentsForPersonnel(
          String personnelId) =>
      Future.delayed(
          kMockDelay,
          () => _assignments
              .where((a) => a.personnelId == personnelId)
              .toList());

  Future<void> addProduct(Product product) =>
      Future.delayed(kMockDelay, () {
        _products.add(product);
      });
}