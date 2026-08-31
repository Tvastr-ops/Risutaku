import 'dart:ui';

import 'package:flutter/material.dart';

enum FormFactor { phone, tablet }

enum ThemeBase {
  peach(
    'Peach',
    Color(0xFFFF8A65),
    lightPrimary: Color(0xFFD84315),
    lightContainer: Color(0xFFFFEBE5),
    darkPrimary: Color(0xFFFFAB91),
    darkContainer: Color(0xFF5E1A04),
  ),
  sakura(
    'Sakura',
    Color(0xFFFF80AB),
    lightPrimary: Color(0xFFD81B60),
    lightContainer: Color(0xFFFCE4EC),
    darkPrimary: Color(0xFFFF80AB),
    darkContainer: Color(0xFF5C0028),
  ),
  cyberpunk(
    'Cyberpunk',
    Color(0xFFFF007F),
    lightPrimary: Color(0xFFD500F9),
    lightContainer: Color(0xFFFFD6EC),
    darkPrimary: Color(0xFFFF007F),
    darkContainer: Color(0xFF600030),
  ),
  neonRed(
    'Neon Red',
    Color(0xFFFF1744),
    lightPrimary: Color(0xFFD50000),
    lightContainer: Color(0xFFFFCDD2),
    darkPrimary: Color(0xFFFF3355),
    darkContainer: Color(0xFF5A000A),
  ),
  crimson(
    'Crimson',
    Color(0xFFB71C1C),
    lightPrimary: Color(0xFF8B0000),
    lightContainer: Color(0xFFFFEBEE),
    darkPrimary: Color(0xFFE53935),
    darkContainer: Color(0xFF4A0808),
  ),
  wine(
    'Wine',
    Color(0xFF722F37),
    lightPrimary: Color(0xFF581845),
    lightContainer: Color(0xFFF3E5F5),
    darkPrimary: Color(0xFFC75D8F),
    darkContainer: Color(0xFF400A24),
  ),
  amethyst(
    'Amethyst',
    Color(0xFF9C27B0),
    lightPrimary: Color(0xFF7B1FA2),
    lightContainer: Color(0xFFEDE7F6),
    darkPrimary: Color(0xFFCE6CE6),
    darkContainer: Color(0xFF450A52),
  ),
  lavender(
    'Lavender',
    Color(0xFF7E57C2),
    lightPrimary: Color(0xFF512DA8),
    lightContainer: Color(0xFFEDE7F6),
    darkPrimary: Color(0xFFB4ABF5),
    darkContainer: Color(0xFF26184D),
  ),
  indigo(
    'Indigo',
    Color(0xFF3F51B5),
    lightPrimary: Color(0xFF283593),
    lightContainer: Color(0xFFE8EAF6),
    darkPrimary: Color(0xFF7986CB),
    darkContainer: Color(0xFF141F59),
  ),
  navy(
    'Navy',
    Color(0xFF0288D1),
    lightPrimary: Color(0xFF0277BD),
    lightContainer: Color(0xFFE1F5FE),
    darkPrimary: Color(0xFF40C4FF),
    darkContainer: Color(0xFF003859),
  ),
  neonCyan(
    'Neon Cyan',
    Color(0xFF00E5FF),
    lightPrimary: Color(0xFF00838F),
    lightContainer: Color(0xFFE0F7FA),
    darkPrimary: Color(0xFF00E5FF),
    darkContainer: Color(0xFF004953),
  ),
  mint(
    'Mint',
    Color(0xFF00BFA5),
    lightPrimary: Color(0xFF00796B),
    lightContainer: Color(0xFFE0F2F1),
    darkPrimary: Color(0xFF1DE9B6),
    darkContainer: Color(0xFF003D34),
  ),
  forest(
    'Forest',
    Color(0xFF2E7D32),
    lightPrimary: Color(0xFF1B5E20),
    lightContainer: Color(0xFFE8F5E9),
    darkPrimary: Color(0xFF4CAF50),
    darkContainer: Color(0xFF0F3A13),
  ),
  neonGreen(
    'Neon Green',
    Color(0xFF00E676),
    lightPrimary: Color(0xFF00853B),
    lightContainer: Color(0xFFE8F8F0),
    darkPrimary: Color(0xFF00E676),
    darkContainer: Color(0xFF004D22),
  ),
  matcha(
    'Matcha',
    Color(0xFF689F38),
    lightPrimary: Color(0xFF4B6E1F),
    lightContainer: Color(0xFFF1F8E9),
    darkPrimary: Color(0xFFAED581),
    darkContainer: Color(0xFF2B400F),
  ),
  mustard(
    'Mustard',
    Color(0xFFFFB300),
    lightPrimary: Color(0xFFB26A00),
    lightContainer: Color(0xFFFFF8E1),
    darkPrimary: Color(0xFFFFD54F),
    darkContainer: Color(0xFF5C3800),
  ),
  sunset(
    'Sunset',
    Color(0xFFFF3D00),
    lightPrimary: Color(0xFFDD2C00),
    lightContainer: Color(0xFFFFEBE5),
    darkPrimary: Color(0xFFFF6E40),
    darkContainer: Color(0xFF5C1000),
  ),
  caramel(
    'Caramel',
    Color(0xFFD87A15),
    lightPrimary: Color(0xFF8D4004),
    lightContainer: Color(0xFFFFF3E0),
    darkPrimary: Color(0xFFFFA726),
    darkContainer: Color(0xFF4A2000),
  ),
  nordic(
    'Nordic',
    Color(0xFF546E7A),
    lightPrimary: Color(0xFF37474F),
    lightContainer: Color(0xFFECEFF1),
    darkPrimary: Color(0xFF90A4AE),
    darkContainer: Color(0xFF1E282D),
  );

