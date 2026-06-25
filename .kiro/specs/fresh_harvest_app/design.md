# Design Document — Fresh Harvest

## Overview

Fresh Harvest is a Flutter application targeting Android, iOS, and Web. It simulates a complete fruit and vegetable delivery marketplace with four user roles (Customer, Vendor, Delivery Personnel, Admin) backed entirely by in-memory mock data. There is no backend, no Firebase, and no payment gateway.

The design follows clean architecture principles with distinct layers: **models**, **services**, **providers**, **widgets**, and **screens**. State is managed exclusively with the `provider` package. The UI uses Material 3 with a green-and-white theme and adapts responsively to phone, tablet, and desktop viewports.

---

## Architecture

### Layer Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        Screens (UI)                         │
│   Splash │ Auth │ Customer │ Vendor │ Delivery │ Admin      │
├─────────────────────────────────────────────────────────────┤
│                    Shared Widgets                           │
│  FreshHarvestAppBar │ BottomNavBar │ ProductCard │ etc.     │
├─────────────────────────────────────────────────────────────┤
│                      Providers                              │
│  AuthProvider │ ProductProvider │ CartProvider │            │
│  OrderProvider │ UserProvider                               │
├─────────────────────────────────────────────────────────────┤
│                     Services                                │
│                   MockDataService                           │
├─────────────────────────────────────────────────────────────┤
│                      Models                                 │
│  AppUser │ Product │ Category │ Order │ CartItem │ etc.     │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. `MockDataService` holds all static data and exposes `Future`-returning methods with a simulated 300–500 ms delay.
2. Provider classes call `MockDataService`, hold the resulting state, and notify listeners.
3. Screens and widgets use `context.watch<T>()` / `context.read<T>()` to consume Provider state.
4. Navigation is name-based; all routes are registered in `main.dart`.

---

## Components and Interfaces

### Folder Structure

```
lib/
├── main.dart                          # App entry, route table, MultiProvider setup
├── config/
│   ├── app_theme.dart                 # Material 3 ThemeData
│   ├── app_routes.dart                # Named route constants
│   └── app_constants.dart             # Colors, sizes, durations
├── models/
│   ├── app_user.dart
│   ├── product.dart
│   ├── category.dart
│   ├── cart_item.dart
│   ├── order.dart
│   └── delivery_assignment.dart
├── services/
│   └── mock_data_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── cart_provider.dart
│   ├── order_provider.dart
│   └── user_provider.dart
├── widgets/
│   ├── fresh_harvest_app_bar.dart
│   ├── bottom_nav_bar.dart
│   ├── product_card.dart
│   ├── category_card.dart
│   ├── search_bar_widget.dart
│   ├── order_card.dart
│   ├── stats_card.dart
│   └── skeleton_loader.dart
└── screens/
    ├── splash/
    │   └── splash_screen.dart
    ├── auth/
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   └── forgot_password_screen.dart
    ├── home/
    │   └── home_screen.dart
    ├── categories/
    │   ├── categories_screen.dart
    │   └── category_products_screen.dart
    ├── product/
    │   └── product_details_screen.dart
    ├── cart/
    │   └── cart_screen.dart
    ├── checkout/
    │   ├── checkout_screen.dart
    │   └── order_confirmation_screen.dart
    ├── orders/
    │   ├── order_history_screen.dart
    │   ├── order_details_screen.dart
    │   └── order_tracking_screen.dart
    ├── profile/
    │   └── profile_screen.dart
    ├── vendor/
    │   ├── vendor_dashboard_screen.dart
    │   ├── vendor_product_list_screen.dart
    │   ├── vendor_add_edit_product_screen.dart
    │   ├── vendor_order_management_screen.dart
    │   └── vendor_sales_report_screen.dart
    ├── delivery/
    │   ├── assigned_orders_screen.dart
    │   ├── delivery_tracking_screen.dart
    │   └── delivery_history_screen.dart
    └── admin/
        ├── admin_dashboard_screen.dart
        ├── admin_user_management_screen.dart
        ├── admin_product_management_screen.dart
        ├── admin_order_management_screen.dart
        └── admin_analytics_screen.dart
```

### Provider Interfaces

