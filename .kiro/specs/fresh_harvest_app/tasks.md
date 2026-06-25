# Implementation Plan: Fresh Harvest

## Overview

Convert the Fresh Harvest design into incremental Flutter/Dart coding steps. Each task builds on the previous one, starting with the foundation (models and mock data), progressing through providers and shared widgets, then building screens role-by-role, and finishing with routing, theming, and wiring. All code uses null safety, the `provider` package for state, and Material 3 design.

---

## Tasks

- [ ] 1. Project foundation — dependencies, config, and theme
  - Add `provider: ^6.1.2`, `fl_chart: ^0.68.0` to `pubspec.yaml` under `dependencies`
  - Create `lib/config/app_constants.dart` with color constants (`kPrimaryColor = Color(0xFF2E7D32)`), breakpoints (600, 1024), and mock delay duration (400 ms)
  - Create `lib/config/app_theme.dart` implementing `AppTheme.lightTheme` as a Material 3 `ThemeData` seeded with `kPrimaryColor`
  - Create `lib/config/app_routes.dart` defining all route name string constants from the design
  - _Requirements: 15.1, 15.2, 16.1_

- [ ] 2. Data models
  - [ ] 2.1 Create all model files under `lib/models/`
    - `app_user.dart` — `AppUser` class + `UserRole` enum
    - `category.dart` — `Category` class
    - `product.dart` — `Product` class
    - `cart_item.dart` — `CartItem` class with `lineTotal` getter
    - `order.dart` — `Order` class + `OrderStatus` enum + `Address` class
    - `delivery_assignment.dart` — `DeliveryAssignment` class + `DeliveryStatus` enum
    - All fields use non-nullable types with required named constructor parameters
    - _Requirements: 3.5, 4.4, 5.2, 8.2, 10.2_

  - [ ]* 2.2 Write unit tests for model getters and constructors
    - Test `CartItem.lineTotal` returns `product.price * quantity`
    - Test `CartItem` with quantity 0 has `lineTotal == 0.0`
    - _Requirements: 3.5_

- [ ] 3. MockDataService
  - [ ] 3.1 Create `lib/services/mock_data_service.dart`
    - Implement static in-memory lists for users (one per role), categories (6), products (20+), orders (10+), and delivery assignments
    - Each public method returns a `Future` that delays 400 ms (`Future.delayed`) before returning data
    - Implement: `getProducts()`, `getCategories()`, `getOrdersForCustomer()`, `getOrdersForVendor()`, `getOrdersForDeliveryPersonnel()`, `getAllOrders()`, `getUserByCredentials()`, `createUser()`, `updateUser()`, `updateProduct()`, `deleteProduct()`, `createOrder()`, `updateOrderStatus()`, `toggleUserActive()`, `toggleProductActive()`
    - _Requirements: 16.4, 1.3, 7.4_

  - [ ]* 3.2 Write property test for MockDataService simulated delay
    - **Property 19: MockDataService simulated delay is within bounds**
    - **Validates: Requirements 16.4**
    - For 100 iterations, call each major MockDataService method and assert elapsed time is ≥300 ms and ≤500 ms
    - _Requirements: 16.4_

