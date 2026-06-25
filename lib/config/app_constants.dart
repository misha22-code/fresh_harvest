import 'package:flutter/material.dart';

// ─── Colours ──────────────────────────────────────────────────────────────────
const Color kPrimaryColor = Color(0xFF2E7D32);
const Color kAccentColor = Color(0xFF66BB6A);
const Color kBeigeColor = Color(0xFFF5F0E8);

const Color kWhiteColor = Colors.white;

const Color kErrorColor = Color(0xFFD32F2F);
const Color kWarningColor = Color(0xFFF57C00);
const Color kSuccessColor = Color(0xFF388E3C);

const Color kTextPrimary = Color(0xFF333333);
const Color kTextSecondary = Color(0xFF666666);

const Color kBorderColor = Color(0xFFE0E0E0);
const Color kShadowColor = Color(0x1A000000);
const Color kSurfaceColor = Color(0xFFF5F5F5);
const Color kCardColor = Color(0xFFF7F7F7);

// ─── Responsive Breakpoints ───────────────────────────────────────────────────
const double kMobileBreakpoint = 600.0;
const double kTabletBreakpoint = 1024.0;

// ─── Sizes ────────────────────────────────────────────────────────────────────
const double kBorderRadius = 12.0;
const double kCardRadius = 16.0;
const double kButtonRadius = 12.0;

const double kButtonHeight = 48.0;
const double kSectionSpacing = 16.0;

const double kPadding = 16.0;
const double kPaddingSmall = 8.0;
const double kPaddingLarge = 24.0;

// ─── Spacing Scale ────────────────────────────────────────────────────────────
const double kSpacingXS = 8.0;
const double kSpacingSM = 12.0;
const double kSpacingMD = 16.0;
const double kSpacingLG = 24.0;

// ─── Durations ────────────────────────────────────────────────────────────────
const Duration kMockDelay = Duration(milliseconds: 400);
const Duration kAnimationDuration = Duration(milliseconds: 300);

// ─── Grid Helper ──────────────────────────────────────────────────────────────
int gridColumns(double width) {
  if (width >= kTabletBreakpoint) return 4;
  if (width >= kMobileBreakpoint) return 3;
  return 2;
}