```dart
// AuthProvider
class AuthProvider extends ChangeNotifier {
  AppUser? currentUser;
  bool get isAuthenticated;
  UserRole? get currentRole;
  Future<bool> login(String email, String password);
  Future<bool> register(String name, String email, String password, UserRole role);
  Future<void> logout();
}

// ProductProvider
class ProductProvider extends ChangeNotifier {
  List<Product> products;
  List<Product> filteredProducts;
  bool isLoading;
  Future<void> loadProducts();
  void filterByCategory(String categoryId);
  void search(String query);
  void applyFilters({double? minPrice, double? maxPrice, String? sortOrder});
  Future<void> addProduct(Product p);
  Future<void> updateProduct(Product p);
  Future<void> deleteProduct(String id);
  Future<void> toggleProductActive(String id);
}

// CartProvider
class CartProvider extends ChangeNotifier {
  List<CartItem> items;
  double get subtotal;
  double get deliveryFee;
  double get grandTotal;
  void addItem(Product p);
  void updateQuantity(String productId, int qty);
  void removeItem(String productId);
  void clearCart();
}

// OrderProvider
class OrderProvider extends ChangeNotifier {
  List<Order> orders;
  bool isLoading;
  Future<void> loadOrders();
  Future<Order> placeOrder(List<CartItem> items, Address address);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}

// UserProvider
class UserProvider extends ChangeNotifier {
  List<AppUser> users;
  bool isLoading;
  Future<void> loadUsers();
  Future<void> toggleUserActive(String userId);
  List<AppUser> search(String query);
}
```

### MockDataService Interface

```dart
class MockDataService {
  // Simulates network latency
  static const _delay = Duration(milliseconds: 400);

  Future<List<Product>> getProducts();
  Future<List<Category>> getCategories();
  Future<List<Order>> getOrdersForCustomer(String customerId);
  Future<List<Order>> getOrdersForVendor(String vendorId);
  Future<List<Order>> getOrdersForDeliveryPersonnel(String personnelId);
  Future<List<Order>> getAllOrders();
  Future<AppUser?> getUserByCredentials(String email, String password);
  Future<AppUser> createUser(String name, String email, String password, UserRole role);
  Future<void> updateUser(AppUser user);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<Order> createOrder(List<CartItem> items, Address address, String customerId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}
```

---

## Data Models

```dart
// Enums
enum UserRole { customer, vendor, deliveryPersonnel, admin }
enum OrderStatus { pending, confirmed, preparing, outForDelivery, delivered, cancelled }
enum DeliveryStatus { assigned, pickedUp, enRoute, delivered }

// AppUser
class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  bool isActive;
  final String avatarUrl;
}

// Category
class Category {
  final String id;
  final String name;
  final String iconAsset;
  final int itemCount;
}

// Product
class Product {
  final String id;
  final String vendorId;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final String unit;       // e.g. "kg", "piece", "bunch"
  int stockQuantity;
  bool isActive;
  final String imageUrl;
}

// CartItem
class CartItem {
  final Product product;
  int quantity;
  double get lineTotal => product.price * quantity;
}

// Address
class Address {
  final String street;
  final String city;
  final String state;
  final String postalCode;
}

// Order
class Order {
  final String id;
  final String customerId;
  final String vendorId;
  String? deliveryPersonnelId;
  final List<CartItem> items;
  final Address deliveryAddress;
  OrderStatus status;
  DeliveryStatus? deliveryStatus;
  final DateTime createdAt;
  final double total;
}

// DeliveryAssignment
class DeliveryAssignment {
  final String orderId;
  final String personnelId;
  DeliveryStatus status;
  final String estimatedDeliveryTime; // e.g. "45 min"
}
```

---

## Routing Strategy

All routes are registered as named routes in `main.dart`. Post-login navigation is driven by `UserRole`.