- [ ] 4. Providers
  - [ ] 4.1 Create `lib/providers/auth_provider.dart`
    - `AuthProvider extends ChangeNotifier` with `currentUser`, `isAuthenticated`, `currentRole`
    - Implement `login(email, password)` → calls MockDataService, notifies, returns bool
    - Implement `register(name, email, password, role)` → calls MockDataService, returns bool
    - Implement `logout()` → clears `currentUser`, notifies
    - _Requirements: 1.3, 1.4, 1.6, 6.4_

  - [ ]* 4.2 Write property tests for AuthProvider
    - **Property 1: Valid credentials always authenticate successfully**
    - **Validates: Requirements 1.3**
    - **Property 2: Invalid credentials always fail authentication**
    - **Validates: Requirements 1.4**
    - **Property 3: User registration round-trip**
    - **Validates: Requirements 1.6**
    - **Property 4: Registration validation rejects invalid inputs**
    - **Validates: Requirements 1.7**
    - Run each property for 100 iterations using random credential combinations
    - _Requirements: 1.3, 1.4, 1.6, 1.7_

  - [ ] 4.3 Create `lib/providers/product_provider.dart`
    - `ProductProvider extends ChangeNotifier` with `products`, `filteredProducts`, `isLoading`
    - Implement `loadProducts()`, `filterByCategory(categoryId)`, `search(query)`, `applyFilters(...)`, `addProduct(p)`, `updateProduct(p)`, `deleteProduct(id)`, `toggleProductActive(id)`
    - Search and filter operate on the in-memory `products` list without re-calling MockDataService
    - _Requirements: 2.2, 2.3, 2.7, 7.4, 7.7, 7.8, 7.10_

  - [ ]* 4.4 Write property tests for ProductProvider
    - **Property 5: Product search filter correctness**
    - **Validates: Requirements 2.2**
    - **Property 6: Category filter correctness**
    - **Validates: Requirements 2.3**
    - **Property 7: Combined filter constraints are all satisfied**
    - **Validates: Requirements 2.7**
    - **Property 14: Product creation round-trip**
    - **Validates: Requirements 7.4**
    - Run each property for 100 iterations with randomly generated queries, categories, and product data
    - _Requirements: 2.2, 2.3, 2.7, 7.4_

  - [ ] 4.5 Create `lib/providers/cart_provider.dart`
    - `CartProvider extends ChangeNotifier` with `items`, `subtotal`, `deliveryFee`, `grandTotal`
    - Implement `addItem(p)`, `updateQuantity(productId, qty)` (removes item when qty=0), `removeItem(productId)`, `clearCart()`
    - `subtotal` computed as sum of all `item.lineTotal`
    - `deliveryFee` fixed at 2.99; `grandTotal = subtotal + deliveryFee`
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 4.5_

  - [ ]* 4.6 Write property tests for CartProvider
    - **Property 8: Cart add creates entry with quantity 1**
    - **Validates: Requirements 3.1**
    - **Property 9: Cart total is always the sum of line totals**
    - **Validates: Requirements 3.2, 3.5**
    - **Property 10: Decreasing quantity to zero removes the item**
    - **Validates: Requirements 3.3**
    - Run each property for 100 iterations with randomly generated product data
    - _Requirements: 3.1, 3.2, 3.3, 3.5_

  - [ ] 4.7 Create `lib/providers/order_provider.dart`
    - `OrderProvider extends ChangeNotifier` with `orders`, `isLoading`
    - Implement `loadOrders()`, `placeOrder(items, address)` (calls MockDataService, then notifies), `updateOrderStatus(orderId, status)`
    - `loadOrders()` returns orders sorted descending by `createdAt`
    - _Requirements: 4.2, 5.1, 8.3, 10.3, 13.4_

  - [ ]* 4.8 Write property tests for OrderProvider
    - **Property 11: Successful checkout clears the cart and creates a pending order**
    - **Validates: Requirements 4.2, 4.5**
    - **Property 12: Checkout validation rejects incomplete addresses**
    - **Validates: Requirements 4.3**
    - **Property 13: Order history is sorted most-recent-first**
    - **Validates: Requirements 5.1**
    - **Property 15: Order status update is persisted**
    - **Validates: Requirements 8.3, 10.3, 13.4**
    - Run each property for 100 iterations
    - _Requirements: 4.2, 4.3, 4.5, 5.1, 8.3_

  - [ ] 4.9 Create `lib/providers/user_provider.dart`
    - `UserProvider extends ChangeNotifier` with `users`, `isLoading`
    - Implement `loadUsers()`, `toggleUserActive(userId)`, `search(query)` (filters by name or email, case-insensitive)
    - _Requirements: 12.1, 12.3, 12.4_

  - [ ]* 4.10 Write property tests for UserProvider
    - **Property 16: User active-status toggle is idempotent over two applications**
    - **Validates: Requirements 12.3**
    - **Property 17: User search filter correctness**
    - **Validates: Requirements 12.4**
    - Run each property for 100 iterations
    - _Requirements: 12.3, 12.4_

