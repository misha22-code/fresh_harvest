import 'package:flutter/material.dart';
import 'package:fresh_harvest/config/app_constants.dart';

/// A reusable AppBar that implements [PreferredSizeWidget] for use in
/// [Scaffold.appBar]. Defaults to green background with white foreground,
/// matching the Fresh Harvest design system.
class FreshHarvestAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FreshHarvestAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
  });

  final String title;

  /// When `true`, renders a white back-arrow that calls [Navigator.pop].
  final bool showBack;

  final List<Widget>? actions;

  /// Defaults to [kPrimaryColor] when null.
  final Color? backgroundColor;

  /// Defaults to [kWhiteColor] when null.
  final Color? foregroundColor;

  /// Optional custom leading widget. Takes precedence over [showBack].
  final Widget? leading;

  final bool centerTitle;
  final double elevation;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? kPrimaryColor;
    final fg = foregroundColor ?? kWhiteColor;

    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && showBack) {
      effectiveLeading = IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: fg),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    return AppBar(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: effectiveLeading,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      surfaceTintColor: Colors.transparent,
    );
  }
}
