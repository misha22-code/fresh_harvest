/// Named route constants for the Fresh Harvest application.
///
/// All routes are registered in `main.dart` and used throughout the app for
/// type-safe navigation instead of hard-coded string literals.
class AppRoutes {
  AppRoutes._();

  // ── Auth / Splash ─────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otpVerification';
  static const String roleSelection = '/roleSelection';

  // ── Customer ──────────────────────────────────────────────────────────────
  static const String customerHome = '/customer/home';
  static const String categories = '/customer/categories';
  static const String categoryProducts = '/customer/categories/products';
  static const String productDetails = '/customer/product/details';
  static const String cart = '/customer/cart';
  static const String checkout = '/customer/checkout';
  static const String orderConfirmation = '/customer/order-confirmation';
  static const String orderHistory = '/customer/orders';
  static const String orderDetails = '/customer/orders/details';
  static const String orderTracking = '/customer/orders/tracking';
  static const String profile = '/customer/profile';
  static const String favorites = '/favorites';

  // ── Vendor ────────────────────────────────────────────────────────────────
  static const String vendorDashboard = '/vendor/dashboard';
  static const String vendorProducts = '/vendor/products';
  static const String vendorAddProduct = '/vendor/products/add';
  static const String vendorEditProduct = '/vendor/products/edit';
  static const String vendorProductReviews = '/vendor/products/reviews';
  static const String vendorOrders = '/vendor/orders';
  static const String vendorReports = '/vendor/reports';

  // ── Delivery Personnel ────────────────────────────────────────────────────
  static const String deliveryAssigned = '/delivery/assigned';
  static const String deliveryTracking = '/delivery/tracking';
  static const String deliveryHistory = '/delivery/history';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminProducts = '/admin/products';
  static const String adminOrders = '/admin/orders';
  static const String adminAnalytics = '/admin/analytics';

  // ── Owner ──────────────────────────────────────────────────────────────────
  // Owner = Admin + Vendor + Delivery (All-in-One)
  static const String ownerLogin = '/owner/login';
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerProducts = '/owner/products';
  static const String ownerAddProduct = '/owner/products/add';
  static const String ownerEditProduct = '/owner/products/edit';
  static const String ownerOrders = '/owner/orders';
  static const String ownerDelivery = '/owner/delivery';
  static const String ownerReports = '/owner/reports';
}