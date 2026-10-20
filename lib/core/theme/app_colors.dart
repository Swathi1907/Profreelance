import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette lifted from the Kotlin app's layouts (maroon, gold, cream).
class Pf {
  Pf._();
  static const maroon = Color(0xFF4A0E1C);
  static const ink = Color(0xFF2D0A13);
  static const gold = Color(0xFFC9A24A);
  static const goldDark = Color(0xFFB08222);
  static const cream = Color(0xFFFAF9F0);
  static const sand = Color(0xFFF1EEDD);
  static const hairline = Color(0xFFE4DFC9);
  static const mauve = Color(0xFF8A5A66);
  static const muted = Color(0xFF6F575E);
  static const error = Color(0xFFB3261E);
  static const success = Color(0xFF2E7D32);
}

@immutable
class PfColors extends ThemeExtension<PfColors> {
  const PfColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.cardLine,
    required this.gold,
  });

  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color cardLine;
  final Color gold;

  static const light = PfColors(
    success: Pf.success,
    warning: Pf.goldDark,
    danger: Pf.error,
    info: Pf.maroon,
    cardLine: Color(0xFFE2D5D8),
    gold: Pf.gold,
  );

  static const dark = PfColors(
    success: Color(0xFF7FD18B),
    warning: Color(0xFFE0B654),
    danger: Color(0xFFFFB4AB),
    info: Color(0xFFD7A9B5),
    cardLine: Color(0xFF6A3446),
    gold: Pf.gold,
  );

  @override
  PfColors copyWith({Color? success, Color? warning, Color? danger, Color? info, Color? cardLine, Color? gold}) =>
      PfColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
        info: info ?? this.info,
        cardLine: cardLine ?? this.cardLine,
        gold: gold ?? this.gold,
      );

  @override
  PfColors lerp(ThemeExtension<PfColors>? other, double t) {
    if (other is! PfColors) return this;
    return PfColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      cardLine: Color.lerp(cardLine, other.cardLine, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
    );
  }
}

extension PfContext on BuildContext {
  PfColors get pf => Theme.of(this).extension<PfColors>()!;
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get tt => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// Monospace label style, as used for CLIENT / DATE / STATUS in the original cards.
TextStyle monoStyle(BuildContext context, {double size = 11, Color? color, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: 0.6,
      color: color ?? context.cs.onSurfaceVariant,
    );

const lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Pf.maroon,
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFF3E6E9),
  onPrimaryContainer: Pf.maroon,
  secondary: Pf.gold,
  onSecondary: Pf.ink,
  secondaryContainer: Color(0xFFF4EBCF),
  onSecondaryContainer: Color(0xFF4A3708),
  error: Pf.error,
  onError: Color(0xFFFFFFFF),
  surface: Pf.cream,
  onSurface: Pf.ink,
  onSurfaceVariant: Pf.muted,
  outline: Color(0xFFBCB095),
  outlineVariant: Pf.hairline,
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFFDFCF7),
  surfaceContainer: Pf.sand,
  surfaceContainerHigh: Color(0xFFE9E4D0),
  surfaceContainerHighest: Pf.hairline,
);

const darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Pf.gold,
  onPrimary: Pf.ink,
  primaryContainer: Color(0xFF5E1426),
  onPrimaryContainer: Color(0xFFFBEFF1),
  secondary: Color(0xFFE3B7C2),
  onSecondary: Pf.ink,
  secondaryContainer: Color(0xFF5A2A38),
  onSecondaryContainer: Color(0xFFFBEFF1),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF3B0A06),
  surface: Color(0xFF12040A),
  onSurface: Pf.cream,
  onSurfaceVariant: Color(0xFFD2BFC4),
  outline: Color(0xFF9B6B79),
  outlineVariant: Color(0xFF5A2C3C),
  surfaceContainerLowest: Color(0xFF2A101C),
  surfaceContainerLow: Color(0xFF1E0A13),
  surfaceContainer: Color(0xFF3A1A29),
  surfaceContainerHigh: Color(0xFF47202F),
  surfaceContainerHighest: Color(0xFF55283A),
);

