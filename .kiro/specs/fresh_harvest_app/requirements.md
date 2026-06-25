# Requirements Document

## Introduction

Fresh Harvest is a Flutter-based online fruit and vegetable delivery platform that serves four distinct user roles: Customer, Vendor, Delivery Personnel, and Admin. The application provides a complete end-to-end ordering experience — from product browsing and cart management through delivery tracking — backed entirely by mock/dummy data. The system uses Material 3 design with a green-and-white theme, Provider-based state management, and clean architecture for Android, iOS, and Web targets.

---

## Glossary

- **App**: The Fresh Harvest Flutter application
- **Customer**: An end-user who browses products, places orders, and tracks deliveries
- **Vendor**: A supplier who manages product listings, inventory, and fulfills orders
- **Delivery_Personnel**: A worker who picks up and delivers customer orders
- **Admin**: A system administrator who oversees users, products, orders, and analytics
- **Cart**: A temporary in-memory collection of products selected by a Customer before checkout
- **Order**: A confirmed purchase created from a Customer's Cart with an assigned status
- **Product**: A fruit or vegetable item listed by a Vendor with name, category, price, stock, and image
- **Category**: A product grouping (e.g., Fruits, Vegetables, Leafy Greens, Exotic)
- **MockDataService**: A Dart service class that provides static in-memory dummy data in place of a backend
- **Provider**: A Flutter state-management class from the `provider` package
- **Route**: A named navigation path registered in `main.dart`
- **Role**: One of Customer, Vendor, Delivery_Personnel, or Admin that determines post-login navigation and available features
- **Dashboard**: A role-specific home screen presenting key statistics and quick-access actions
- **Order_Status**: One of `pending`, `confirmed`, `preparing`, `out_for_delivery`, `delivered`, `cancelled`
- **Delivery_Status**: One of `assigned`, `picked_up`, `en_route`, `delivered`

---

## Requirements

### Requirement 1: Splash and Authentication

**User Story:** As any user, I want to launch the app and authenticate with my role, so that I can access the features appropriate to my account type.

#### Acceptance Criteria

1. WHEN the App starts, THE App SHALL display the Splash Screen for a minimum of 2 seconds before navigating to the Login screen
2. THE Splash_Screen SHALL display the Fresh Harvest logo, app name, and a tagline
3. WHEN a user provides valid credentials and taps Login, THE App SHALL authenticate the user against MockDataService and navigate to the role-appropriate Dashboard or Home screen
4. WHEN a user provides invalid credentials and taps Login, THE App SHALL display an inline error message without navigating away from the Login screen
5. WHEN a user taps Register, THE App SHALL navigate to the Registration screen
6. WHEN a new user submits the Registration form with valid name, email, password, and selected role, THE App SHALL create a mock user record and navigate to the Login screen
7. WHEN a registration form field is submitted with an invalid or empty value, THE App SHALL display a field-level validation error message for that field
8. WHEN a user taps Forgot Password, THE App SHALL navigate to the Forgot Password screen
9. WHEN a user submits a registered email on the Forgot Password screen, THE App SHALL display a success confirmation message
10. WHEN a user submits an unregistered email on the Forgot Password screen, THE App SHALL display an error message indicating the email was not found
11. THE Login_Screen SHALL provide distinct demo-login shortcuts for each of the four Roles, so that reviewers can access any role without entering credentials manually

---

### Requirement 2: Customer — Product Discovery

**User Story:** As a Customer, I want to browse, search, and filter products, so that I can quickly find the fruits and vegetables I want to buy.

#### Acceptance Criteria

1. WHEN a Customer opens the Home screen, THE App SHALL display featured products, promotional banners, and category shortcuts sourced from MockDataService
2. THE Home_Screen SHALL display a search bar at the top that filters products by name as the Customer types
3. WHEN a Customer taps a category on the Home screen or Categories screen, THE App SHALL navigate to a filtered product list showing only products in that category
4. THE Categories_Screen SHALL list all available product categories with an icon and item count
5. WHEN a Customer taps a Product Card, THE App SHALL navigate to the Product Details screen for that product
6. THE Product_Details_Screen SHALL display product name, image, price, unit (e.g., kg/piece), description, vendor name, and an Add-to-Cart button
7. WHEN a Customer applies a filter (price range, category, sort order), THE App SHALL update the product list immediately without a full page reload
8. WHILE the product list is loading mock data, THE App SHALL display a loading indicator in place of the product grid

