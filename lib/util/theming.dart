import 'dart:ui';

import 'package:flutter/material.dart';

enum FormFactor { phone, tablet }

enum ThemeBase {
  peach('Peach', Color(0xFFFF9E80)),
  sakura('Sakura', Color(0xFFFF80AB)),
  cyberpunk('Cyberpunk', Color(0xFFFF007F)),
  neonRed('Neon Red', Color(0xFFFF1744)),
  crimson('Crimson', Color(0xFFE53935)),
  wine('Wine', Color(0xFF894771)),
  amethyst('Amethyst', Color(0xFF9C27B0)),
  lavender('Lavender', Color(0xFFB4ABF5)),
  indigo('Indigo', Color(0xFF5C6BC0)),
  navy('Navy', Color(0xFF45A0F2)),
  neonCyan('Neon Cyan', Color(0xFF00E5FF)),
  mint('Mint', Color(0xFF2AB8B8)),
  forest('Forest', Color(0xFF00FFA9)),
  neonGreen('Neon Green', Color(0xFF00E676)),
  matcha('Matcha', Color(0xFF8BC34A)),
  mustard('Mustard', Color(0xFFFFBF02)),
  sunset('Sunset', Color(0xFFFF6E40)),
  caramel('Caramel', Color(0xFFF78204)),
  nordic('Nordic', Color(0xFF607D8B));

  const ThemeBase(this.title, this.seed);

  final String title;
  final Color seed;
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
  static const blurFilter = ImageFilter.blur(sigmaX: 5, sigmaY: 5);
  static const bouncyPhysics = AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

  static ColorScheme createColorScheme({
    required Color seed,
    required Brightness brightness,
    required bool highContrast,
  }) {
    if (brightness == Brightness.light) {
      final base = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
      if (highContrast) {
        return base.copyWith(
          surface: Colors.white,
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: const Color(0xFFF7F7F7),
          surfaceContainer: const Color(0xFFEFEFEF),
          surfaceContainerHigh: const Color(0xFFE5E5E5),
          surfaceContainerHighest: const Color(0xFFDBDBDB),
        );
      }
      return base;
    }

    final hsl = HSLColor.fromColor(seed);
    final vibrantPrimary = HSLColor.fromAHSL(
      1.0,
      hsl.hue,
      (hsl.saturation * 1.15).clamp(0.75, 1.0),
      hsl.lightness.clamp(0.60, 0.72),
    ).toColor();

    final primaryContainer = HSLColor.fromAHSL(
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

    final bgHue = hsl.hue;
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
    segmentedButtonTheme: const SegmentedButtonThemeData(
      style: ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
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