- [ ] 5. Checkpoint — Ensure all provider and service tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Shared widgets
  - [ ] 6.1 Create `lib/widgets/fresh_harvest_app_bar.dart`
    - `FreshHarvestAppBar` implements `PreferredSizeWidget`
    - Accepts `title`, optional `showBack` bool, optional `actions` list
    - Uses `kPrimaryColor` background and white foreground
    - _Requirements: 15.5_

  - [ ] 6.2 Create `lib/widgets/bottom_nav_bar.dart`
    - `FreshHarvestBottomNavBar` takes `UserRole role`, `int currentIndex`, `ValueChanged<int> onTap`
    - Renders role-specific tab items: Customer (5 tabs), Vendor (4), Delivery (3), Admin (5)
    - _Requirements: 14.3_

  - [ ] 6.3 Create `lib/widgets/product_card.dart`
    - `ProductCard` shows product image, name, price/unit, and an Add-to-Cart icon button
    - Uses `errorBuilder` on `Image.network` to show a placeholder on load failure
    - _Requirements: 2.5, 15.6_

  - [ ] 6.4 Create `lib/widgets/category_card.dart`
    - `CategoryCard` shows category icon and name
    - _Requirements: 2.4_

  - [ ] 6.5 Create `lib/widgets/search_bar_widget.dart`
    - `SearchBarWidget` wraps a `TextField` with a search icon, debounced 300 ms, calling an `onChanged` callback
    - _Requirements: 2.2, 12.4_

  - [ ] 6.6 Create `lib/widgets/order_card.dart`
    - `OrderCard` shows order ID, date, total, item count, and an `OrderStatus` chip with colour-coding
    - _Requirements: 5.1, 10.1_

  - [ ] 6.7 Create `lib/widgets/stats_card.dart`
    - `StatsCard` shows a label, large numeric value, and an icon; used on all Dashboards
    - _Requirements: 7.1, 11.1_

  - [ ] 6.8 Create `lib/widgets/skeleton_loader.dart`
    - `SkeletonLoader` renders animated shimmer placeholder boxes matching the product grid layout
    - Displayed whenever `isLoading == true` in ProductProvider
    - _Requirements: 15.3_

- [ ] 7. Authentication screens
  - [ ] 7.1 Create `lib/screens/splash/splash_screen.dart`
    - Show logo, app name "Fresh Harvest", and tagline for 2 seconds using `Future.delayed`
    - Navigate to `/login` on completion
    - _Requirements: 1.1, 1.2_

  - [ ] 7.2 Create `lib/screens/auth/login_screen.dart`
    - Email + password `TextFormField`s with validation
    - "Login" button calls `AuthProvider.login()` and navigates to role-based route on success, shows inline `SnackBar` error on failure
    - Four demo-login shortcut buttons (one per Role) that pre-fill credentials and trigger login
    - Links to Register and Forgot Password screens
    - _Requirements: 1.3, 1.4, 1.5, 1.8, 1.11, 14.2_

  - [ ] 7.3 Create `lib/screens/auth/register_screen.dart`
    - Name, email, password, confirm-password fields + role dropdown
    - Field-level `validator` callbacks for all fields
    - On success → navigate to `/login`; on validation failure → display inline errors
    - _Requirements: 1.6, 1.7_

  - [ ] 7.4 Create `lib/screens/auth/forgot_password_screen.dart`
    - Email field; on submit checks MockDataService and shows success or error message
    - _Requirements: 1.9, 1.10_

  - [ ]* 7.5 Write example tests for auth screens
    - Test that LoginScreen renders 4 demo-login buttons (Requirement 1.11)
    - Test that SplashScreen renders app name text (Requirement 1.2)
    - _Requirements: 1.2, 1.11_

- [ ] 8. Customer screens — product discovery
  - [ ] 8.1 Create `lib/screens/home/home_screen.dart`
    - Use `Consumer<ProductProvider>` to show `SkeletonLoader` while loading, then product grid
    - Include `SearchBarWidget`, promotional banner carousel (mock), category shortcuts row
    - Responsive product grid using `gridColumns(constraints.maxWidth)` via `LayoutBuilder`
    - Tapping a `ProductCard` navigates to `/customer/product/:id` passing product object
    - _Requirements: 2.1, 2.2, 2.5, 2.8, 15.3, 15.4_

  - [ ] 8.2 Create `lib/screens/categories/categories_screen.dart` and `category_products_screen.dart`
    - `CategoriesScreen` lists all categories with `CategoryCard` widgets and item counts
    - Tapping a category navigates to `CategoryProductsScreen` and calls `ProductProvider.filterByCategory(id)`
    - `CategoryProductsScreen` shows filtered product grid + filter/sort controls
    - _Requirements: 2.3, 2.4, 2.7_

  - [ ] 8.3 Create `lib/screens/product/product_details_screen.dart`
    - Displays product image (with error fallback), name, price/unit, description, vendor name
    - "Add to Cart" button calls `CartProvider.addItem(product)` and updates badge
    - _Requirements: 2.6, 3.1, 15.6_