---

### Requirement 3: Customer — Cart Management

**User Story:** As a Customer, I want to manage items in my cart, so that I can review and adjust my order before checking out.

#### Acceptance Criteria

1. WHEN a Customer taps Add to Cart on the Product Details screen, THE App SHALL add the product to the Cart with a quantity of 1 and update the cart badge count in the navigation bar
2. WHEN a Customer increases the quantity of a Cart item, THE App SHALL update the item quantity and recalculate the Cart total
3. WHEN a Customer decreases the quantity of a Cart item to zero, THE App SHALL remove the item from the Cart and update the Cart total
4. WHEN a Customer taps Remove on a Cart item, THE App SHALL remove that item from the Cart immediately
5. THE Cart_Screen SHALL display each item's image, name, unit price, quantity controls, line total, and a summary of the overall Cart total
6. WHEN the Cart is empty, THE Cart_Screen SHALL display an empty-state illustration and a "Continue Shopping" button
7. WHEN a Customer taps Checkout from the Cart screen, THE App SHALL navigate to the Checkout screen

---

### Requirement 4: Customer — Checkout

**User Story:** As a Customer, I want to complete a checkout flow with my delivery address and order summary, so that I can place my order.

#### Acceptance Criteria

1. THE Checkout_Screen SHALL display an address entry form with fields for street, city, state, and postal code
2. WHEN a Customer submits the Checkout form with a valid address, THE App SHALL create a new Order in MockDataService with status `pending` and navigate to the Order Confirmation screen
3. WHEN a Customer submits the Checkout form with any empty required address field, THE App SHALL display field-level validation errors and prevent Order creation
4. THE Checkout_Screen SHALL display a read-only order summary showing all Cart items, subtotal, delivery fee, and grand total
5. WHEN an Order is successfully placed, THE App SHALL clear the Customer's Cart

---

### Requirement 5: Customer — Order History and Tracking

**User Story:** As a Customer, I want to view my order history and track active deliveries, so that I know the status and location of my purchases.

#### Acceptance Criteria

1. THE Order_History_Screen SHALL list all past and active Orders for the authenticated Customer, sorted by most recent first
2. WHEN a Customer taps an Order in the history list, THE App SHALL navigate to the Order Details screen showing full item breakdown, delivery address, and current Order_Status
3. WHEN a Customer taps Track Order for an active Order, THE App SHALL navigate to the Order Tracking screen
4. THE Order_Tracking_Screen SHALL display the Order_Status timeline showing completed and pending steps from `confirmed` through `delivered`
5. THE Order_Tracking_Screen SHALL display the assigned Delivery_Personnel name and estimated delivery time sourced from MockDataService

---

### Requirement 6: Customer — Profile Management

**User Story:** As a Customer, I want to view and edit my profile, so that I can keep my account information up to date.

#### Acceptance Criteria

1. THE Profile_Screen SHALL display the Customer's name, email, phone number, and profile avatar
2. WHEN a Customer taps Edit Profile, THE App SHALL display an edit form pre-populated with the Customer's current information
3. WHEN a Customer submits the edit form with valid data, THE App SHALL update the mock user record and display a success confirmation
4. WHEN a Customer taps Logout, THE App SHALL clear the authenticated session and navigate to the Login screen

---

### Requirement 7: Vendor — Dashboard and Product Management

**User Story:** As a Vendor, I want to manage my product catalog and monitor sales statistics, so that I can keep my store up to date and understand my performance.

#### Acceptance Criteria

