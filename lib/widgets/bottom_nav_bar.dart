// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:fresh_harvest/config/app_constants.dart';
import 'package:fresh_harvest/models/app_user.dart';

class _NavTab {
  const _NavTab({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

const _customerTabs = <_NavTab>[
  _NavTab(label: 'Home', icon: Icons.home_rounded),
  _NavTab(label: 'Categories', icon: Icons.grid_view_rounded),
  _NavTab(label: 'Cart', icon: Icons.shopping_cart_rounded),
  _NavTab(label: 'Orders', icon: Icons.receipt_long_rounded),
  _NavTab(label: 'Profile', icon: Icons.person_rounded),
];

const _ownerTabs = <_NavTab>[
  _NavTab(label: 'Dashboard', icon: Icons.dashboard_rounded),
  _NavTab(label: 'Products', icon: Icons.inventory_2_rounded),
  _NavTab(label: 'Orders', icon: Icons.receipt_long_rounded),
  _NavTab(label: 'Reports', icon: Icons.bar_chart_rounded),
];

class FreshHarvestBottomNavBar extends StatelessWidget {
  const FreshHarvestBottomNavBar({
    super.key,
    required this.role,
    required this.currentIndex,
    required this.onTap,
    this.cartBadge,
  });

  final UserRole role;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int? cartBadge;

  List<_NavTab> get _tabs {
    switch (role) {
      case UserRole.customer:
        return _customerTabs;
      case UserRole.owner:
        return _ownerTabs;
      default:
        return _customerTabs;
    }
  }

  static const int _cartTabIndex = 2;

  NavigationDestination _buildDestination(int index, _NavTab tab) {
    final showBadge = role == UserRole.customer &&
        index == _cartTabIndex &&
        cartBadge != null &&
        cartBadge! > 0;

    final icon = Icon(tab.icon);

    return NavigationDestination(
      label: tab.label,
      icon: showBadge
          ? Badge(
              label: Text('$cartBadge'),
              child: icon,
            )
          : icon,
      selectedIcon: showBadge
          ? Badge(
              label: Text('$cartBadge'),
              child: Icon(tab.icon),
            )
          : Icon(tab.icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    final safeIndex = currentIndex.clamp(0, tabs.length - 1);

    return NavigationBar(
      selectedIndex: safeIndex,
      onDestinationSelected: onTap,
      backgroundColor: kWhiteColor,
      indicatorColor: kAccentColor.withAlpha(77),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: kPrimaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return const TextStyle(
          color: kTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        );
      }),
      destinations: [
        for (int i = 0; i < tabs.length; i++) _buildDestination(i, tabs[i]),
      ],
    );
  }
}