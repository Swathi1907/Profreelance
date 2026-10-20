import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildTheme(Brightness b) {
  final cs = b == Brightness.light ? lightScheme : darkScheme;
  final ext = b == Brightness.light ? PfColors.light : PfColors.dark;
  final base = ThemeData(brightness: b, useMaterial3: true).textTheme;
  final body = GoogleFonts.interTextTheme(base).apply(bodyColor: cs.onSurface, displayColor: cs.onSurface);
  TextStyle? head(TextStyle? s) => GoogleFonts.manrope(textStyle: s, fontWeight: FontWeight.w800, letterSpacing: -0.3);
  final text = body.copyWith(
    displaySmall: head(body.displaySmall),
    headlineLarge: head(body.headlineLarge),
    headlineMedium: head(body.headlineMedium),
    headlineSmall: head(body.headlineSmall),
    titleLarge: head(body.titleLarge),
    titleMedium: GoogleFonts.manrope(textStyle: body.titleMedium, fontWeight: FontWeight.w700),
  );

  final fieldLine = b == Brightness.light ? Pf.maroon : cs.outline;
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c, width: w),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: cs.surface,
    textTheme: text,
    extensions: [ext],
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: cs.surfaceContainerLowest,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ext.cardLine),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: b == Brightness.light ? Pf.goldDark : cs.outline),
      labelStyle: TextStyle(color: cs.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: b == Brightness.light ? Pf.goldDark : Pf.gold),
      border: border(fieldLine),
      enabledBorder: border(fieldLine),
      focusedBorder: border(fieldLine, 2),
      errorBorder: border(cs.error),
      focusedErrorBorder: border(cs.error, 2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: b == Brightness.light ? Pf.maroon : Pf.gold,
        foregroundColor: b == Brightness.light ? Colors.white : Pf.ink,
        minimumSize: const Size(64, 52),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: b == Brightness.light ? Pf.maroon : cs.onSurface,
        minimumSize: const Size(64, 48),
        shape: const StadiumBorder(),
        side: BorderSide(color: b == Brightness.light ? Pf.maroon : cs.outline),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: b == Brightness.light ? Pf.maroon : Pf.gold,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      selectedColor: b == Brightness.light ? Pf.maroon : Pf.gold,
      side: BorderSide(color: ext.cardLine),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 13),
      secondaryLabelStyle: TextStyle(
        color: b == Brightness.light ? Colors.white : Pf.ink,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      checkmarkColor: b == Brightness.light ? Pf.gold : Pf.ink,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      height: 72,
      indicatorColor: b == Brightness.light ? Pf.maroon : Pf.gold.withValues(alpha: 0.2),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? (b == Brightness.light ? Pf.gold : Pf.gold)
                : (b == Brightness.light ? Pf.maroon : cs.onSurfaceVariant),
          )),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
            color: b == Brightness.light ? Pf.maroon : cs.onSurface,
          )),
    ),
    dividerTheme: DividerThemeData(color: cs.outlineVariant, space: 1, thickness: 1),
    tabBarTheme: TabBarThemeData(
      indicatorColor: b == Brightness.light ? Pf.maroon : Pf.gold,
      labelColor: cs.onSurface,
      unselectedLabelColor: b == Brightness.light ? const Color(0xFF9A7C83) : cs.onSurfaceVariant,
      dividerColor: cs.outlineVariant,
      labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Pf.ink,
      contentTextStyle: const TextStyle(color: Pf.cream),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