1. THE Vendor_Dashboard_Screen SHALL display aggregate statistics: total active products, total orders received today, total revenue (lifetime), and a low-stock alert count, all sourced from MockDataService
2. WHEN a Vendor taps Add Product, THE App SHALL navigate to the Add Product form
3. THE Add_Product_Form SHALL include fields for product name, category (dropdown), price, unit, stock quantity, and description, with a mock image placeholder
4. WHEN a Vendor submits the Add Product form with all required fields valid, THE App SHALL create a new Product in MockDataService and return to the Product List screen
5. WHEN a Vendor submits the Add Product form with any required field empty or invalid, THE App SHALL display field-level validation errors and prevent Product creation
6. WHEN a Vendor taps Edit on a product, THE App SHALL navigate to the Edit Product form pre-populated with existing product data
7. WHEN a Vendor submits the Edit Product form with valid data, THE App SHALL update the Product in MockDataService
8. WHEN a Vendor taps Delete on a product, THE App SHALL display a confirmation dialog before removing the Product from MockDataService
9. THE Vendor_Product_List_Screen SHALL display each product's name, category, price, stock level, and an active/inactive toggle
10. WHEN a Vendor toggles a product's active status, THE App SHALL update the product's availability in MockDataService immediately

---

### Requirement 8: Vendor — Order and Inventory Management

**User Story:** As a Vendor, I want to view incoming orders and manage product inventory, so that I can fulfill orders accurately and prevent stockouts.

#### Acceptance Criteria

1. THE Vendor_Order_Management_Screen SHALL list all Orders containing the Vendor's products, grouped by Order_Status
2. WHEN a Vendor taps an Order, THE App SHALL display Order details including Customer name, ordered items, quantities, and delivery address
3. WHEN a Vendor updates an Order's status (e.g., from `pending` to `confirmed`), THE App SHALL update the Order_Status in MockDataService
4. THE Vendor_Inventory_Screen SHALL highlight products whose stock quantity falls below a configurable threshold (default: 10 units)
5. WHEN a Vendor updates a product's stock quantity, THE App SHALL update the value in MockDataService and refresh the low-stock alert count on the Dashboard

---

### Requirement 9: Vendor — Sales Reports

**User Story:** As a Vendor, I want to view sales reports with charts, so that I can analyse trends and make informed stocking decisions.

#### Acceptance Criteria

1. THE Sales_Report_Screen SHALL display a bar chart showing revenue per day for the last 7 days, using mock time-series data
2. THE Sales_Report_Screen SHALL display a pie chart showing revenue distribution by product category
3. THE Sales_Report_Screen SHALL display summary metrics: total orders this week, best-selling product, and total revenue this month

---

### Requirement 10: Delivery Personnel — Order Assignment and Tracking

**User Story:** As a Delivery_Personnel, I want to view my assigned deliveries and update their status, so that I can manage my route and keep customers informed.

#### Acceptance Criteria

1. THE Assigned_Orders_Screen SHALL list all Orders assigned to the authenticated Delivery_Personnel with customer name, delivery address, and current Delivery_Status
2. WHEN a Delivery_Personnel taps an Order, THE App SHALL display the Order details and a button to update the Delivery_Status
3. WHEN a Delivery_Personnel updates the Delivery_Status (e.g., from `assigned` to `picked_up`), THE App SHALL update the status in MockDataService and refresh the order list
4. THE Delivery_Tracking_Screen SHALL display a mock map placeholder with pickup and drop-off address labels and the current Delivery_Status
5. THE Delivery_History_Screen SHALL list all Orders the authenticated Delivery_Personnel has previously delivered with date, customer name, and delivery address

---

### Requirement 11: Admin — Dashboard and Analytics

**User Story:** As an Admin, I want to view platform-wide analytics, so that I can monitor the health and performance of the Fresh Harvest platform.

#### Acceptance Criteria

1. THE Admin_Dashboard_Screen SHALL display aggregate platform statistics: total registered users, total orders today, total revenue today, and total active products, all sourced from MockDataService
2. THE Analytics_Screen SHALL display a line chart showing total daily orders over the last 30 days
3. THE Analytics_Screen SHALL display a bar chart showing revenue by product category
4. THE Analytics_Screen SHALL display a summary table of the top 5 selling products with product name, units sold, and revenue

