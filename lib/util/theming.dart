import 'dart:ui';

import 'package:flutter/material.dart';

enum FormFactor { phone, tablet }

enum ThemeBase {
  greenApple('Green Apple', Color(0xFF4CAF50)),
  midnightDusk('Midnight Dusk', Color(0xFF7E57C2)),
  nordic('Nordic Slate', Color(0xFF546E7A)),
  cobalt('Cobalt Blue', Color(0xFF0288D1)),
  strawberry('Strawberry', Color(0xFFE53935)),
  tangerine('Tangerine', Color(0xFFFF6D00)),
  sakura('Sakura', Color(0xFFEC407A)),
  teal('Teal Breeze', Color(0xFF00BFA5)),
  monochrome('Monochrome', Color(0xFF757575));

  const ThemeBase(this.title, this.seed);

  final String title;
  final Color seed;

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
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    );

    if (brightness == Brightness.light) {
      if (highContrast) {
        return baseScheme.copyWith(
          surface: Colors.white,
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: const Color(0xFFF7F7F7),
          surfaceContainer: const Color(0xFFEFEFEF),
          surfaceContainerHigh: const Color(0xFFE5E5E5),
          surfaceContainerHighest: const Color(0xFFDBDBDB),
          outline: baseScheme.primary.withValues(alpha: 0.40),
          outlineVariant: const Color(0xFFD0D0D0),
        );
      }
      return baseScheme;
    }

    // Dark Mode
    if (highContrast) {
      // True AMOLED Pure Black mode
      return baseScheme.copyWith(
        surface: Colors.black,
        surfaceContainerLowest: Colors.black,
        surfaceContainerLow: const Color(0xFF0A0A0A),
        surfaceContainer: const Color(0xFF111111),
        surfaceContainerHigh: const Color(0xFF181818),
        surfaceContainerHighest: const Color(0xFF222222),
        outline: baseScheme.primary.withValues(alpha: 0.35),
        outlineVariant: const Color(0xFF2A2A2A),
      );
    }

    return baseScheme;
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