- [ ] 9. Customer screens — cart, checkout, and orders
  - [ ] 9.1 Create `lib/screens/cart/cart_screen.dart`
    - Shows list of `CartItem`s with quantity controls (`+`/`-` buttons) and remove icon
    - Displays subtotal, delivery fee, and grand total from `CartProvider`
    - Empty-state widget with "Continue Shopping" button when cart is empty
    - "Proceed to Checkout" button navigates to `/customer/checkout`
    - _Requirements: 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

  - [ ] 9.2 Create `lib/screens/checkout/checkout_screen.dart` and `order_confirmation_screen.dart`
    - `CheckoutScreen`: address form (street, city, state, postal code) with validators + read-only order summary
    - On valid submit: call `OrderProvider.placeOrder(...)`, then `CartProvider.clearCart()`, then navigate to `OrderConfirmationScreen`
    - `OrderConfirmationScreen`: shows order ID, items summary, and "View Orders" button
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

  - [ ] 9.3 Create `lib/screens/orders/order_history_screen.dart`, `order_details_screen.dart`, and `order_tracking_screen.dart`
    - `OrderHistoryScreen`: lists orders from `OrderProvider` sorted most-recent-first using `OrderCard`
    - `OrderDetailsScreen`: full item breakdown, address, and status; shows "Track Order" button for active orders
    - `OrderTrackingScreen`: status timeline (Stepper widget) + delivery personnel name and ETA from MockDataService
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [ ] 9.4 Create `lib/screens/profile/profile_screen.dart`
    - Displays current user info from `AuthProvider.currentUser`
    - Edit mode toggles editable fields; on save calls `MockDataService.updateUser()` and shows success snackbar
    - Logout button calls `AuthProvider.logout()` and navigates to `/login`
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 10. Checkpoint — Ensure all customer-facing tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 11. Vendor screens
  - [ ] 11.1 Create `lib/screens/vendor/vendor_dashboard_screen.dart`
    - Four `StatsCard` widgets: total products, orders today, lifetime revenue, low-stock count
    - All data computed from MockDataService; quick-access buttons to Products and Orders
    - _Requirements: 7.1_

  - [ ] 11.2 Create `lib/screens/vendor/vendor_product_list_screen.dart`
    - Lists all of the vendor's products with name, category chip, price, stock level badge, and active toggle
    - "Add Product" FAB navigates to `VendorAddEditProductScreen`
    - Edit/Delete actions per row; delete shows confirmation `AlertDialog`
    - _Requirements: 7.2, 7.6, 7.7, 7.8, 7.9, 7.10_

  - [ ] 11.3 Create `lib/screens/vendor/vendor_add_edit_product_screen.dart`
    - `TextFormField`s for name, price, stock, description; `DropdownButtonFormField` for category and unit
    - Mock image placeholder (grey box with camera icon)
    - On valid submit: calls `ProductProvider.addProduct()` or `updateProduct()` and pops back
    - _Requirements: 7.3, 7.4, 7.5, 7.7_

  - [ ] 11.4 Create `lib/screens/vendor/vendor_order_management_screen.dart`
    - Lists orders grouped by `OrderStatus` using `ExpansionTile` sections
    - Tapping an order shows bottom sheet with customer info, items, and status-update dropdown
    - Calls `OrderProvider.updateOrderStatus()` on status change
    - _Requirements: 8.1, 8.2, 8.3_

  - [ ] 11.5 Create `lib/screens/vendor/vendor_sales_report_screen.dart`
    - Bar chart (fl_chart `BarChart`) for revenue per day (last 7 days mock data)
    - Pie chart (`PieChart`) for revenue by category
    - Summary row: total orders this week, best-selling product, total revenue this month
    - _Requirements: 9.1, 9.2, 9.3_

- [ ] 12. Delivery Personnel screens
  - [ ] 12.1 Create `lib/screens/delivery/assigned_orders_screen.dart`
    - Lists orders assigned to current delivery personnel from `OrderProvider`
    - Each `OrderCard` shows customer name, address, and current `DeliveryStatus` chip
    - Tapping an order navigates to `DeliveryTrackingScreen`
    - _Requirements: 10.1, 10.2_

  - [ ] 12.2 Create `lib/screens/delivery/delivery_tracking_screen.dart`
    - Mock map placeholder (Container with grey background + map pin icon and route labels)
    - Shows pickup address, drop-off address, and current `DeliveryStatus`
    - "Update Status" button shows a dialog with the next valid status transition; calls `OrderProvider.updateOrderStatus()` on confirm
    - _Requirements: 10.3, 10.4_

  - [ ] 12.3 Create `lib/screens/delivery/delivery_history_screen.dart`
    - Lists all previously delivered orders for the current delivery personnel
    - Each row shows date, customer name, and delivery address
    - _Requirements: 10.5_

