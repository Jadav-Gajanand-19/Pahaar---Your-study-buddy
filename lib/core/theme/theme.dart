import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// COMMAND CENTER COLOR PALETTE - Military Tactical Theme
// ============================================================================

// Primary Colors - Tactical Olive & Military Greens (Replaces Gold/Dark Green)
const Color kCommandGold = Color(0xFF4A6341);      // Olive Green - Primary accent (Was Gold)
const Color kMilitaryGreen = Color(0xFF8DC63F);    // Lime Green - Active (Was Green)
const Color kOliveGreen = Color(0xFF2E4029);       // Dark Olive - Secondary

// Background & Surface Colors - Clean Light Theme (Replaces Black)
const Color kBackgroundBlack = Color(0xFFF8F9FA);  // Off-white background (Was Black)
const Color kCardBackground = Color(0xFFFFFFFF);   // Pure white card (Was Dark Grey)
const Color kCardElevated = Color(0xFFEBEDEF);     // Light Grey Surface

// Status Colors - Mission Indicators
const Color kStatusActive = Color(0xFF8DC63F);     // Lime Green
const Color kStatusPriority = Color(0xFFE74C3C);   // Red
const Color kStatusWarning = Color(0xFFF39C12);    // Orange
const Color kStatusPending = Color(0xFF3498DB);    // Blue

// Text Colors
const Color kTextPrimary = Color(0xFF1E272E);      // Dark Grey - Primary text (Was White)
const Color kTextSecondary = Color(0xFF7F8C8D);    // Medium Grey - Secondary text
const Color kTextDisabled = Color(0xFFBDC3C7);     // Light Grey - Disabled text

// Border & Accent Colors
const Color kBorderGold = Color(0xFF4A6341);       // Olive borders (Was Gold)
const Color kBorderSubtle = Color(0xFFE0E0E0);     // Light borders

// ============================================================================
// LIGHT MILITARY THEME (New)
// ============================================================================
const Color kLightBackground = Color(0xFFF8F9FA);  // Off-white background
const Color kLightSurface = Color(0xFFFFFFFF);     // Pure white cards
const Color kOlivePrimary = Color(0xFF4A6C2F);     // Dark Olive (Buttons/Priority)
const Color kLimeAccent = Color(0xFF8DC63F);       // Lime Green (Progress)
const Color kTextDarkPrimary = Color(0xFF1A1A1A);  // Dark Text
const Color kTextDarkSecondary = Color(0xFF7F8C8D); // Grey Text
const Color kLightBorder = Color(0xFFEEEEEE);      // Light Borders

// ============================================================================
// GRADIENTS - Command Center Visual Effects
// ============================================================================

class AppGradients {
  // Olive accent gradient (Was Gold)
  static const LinearGradient goldAccent = LinearGradient(
    colors: [kCommandGold, Color(0xFF6B8E5F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Light card gradient (Was Dark)
  static const LinearGradient darkCard = LinearGradient(
    colors: [kCardBackground, kCardElevated],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Status active gradient (Lime)
  static const LinearGradient activeStatus = LinearGradient(
    colors: [kMilitaryGreen, Color(0xFFA2D964)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Priority gradient (Keep Red)
  static const LinearGradient priority = LinearGradient(
    colors: [kStatusPriority, Color(0xFFC0392B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ============================================================================
// ANIMATION CONFIGURATION
// ============================================================================

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve spring = Curves.elasticOut;
}

// ============================================================================
// TEXT STYLES - Military Typography
// ============================================================================

class AppTextStyles {
  // Headers - Black Ops One (Military stencil aesthetic - Mission Prep style)
  static TextStyle get commandTitle => GoogleFonts.blackOpsOne(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: kTextPrimary,
    letterSpacing: 1.5,
  );
  
  static TextStyle get sectionHeader => GoogleFonts.blackOpsOne(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: kTextPrimary,
    letterSpacing: 1.2,
  );
  
  static TextStyle get cardTitle => GoogleFonts.blackOpsOne(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: kTextSecondary,
    letterSpacing: 1.0,
  );
  
  // Body Text - Lato (Clean readability)
  static TextStyle get bodyLarge => GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: kTextPrimary,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: kTextSecondary,
  );
  
  static TextStyle get bodySmall => GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: kTextDisabled,
  );
  
  // Special Styles
  static TextStyle get quotation => GoogleFonts.merriweather(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: kTextSecondary,
    height: 1.6,
  );
  
  static TextStyle get statusBadge => GoogleFonts.lato(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: kTextPrimary,
    letterSpacing: 0.5,
  );
  
  static TextStyle get countdown => GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: kCommandGold,
  );
}

// ============================================================================
// MAIN THEME
// ============================================================================

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: kBackgroundBlack,
    
    colorScheme: const ColorScheme.dark(
      primary: kCommandGold,
      secondary: kMilitaryGreen,
      surface: kCardBackground,
      background: kBackgroundBlack,
      error: kStatusPriority,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: kTextPrimary,
      onBackground: kTextPrimary,
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: kBackgroundBlack,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.commandTitle.copyWith(fontSize: 24),
      iconTheme: const IconThemeData(color: kCommandGold, size: 24),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: kCardBackground,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kBorderSubtle, width: 1),
      ),
    ),
    
    // Text Theme
    textTheme: TextTheme(
      displayLarge: AppTextStyles.commandTitle,
      headlineMedium: AppTextStyles.sectionHeader,
      titleLarge: AppTextStyles.cardTitle,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
    ),
    
    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kCommandGold,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.lato(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kCommandGold,
        side: const BorderSide(color: kCommandGold, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kCardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kBorderSubtle, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kBorderSubtle, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kCommandGold, width: 2),
      ),
      labelStyle: AppTextStyles.bodyMedium,
      hintStyle: AppTextStyles.bodySmall,
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: kCardElevated,
      labelStyle: AppTextStyles.statusBadge,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: kBorderSubtle,
      thickness: 1,
      space: 32,
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: kCommandGold,
      size: 24,
    ),
    
    // FloatingActionButton Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kCommandGold,
      foregroundColor: Colors.black,
      elevation: 6,
    ),
  );
}