---

### Requirement 12: Admin — User Management

**User Story:** As an Admin, I want to list and manage user accounts, so that I can maintain platform integrity and handle policy violations.

#### Acceptance Criteria

1. THE User_Management_Screen SHALL list all registered users with their name, email, role, and active/inactive status
2. WHEN an Admin taps a user, THE App SHALL display a User Detail view with full profile information
3. WHEN an Admin toggles a user's active status, THE App SHALL update the user record in MockDataService and reflect the change in the list immediately
4. THE User_Management_Screen SHALL provide a search field that filters the user list by name or email as the Admin types

---

### Requirement 13: Admin — Product and Order Management

**User Story:** As an Admin, I want to oversee all products and orders, so that I can resolve issues and ensure catalogue quality.

#### Acceptance Criteria

1. THE Admin_Product_Management_Screen SHALL list all products across all Vendors with name, vendor, category, price, and stock level
2. WHEN an Admin toggles a product's active status, THE App SHALL update the product's availability in MockDataService
3. THE Admin_Order_Management_Screen SHALL list all Orders on the platform with order ID, customer name, vendor, total amount, and current Order_Status
4. WHEN an Admin updates an Order's status, THE App SHALL update the Order_Status in MockDataService

---

### Requirement 14: Navigation and Routing

**User Story:** As any user, I want intuitive navigation appropriate to my role, so that I can move between screens efficiently.

#### Acceptance Criteria

1. THE App SHALL register all screens as named routes in `main.dart`
2. WHEN a user successfully logs in, THE App SHALL navigate to the root screen for their Role: Home for Customer, Dashboard for Vendor, Assigned Orders for Delivery_Personnel, and Dashboard for Admin
3. THE App SHALL render a role-aware Bottom_Navigation_Bar with tabs specific to each Role:
   - Customer: Home, Categories, Cart, Orders, Profile
   - Vendor: Dashboard, Products, Orders, Reports
   - Delivery_Personnel: Assigned, Tracking, History
   - Admin: Dashboard, Users, Products, Orders, Analytics
4. WHEN a user taps the Back button or swipe gesture, THE App SHALL navigate to the previous screen in the navigation stack
5. WHEN an unauthenticated user attempts to access a protected route, THE App SHALL redirect to the Login screen

---

### Requirement 15: UI/UX and Theming

**User Story:** As any user, I want a consistent, attractive, and accessible interface, so that the app is easy and pleasant to use.

#### Acceptance Criteria

1. THE App SHALL apply a Material 3 theme with primary color `#2E7D32` (dark green) and background color `#FFFFFF` (white) across all screens
2. THE App SHALL use consistent typography: headline text using `displaySmall`, section titles using `titleLarge`, body text using `bodyMedium`
3. THE App SHALL display skeleton loading placeholders while mock data is being "fetched" via a simulated async delay
4. WHEN the screen width exceeds 600 dp, THE App SHALL adapt product grids from 2 columns to 3 or more columns for tablet and web layouts
5. THE App SHALL provide a custom App Bar widget (`FreshHarvestAppBar`) used on all screens, supporting a title, optional back button, and optional action icons
6. IF a network image URL fails to load, THE App SHALL display a fallback placeholder image

---

### Requirement 16: State Management

**User Story:** As a developer, I want a clean Provider-based state management structure, so that the app is maintainable and testable.

#### Acceptance Criteria

1. THE App SHALL use the `provider` package (version ≥6.0.0) for all state management, with no other state-management libraries
2. THE App SHALL define a separate Provider class for each major domain: `AuthProvider`, `ProductProvider`, `CartProvider`, `OrderProvider`, `UserProvider`
3. WHEN any Provider state changes, THE App SHALL rebuild only the widgets that depend on that Provider's data
4. THE MockDataService SHALL expose synchronous or `Future`-returning methods that simulate async data access with a fixed delay of 300–500 ms