- [ ] 13. Admin screens
  - [ ] 13.1 Create `lib/screens/admin/admin_dashboard_screen.dart`
    - Four `StatsCard` widgets: total users, orders today, revenue today, active products
    - All data sourced from MockDataService
    - _Requirements: 11.1_

  - [ ] 13.2 Create `lib/screens/admin/admin_user_management_screen.dart`
    - Lists all users using `UserProvider.users` with name, email, role chip, and active toggle
    - `SearchBarWidget` at the top calls `UserProvider.search(query)` to filter the list
    - Tapping a user opens a detail bottom sheet with full profile info
    - _Requirements: 12.1, 12.2, 12.3, 12.4_

  - [ ] 13.3 Create `lib/screens/admin/admin_product_management_screen.dart`
    - Lists all products across all vendors with name, vendor, category, price, stock, and active toggle
    - Active toggle calls `ProductProvider.toggleProductActive(id)`
    - _Requirements: 13.1, 13.2_

  - [ ] 13.4 Create `lib/screens/admin/admin_order_management_screen.dart`
    - Lists all orders from `OrderProvider` with order ID, customer, vendor, total, and status chip
    - Status chip is tappable and opens a dropdown to change status via `OrderProvider.updateOrderStatus()`
    - _Requirements: 13.3, 13.4_

  - [ ] 13.5 Create `lib/screens/admin/admin_analytics_screen.dart`
    - Line chart (`LineChart` from fl_chart) for daily orders (last 30 days mock data)
    - Bar chart for revenue by category
    - `DataTable` widget listing top 5 products with product name, units sold, revenue columns
    - _Requirements: 11.2, 11.3, 11.4_

- [ ] 14. Routing, MultiProvider wiring, and auth guard
  - [ ] 14.1 Update `lib/main.dart`
    - Wrap `MaterialApp` in `MultiProvider` registering all five providers: `AuthProvider`, `ProductProvider`, `CartProvider`, `OrderProvider`, `UserProvider`
    - Apply `AppTheme.lightTheme`
    - Register all `AppRoutes` constant names in `routes` map
    - Set `initialRoute` to `AppRoutes.splash`
    - _Requirements: 14.1, 16.1, 16.2_

  - [ ] 14.2 Implement `onGenerateRoute` auth guard
    - In `onGenerateRoute`, check `AuthProvider.isAuthenticated` before navigating to any protected route
    - If unauthenticated, redirect to `AppRoutes.login`
    - _Requirements: 14.5_

  - [ ] 14.3 Implement role-aware shell scaffolding
    - Create a `RoleShell` widget that reads `AuthProvider.currentRole` and renders the appropriate `FreshHarvestBottomNavBar` with an `IndexedStack` of role-specific screens
    - Customer shell: Home, Categories, Cart, Orders, Profile
    - Vendor shell: Dashboard, Products, Orders, Reports
    - Delivery shell: Assigned, Tracking, History
    - Admin shell: Dashboard, Users, Products, Orders, Analytics
    - _Requirements: 14.2, 14.3_

  - [ ]* 14.4 Write property test for responsive grid columns
    - **Property 18: Responsive grid column count**
    - **Validates: Requirements 15.4**
    - For 100 random width values, assert `gridColumns(w)` returns the correct bucket
    - _Requirements: 15.4_

- [ ] 15. Final checkpoint — full integration pass
  - Ensure all tests pass, ask the user if questions arise.

---

## Task Dependency Graph

```json
{
  "waves": [
    ["1"],
    ["2"],
    ["3"],
    ["4"],
    ["5"],
    ["6", "7"],
    ["8", "9"],
    ["10"],
    ["11", "12", "13"],
    ["14"],
    ["15"]
  ]
}
```

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP build
- Each task references specific requirements from `requirements.md` for traceability
- All mock data lives exclusively in `MockDataService`; no other class should contain hardcoded domain data
- Charts in vendor and admin screens use `fl_chart` with static `List<FlSpot>` / `BarChartGroupData` arrays
- The mock map on the Delivery Tracking screen is a styled `Container` — no map SDK needed
- Property tests run a minimum of 100 iterations each and include the tag comment `// Feature: fresh_harvest_app, Property N: <text>`