  const ThemeBase(
    this.title,
    this.seed, {
    required this.lightPrimary,
    required this.lightContainer,
    required this.darkPrimary,
    required this.darkContainer,
  });

  final String title;
  final Color seed;
  final Color lightPrimary;
  final Color lightContainer;
  final Color darkPrimary;
  final Color darkContainer;

  static ThemeBase? fromSeed(Color seed) {
    for (final t in values) {
      if (t.seed == seed) return t;
    }
    return null;
  }
}

class Theming extends ThemeExtension<Theming> {
  const Theming({required this.formFactor, required this.rightButtonOrientation});

  /// Pages should adapt their layouts, in consideration of the [formFactor].
  final FormFactor formFactor;

  /// Determines whether FAB and prominent buttons should be on the right side,
  /// with lest important buttons on the left.
  /// This makes core actions more accessible.
  final bool rightButtonOrientation;

  static Theming of(BuildContext context) =>
      Theme.of(context).extension<Theming>() ??
      const Theming(formFactor: .phone, rightButtonOrientation: true);

  @override
  ThemeExtension<Theming> copyWith({FormFactor? formFactor, bool? rightButtonOrientation}) =>
      Theming(
        formFactor: formFactor ?? this.formFactor,
        rightButtonOrientation: rightButtonOrientation ?? this.rightButtonOrientation,
      );

  @override
  ThemeExtension<Theming> lerp(covariant ThemeExtension<Theming>? other, double t) =>
      switch (other) {
        Theming _ => other,
        _ => this,
      };

  static const windowWidthMedium = 600.0;
  static const windowWidthLarge = 840.0;

  static const offset = 10.0;
  static const minTapTarget = 48.0;
  static const normalTapTarget = 56.0;
  static const coverHtoWRatio = 1.53;

  static const fontBig = 18.0;
  static const fontMedium = 15.0;
  static const fontSmall = 13.0;

  static const iconBig = 25.0;
  static const iconSmall = 20.0;

  static const paddingAll = EdgeInsets.all(offset);
  static const radiusSmall = Radius.circular(12);
  static const radiusBig = Radius.circular(24);
  static const borderRadiusSmall = BorderRadius.all(radiusSmall);
  static const borderRadiusBig = BorderRadius.all(radiusBig);
  static final blurFilter = ImageFilter.blur(sigmaX: 5, sigmaY: 5);
  static const bouncyPhysics = AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