```dart
// app_routes.dart — route name constants
class AppRoutes {
  static const splash        = '/';
  static const login         = '/login';
  static const register      = '/register';
  static const forgotPassword = '/forgot-password';

  // Customer
  static const customerHome  = '/customer/home';
  static const categories    = '/customer/categories';
  static const categoryProducts = '/customer/categories/products';
  static const productDetails = '/customer/product/:id';
  static const cart          = '/customer/cart';
  static const checkout      = '/customer/checkout';
  static const orderConfirmation = '/customer/order-confirmation';
  static const orderHistory  = '/customer/orders';
  static const orderDetails  = '/customer/orders/:id';
  static const orderTracking = '/customer/orders/:id/tracking';
  static const profile       = '/customer/profile';

  // Vendor
  static const vendorDashboard  = '/vendor/dashboard';
  static const vendorProducts   = '/vendor/products';
  static const vendorAddProduct = '/vendor/products/add';
  static const vendorEditProduct = '/vendor/products/edit/:id';
  static const vendorOrders     = '/vendor/orders';
  static const vendorReports    = '/vendor/reports';

  // Delivery
  static const deliveryAssigned = '/delivery/assigned';
  static const deliveryTracking = '/delivery/tracking/:id';
  static const deliveryHistory  = '/delivery/history';

  // Admin
  static const adminDashboard = '/admin/dashboard';
  static const adminUsers     = '/admin/users';
  static const adminProducts  = '/admin/products';
  static const adminOrders    = '/admin/orders';
  static const adminAnalytics = '/admin/analytics';
}
```

### Role-Based Post-Login Navigation

| Role | Initial Route |
|------|---------------|
| `customer` | `/customer/home` |
| `vendor` | `/vendor/dashboard` |
| `deliveryPersonnel` | `/delivery/assigned` |
| `admin` | `/admin/dashboard` |

---

## Theme System

```dart
// app_theme.dart
class AppTheme {
  static const seedColor = Color(0xFF2E7D32);   // dark green
  static const onPrimary = Colors.white;
  static const background = Colors.white;

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seedColor,
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: seedColor,
      foregroundColor: onPrimary,
      elevation: 0,
    ),
    // typography uses default M3 text theme
  );
}
```

### Responsive Breakpoints

| Breakpoint | Width | Grid Columns |
|------------|-------|--------------|
| Mobile     | < 600 dp | 2 |
| Tablet     | 600–1024 dp | 3 |
| Desktop/Web | ≥ 1024 dp | 4 |

Implemented via `LayoutBuilder` in product grid widgets, using a helper:

```dart
int gridColumns(double width) {
  if (width >= 1024) return 4;
  if (width >= 600)  return 3;
  return 2;
}
```

---

## Widget Hierarchy

```
MaterialApp
└── MultiProvider (AuthProvider, ProductProvider, CartProvider, OrderProvider, UserProvider)
    ├── SplashScreen
    ├── LoginScreen
    │   └── (demo role buttons)
    ├── RegisterScreen
    ├── ForgotPasswordScreen
    │
    ├── [Customer Shell]
    │   └── BottomNavBar (Home, Categories, Cart, Orders, Profile)
    │       ├── HomeScreen
    │       │   ├── FreshHarvestAppBar
    │       │   ├── SearchBarWidget
    │       │   ├── BannerCarousel
    │       │   ├── CategoryRow (CategoryCard ×N)
    │       │   └── ProductGrid (ProductCard ×N)
    │       ├── CategoriesScreen → CategoryProductsScreen
    │       ├── CartScreen (CartItemRow ×N)
    │       ├── OrderHistoryScreen (OrderCard ×N) → OrderDetailsScreen → OrderTrackingScreen
    │       └── ProfileScreen
    │
    ├── [Vendor Shell]
    │   └── BottomNavBar (Dashboard, Products, Orders, Reports)
    │       ├── VendorDashboardScreen (StatsCard ×4)
    │       ├── VendorProductListScreen → VendorAddEditProductScreen
    │       ├── VendorOrderManagementScreen
    │       └── VendorSalesReportScreen (charts)
    │
    ├── [Delivery Shell]
    │   └── BottomNavBar (Assigned, Tracking, History)
    │       ├── AssignedOrdersScreen (OrderCard ×N)
    │       ├── DeliveryTrackingScreen (mock map placeholder)
    │       └── DeliveryHistoryScreen (OrderCard ×N)
    │
    └── [Admin Shell]
        └── BottomNavBar (Dashboard, Users, Products, Orders, Analytics)
            ├── AdminDashboardScreen (StatsCard ×4)
            ├── AdminUserManagementScreen
            ├── AdminProductManagementScreen
            ├── AdminOrderManagementScreen
            └── AdminAnalyticsScreen (charts)
```

