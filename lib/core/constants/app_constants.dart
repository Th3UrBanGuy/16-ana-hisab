import 'package:flutter/material.dart';

// Brand Colors (matching the design screenshots)
class AppColors {
  static const Color primaryTeal = Color(0xFF00BFA5);
  static const Color darkNavy = Color(0xFF1A2332);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color errorRed = Color(0xFFE53935);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color successGreen = Color(0xFF4CAF50);
  
  // Chart Colors
  static const Color chartBlue = Color(0xFF2196F3);
  static const Color chartPurple = Color(0xFF9C27B0);
  static const Color chartGreen = Color(0xFF4CAF50);
}

// App Constants
class AppConstants {
  static const String appName = 'Retail Pro';
  static const String currency = '\$';
  static const double taxRate = 0.09; // 9% tax
  
  // Payment Methods
  static const String paymentCash = 'Cash';
  static const String paymentCard = 'Card';
  static const String paymentSplit = 'Split';
  
  // Order Status
  static const String statusPaid = 'Paid';
  static const String statusVoid = 'Void';
  static const String statusRefunded = 'Refunded';
  static const String statusParked = 'Parked';
  
  // User Roles
  static const String roleAdmin = 'Admin';
  static const String roleCashier = 'Cashier';
  
  // Coupon Types
  static const String couponPercentage = 'Percentage';
  static const String couponFixed = 'Fixed';
  static const String couponBogo = 'BOGO';
}

// Responsive Breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}