  static ColorScheme createColorScheme({
    required Color seed,
    required Brightness brightness,
    required bool highContrast,
  }) {
    final tb = ThemeBase.fromSeed(seed);
    final hsl = HSLColor.fromColor(seed);
    final bgHue = hsl.hue;

    if (brightness == Brightness.light) {
      final primary = tb?.lightPrimary ??
          HSLColor.fromAHSL(
            1.0,
            hsl.hue,
            (hsl.saturation * 1.1).clamp(0.7, 1.0),
            hsl.lightness.clamp(0.28, 0.42),
          ).toColor();

      final primaryContainer = tb?.lightContainer ??
          HSLColor.fromAHSL(
            1.0,
            hsl.hue,
            (hsl.saturation * 0.5).clamp(0.2, 0.6),
            0.92,
          ).toColor();

      final onPrimaryContainer = HSLColor.fromAHSL(
        1.0,
        hsl.hue,
        (hsl.saturation * 1.1).clamp(0.8, 1.0),
        0.18,
      ).toColor();

      final secondary = HSLColor.fromAHSL(
        1.0,
        (hsl.hue + 15) % 360,
        (hsl.saturation * 0.7).clamp(0.3, 0.7),
        0.40,
      ).toColor();

      final tertiary = HSLColor.fromAHSL(
        1.0,
        (hsl.hue + 45) % 360,
        (hsl.saturation * 0.7).clamp(0.3, 0.7),
        0.42,
      ).toColor();

      final secondaryContainer = HSLColor.fromAHSL(
        1.0,
        (hsl.hue + 15) % 360,
        (hsl.saturation * 0.4).clamp(0.15, 0.45),
        0.92,
      ).toColor();

      final onSecondaryContainer = HSLColor.fromAHSL(
        1.0,
        (hsl.hue + 15) % 360,
        (hsl.saturation * 0.8).clamp(0.5, 0.9),
        0.20,
      ).toColor();

      if (highContrast) {
        return ColorScheme.light(
          primary: primary,
          onPrimary: Colors.white,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          secondary: secondary,
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFEDEDED),
          onSecondaryContainer: Colors.black,
          tertiary: tertiary,
          onTertiary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          onSurfaceVariant: const Color(0xFF404040),
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: const Color(0xFFF7F7F7),
          surfaceContainer: const Color(0xFFEFEFEF),
          surfaceContainerHigh: const Color(0xFFE5E5E5),
          surfaceContainerHighest: const Color(0xFFDBDBDB),
          outline: primary.withValues(alpha: 0.40),
          outlineVariant: const Color(0xFFD0D0D0),
        );
      }

      final surface = HSLColor.fromAHSL(1.0, bgHue, 0.08, 0.985).toColor();
      final surfaceLow = HSLColor.fromAHSL(1.0, bgHue, 0.08, 0.96).toColor();
      final surfaceCont = HSLColor.fromAHSL(1.0, bgHue, 0.10, 0.93).toColor();
      final surfaceHigh = HSLColor.fromAHSL(1.0, bgHue, 0.12, 0.89).toColor();
      final surfaceHighest = HSLColor.fromAHSL(1.0, bgHue, 0.14, 0.85).toColor();

      return ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: Colors.white,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: Colors.white,
        surface: surface,
        onSurface: const Color(0xFF1A1A1A),
        onSurfaceVariant: const Color(0xFF555555),
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: surfaceLow,
        surfaceContainer: surfaceCont,
        surfaceContainerHigh: surfaceHigh,
        surfaceContainerHighest: surfaceHighest,
        outline: primary.withValues(alpha: 0.25),
        outlineVariant: HSLColor.fromAHSL(1.0, bgHue, 0.08, 0.88).toColor(),
      );
    }

    final vibrantPrimary = tb?.darkPrimary ??
        HSLColor.fromAHSL(
          1.0,
          hsl.hue,
          (hsl.saturation * 1.15).clamp(0.75, 1.0),
          hsl.lightness.clamp(0.60, 0.72),
        ).toColor();

    final primaryContainer = tb?.darkContainer ??
        HSLColor.fromAHSL(
          1.0,
          hsl.hue,
          (hsl.saturation * 0.9).clamp(0.5, 0.9),
          0.22,
        ).toColor();

    final onPrimaryContainer = HSLColor.fromAHSL(
      1.0,
      hsl.hue,
      0.9,
      0.88,
    ).toColor();

    final secondary = HSLColor.fromAHSL(
      1.0,
      (hsl.hue + 15) % 360,
      (hsl.saturation * 0.8).clamp(0.4, 0.8),
      0.70,
    ).toColor();

    final secondaryContainer = HSLColor.fromAHSL(
      1.0,
      (hsl.hue + 15) % 360,
      (hsl.saturation * 0.45).clamp(0.2, 0.45),
      0.18,
    ).toColor();

    final onSecondaryContainer = HSLColor.fromAHSL(
      1.0,
      (hsl.hue + 15) % 360,
      (hsl.saturation * 0.8).clamp(0.4, 0.85),
      0.88,
    ).toColor();

    final tertiary = HSLColor.fromAHSL(
      1.0,
      (hsl.hue + 45) % 360,
      (hsl.saturation * 0.8).clamp(0.4, 0.8),
      0.72,
    ).toColor();

    if (highContrast) {
      return ColorScheme.dark(
        primary: vibrantPrimary,
        onPrimary: Colors.black,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: Colors.black,
        secondaryContainer: const Color(0xFF1A1A1A),
        onSecondaryContainer: const Color(0xFFE8E8E8),
        tertiary: tertiary,
        onTertiary: Colors.black,
        surface: Colors.black,
        onSurface: const Color(0xFFF0F0F0),
        onSurfaceVariant: const Color(0xFFB8B8B8),
        surfaceContainerLowest: Colors.black,
        surfaceContainerLow: const Color(0xFF0A0A0A),
        surfaceContainer: const Color(0xFF111111),
        surfaceContainerHigh: const Color(0xFF181818),
        surfaceContainerHighest: const Color(0xFF222222),
        outline: vibrantPrimary.withValues(alpha: 0.35),
        outlineVariant: const Color(0xFF2A2A2A),
      );
    }

    final surface = HSLColor.fromAHSL(1.0, bgHue, 0.22, 0.08).toColor();
    final surfaceLow = HSLColor.fromAHSL(1.0, bgHue, 0.20, 0.11).toColor();
    final surfaceCont = HSLColor.fromAHSL(1.0, bgHue, 0.18, 0.13).toColor();
    final surfaceHigh = HSLColor.fromAHSL(1.0, bgHue, 0.16, 0.16).toColor();
    final surfaceHighest = HSLColor.fromAHSL(1.0, bgHue, 0.14, 0.20).toColor();

    return ColorScheme.dark(
      primary: vibrantPrimary,
      onPrimary: Colors.black,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: Colors.black,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: Colors.black,
      surface: surface,
      onSurface: const Color(0xFFE8E8E8),
      onSurfaceVariant: const Color(0xFFAAAAAA),
      surfaceContainerLowest: HSLColor.fromAHSL(1.0, bgHue, 0.25, 0.06).toColor(),
      surfaceContainerLow: surfaceLow,
      surfaceContainer: surfaceCont,
      surfaceContainerHigh: surfaceHigh,
      surfaceContainerHighest: surfaceHighest,
      outline: vibrantPrimary.withValues(alpha: 0.25),
      outlineVariant: HSLColor.fromAHSL(1.0, bgHue, 0.15, 0.25).toColor(),
    );
  }

  static ThemeData generateThemeData(ColorScheme scheme) => ThemeData(
    fontFamily: 'Rubik',
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    disabledColor: scheme.surface,
    unselectedWidgetColor: scheme.surface,
    highlightColor: Colors.transparent,
    cardTheme: CardThemeData(
      margin: const .all(0),
      shape: const RoundedRectangleBorder(borderRadius: borderRadiusSmall),
      color: scheme.surfaceContainerLow,
      elevation: 0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: radiusBig),
      ),
      backgroundColor: scheme.surfaceContainerHigh,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      highlightElevation: 4,
    ),
    iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: iconBig),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface.withAlpha(190),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      labelType: NavigationRailLabelType.all,
      groupAlignment: 0,
    ),
    chipTheme: ChipThemeData(
      labelStyle: TextStyle(
        color: scheme.onSecondaryContainer,
        fontVariations: const [FontVariation('wght', 400)],
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.secondaryContainer;
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.onSecondaryContainer;
          }
          return scheme.onSurface;
        }),
        iconColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.onSecondaryContainer;
          }
          return scheme.onSurfaceVariant;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          return BorderSide(color: scheme.outlineVariant);
        }),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.onPrimary;
        }
        return scheme.onSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.primary;
        }
        return scheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return scheme.outline;
      }),
    ),
    sliderTheme: const SliderThemeData(
      trackGap: 6,
      trackHeight: 16,
      trackShape: GappedSliderTrackShape(),
      thumbShape: HandleThumbShape(),
      thumbSize: WidgetStatePropertyAll(Size(4, 44)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        iconColor: scheme.onPrimary,
        textStyle: const TextStyle(
          fontSize: fontMedium,
          fontVariations: [FontVariation('wght', 500)],
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: fontMedium,
          fontVariations: [FontVariation('wght', 400)],
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: fontMedium,
          fontVariations: [FontVariation('wght', 450)],
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const .symmetric(horizontal: offset),
      titleTextStyle: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurface,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      subtitleTextStyle: TextStyle(
        fontSize: fontSmall,
        color: scheme.onSurfaceVariant,
        fontVariations: const [FontVariation('wght', 350)],
      ),
    ),
    textTheme: TextTheme(
      titleMedium: TextStyle(
        fontSize: fontBig,
        color: scheme.onSurface,
        fontVariations: const [FontVariation('wght', 450)],
      ),
      titleSmall: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurface,
        fontVariations: const [FontVariation('wght', 450)],
      ),
      bodyLarge: TextStyle(
        fontSize: fontBig,
        color: scheme.onSurface,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      bodyMedium: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurface,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      labelLarge: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurfaceVariant,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      labelMedium: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurfaceVariant,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      labelSmall: TextStyle(
        fontSize: fontSmall,
        color: scheme.onSurfaceVariant,
        fontVariations: const [FontVariation('wght', 350)],
        letterSpacing: 0.5,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
      selectionHandleColor: scheme.primary,
      selectionColor: scheme.primary.withAlpha(50),
    ),
    dividerTheme: const DividerThemeData(thickness: 1),
    dialogTheme: DialogThemeData(
      shape: const RoundedRectangleBorder(borderRadius: borderRadiusBig),
      backgroundColor: scheme.surfaceContainerHigh,
      titleTextStyle: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurface,
        fontVariations: const [FontVariation('wght', 500)],
      ),
      contentTextStyle: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurface,
        fontVariations: const [FontVariation('wght', 400)],
      ),
    ),
    tooltipTheme: TooltipThemeData(
      padding: paddingAll,
      textStyle: TextStyle(color: scheme.onSurfaceVariant),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: borderRadiusSmall,
        border: .all(color: scheme.outline),
        boxShadow: [BoxShadow(color: scheme.surface, blurRadius: 10)],
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      interactive: true,
      radius: radiusSmall,
      thickness: .all(5),
      thumbColor: .all(scheme.primary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      hintStyle: TextStyle(
        fontSize: fontMedium,
        color: scheme.onSurfaceVariant,
        fontVariations: const [FontVariation('wght', 400)],
      ),
      border: const OutlineInputBorder(
        borderRadius: borderRadiusSmall,
        borderSide: BorderSide.none,
      ),
    ),
  );
}