---

## Charts Strategy

Since there is no backend, charts use the `fl_chart` Flutter package with hard-coded mock time-series arrays. Key charts:

| Screen | Chart Type | Data |
|--------|-----------|------|
| Vendor Sales Report | Bar chart | Revenue per day (last 7 days) |
| Vendor Sales Report | Pie chart | Revenue by category |
| Admin Analytics | Line chart | Daily orders (last 30 days) |
| Admin Analytics | Bar chart | Revenue by category |
| Admin Analytics | Data table | Top 5 products |

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Valid credentials always authenticate successfully

*For any* email/password pair that exists in MockDataService's user list, calling `AuthProvider.login(email, password)` SHALL return `true` and set `currentUser` to the matching `AppUser`.

**Validates: Requirements 1.3**

---

### Property 2: Invalid credentials always fail authentication

*For any* email/password pair where the email does not exist in MockDataService, or where the password does not match, calling `AuthProvider.login(email, password)` SHALL return `false` and leave `currentUser` as `null`.

**Validates: Requirements 1.4**

---

### Property 3: User registration round-trip

*For any* valid (name, email, password, role) tuple where email is not already registered, calling `AuthProvider.register(...)` SHALL create a user such that a subsequent `getUserByCredentials(email, password)` returns an `AppUser` with matching email and role.

**Validates: Requirements 1.6**

---

### Property 4: Registration validation rejects invalid inputs

*For any* registration form submission where at least one required field is empty or the email is malformed or the password is fewer than 6 characters, the validation function SHALL return a non-empty list of field-level error messages.

**Validates: Requirements 1.7**

---

### Property 5: Product search filter correctness

*For any* non-empty search query string `q`, every product returned by `ProductProvider.search(q)` SHALL have a name that contains `q` (case-insensitive). No product whose name does not contain `q` SHALL appear in the results.

**Validates: Requirements 2.2**

---

### Property 6: Category filter correctness

*For any* category ID `c`, every product returned by `ProductProvider.filterByCategory(c)` SHALL have `categoryId == c`. No product with a different category ID SHALL appear in the results.

**Validates: Requirements 2.3, 13.1**

---

### Property 7: Combined filter constraints are all satisfied

*For any* combination of `minPrice`, `maxPrice`, and `sortOrder` applied via `ProductProvider.applyFilters(...)`, every returned product SHALL have `price >= minPrice` and `price <= maxPrice`. When `sortOrder == 'asc'`, products SHALL be ordered by ascending price; when `sortOrder == 'desc'`, by descending price.

**Validates: Requirements 2.7**

---

### Property 8: Cart add creates entry with quantity 1

*For any* `Product p` not already in `CartProvider.items`, calling `CartProvider.addItem(p)` SHALL result in `CartProvider.items` containing a `CartItem` with `product.id == p.id` and `quantity == 1`.

**Validates: Requirements 3.1**

---

### Property 9: Cart total is always the sum of line totals

*For any* cart state with N items, `CartProvider.subtotal` SHALL equal the sum of `item.lineTotal` for all items in `CartProvider.items`.

**Validates: Requirements 3.2, 3.5**

---

### Property 10: Decreasing quantity to zero removes the item

*For any* `CartItem` in the cart with `quantity == 1`, calling `CartProvider.updateQuantity(productId, 0)` SHALL result in no `CartItem` with that `productId` remaining in `CartProvider.items`.

**Validates: Requirements 3.3**

---

### Property 11: Successful checkout clears the cart and creates a pending order

*For any* non-empty cart and valid delivery address, calling `OrderProvider.placeOrder(items, address)` SHALL (a) create an `Order` with `status == OrderStatus.pending` containing the same items, AND (b) result in `CartProvider.items` being empty after `CartProvider.clearCart()` is invoked.

**Validates: Requirements 4.2, 4.5**

---

### Property 12: Checkout validation rejects incomplete addresses

*For any* `Address` where at least one of `street`, `city`, `state`, or `postalCode` is empty, the checkout form validator SHALL return at least one field-level error and SHALL NOT invoke `OrderProvider.placeOrder`.

**Validates: Requirements 4.3**

---

### Property 13: Order history is sorted most-recent-first

*For any* list of orders returned by `OrderProvider.loadOrders()` for a given customer, the resulting list displayed SHALL be ordered such that `orders[i].createdAt >= orders[i+1].createdAt` for all valid `i`.

**Validates: Requirements 5.1**

---

### Property 14: Product creation round-trip

*For any* valid `Product` object submitted via `ProductProvider.addProduct(p)`, a subsequent call to `MockDataService.getProducts()` SHALL return a list containing a product with the same `id`, `name`, `categoryId`, `price`, and `vendorId`.

**Validates: Requirements 7.4**

---

### Property 15: Order status update is persisted

*For any* `Order` with id `oid` and any valid `OrderStatus` value `s`, calling `OrderProvider.updateOrderStatus(oid, s)` SHALL result in `MockDataService`'s order record for `oid` having `status == s`.

**Validates: Requirements 8.3, 10.3, 13.4**

---

### Property 16: User active-status toggle is idempotent over two applications

*For any* `AppUser` with initial `isActive` value `v`, calling `UserProvider.toggleUserActive(userId)` twice in succession SHALL result in the user's `isActive` being restored to `v`.

**Validates: Requirements 12.3**

---

### Property 17: User search filter correctness

*For any* search query string `q`, every `AppUser` returned by `UserProvider.search(q)` SHALL have a `name` or `email` that contains `q` (case-insensitive).

**Validates: Requirements 12.4**

---

### Property 18: Responsive grid column count

*For any* viewport width `w`, the `gridColumns(w)` helper SHALL return 2 when `w < 600`, 3 when `600 <= w < 1024`, and 4 when `w >= 1024`.

**Validates: Requirements 15.4**

---

### Property 19: MockDataService simulated delay is within bounds

*For any* `MockDataService` method call, the elapsed time before the returned `Future` resolves SHALL be between 300 ms and 500 ms inclusive.

**Validates: Requirements 16.4**

---

## Error Handling

| Scenario | Handling Strategy |
|----------|------------------|
| Login with invalid credentials | Show `SnackBar` or inline field error |
| Empty cart at checkout | Disable Checkout button; show empty-state |
| Form field validation failure | Show `TextFormField` error text per field |
| Image load failure | Replace with `Assets.images.placeholder` via `errorBuilder` |
| MockDataService throws | Provider catches exception, sets error state, Screen shows error widget |
| Unauthorized route access | `AuthGuard` middleware in `onGenerateRoute` redirects to `/login` |

---

## Testing Strategy

### Overview

This app uses a dual testing approach:
- **Unit/example tests** for specific behavior, edge cases, and validation logic
- **Property-based tests** for universal correctness properties defined above

Property-based testing uses the [`dart_test` framework](https://pub.dev/packages/test) combined with hand-rolled generators (since `fast_check` for Dart is not available; Dart's equivalent is manual test-data generation with randomization in `for` loops or using the `proptest` / `faker` packages). Each property test runs a minimum of **100 iterations**.

### Test File Map

```
test/
├── providers/
│   ├── auth_provider_test.dart          # Properties 1, 2, 3, 4
│   ├── product_provider_test.dart       # Properties 5, 6, 7, 14
│   ├── cart_provider_test.dart          # Properties 8, 9, 10
│   ├── order_provider_test.dart         # Properties 11, 12, 13, 15
│   └── user_provider_test.dart          # Properties 16, 17
├── utils/
│   ├── responsive_test.dart             # Property 18
│   └── mock_data_service_test.dart      # Property 19
└── widgets/
    ├── login_screen_test.dart           # Examples: 1.2, 1.11
    └── loading_skeleton_test.dart       # Example: 15.3
```

### Property Test Tag Format

Each property test is annotated with:

```dart
// Feature: fresh_harvest_app, Property N: <property_text>
```

### Unit Test Focus Areas

- Form validators (address, product, registration)
- `gridColumns()` helper function
- `CartItem.lineTotal` getter
- Role-based route selection after login
- Empty-state widget rendering
