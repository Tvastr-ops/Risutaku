import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/extension/card_extension.dart';
import 'package:risutaku/util/theming.dart';

class BarChart extends StatelessWidget {
  const BarChart({required this.title, required this.names, required this.values, this.toolbar})
    : assert(names.length == values.length);

  final String title;
  final List<String> names;
  final List<num> values;
  final Widget? toolbar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBarWidth = constraints.maxWidth;
        double scale(num value) => value > 0 ? math.log(value + 0.1) : 0;

        final maxValue = values.fold<num>(0.0, (prev, element) => element > prev ? element : prev);
        final scaledMaxValue = scale(maxValue);

        final totalValue = values.fold(0.0, (sum, value) => sum + value);

        return Column(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: const .symmetric(vertical: 5),
              child: Text(title, style: textTheme.titleSmall),
            ),
            if (toolbar != null) ...[
              SizedBox(width: double.infinity, child: toolbar!),
              const SizedBox(height: Theming.offset),
            ],
            for (int i = 0; i < names.length; i++)
              Padding(
                padding: const .symmetric(vertical: 3),
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 1,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(names[i], style: textTheme.labelMedium, textAlign: .left),
                        ),
                        Expanded(
                          child: Text(
                            "${(totalValue > 0 ? (values[i] / totalValue * 100) : 0).toStringAsFixed(1)}%",
                            style: textTheme.labelMedium,
                            textAlign: .center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${values[i]}",
                            style: textTheme.labelMedium,
                            textAlign: .right,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 10,
                      width: maxBarWidth,
                      decoration: BoxDecoration(
                        borderRadius: Theming.borderRadiusSmall,
                        color: colorScheme.surfaceContainerLowest,
                        border: .all(color: colorScheme.outlineVariant, width: 1),
                      ),
                      alignment: .centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: scaledMaxValue > 0 ? (scale(values[i]) / scaledMaxValue) * maxBarWidth : 0,
                        decoration: BoxDecoration(
                          borderRadius: Theming.borderRadiusSmall,
                          gradient: LinearGradient(
                            begin: .centerLeft,
                            end: .centerRight,
                            colors: [colorScheme.primaryContainer, colorScheme.primary],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// 10-Column Vertical Score Histogram (Bell Curve)
class ScoreHistogram extends StatelessWidget {
  const ScoreHistogram({
    required this.title,
    required this.scores,
    required this.meanScore,
    required this.highContrast,
    super.key,
  });

  final String title;
  final Map<int, int> scores; // Score 1..10 -> count
  final double meanScore;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final maxCount = scores.values.fold<int>(0, (prev, val) => val > prev ? val : prev);
    final roundedMean = meanScore.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              if (meanScore > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: Theming.borderRadiusSmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.star, size: 13, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${meanScore.toStringAsFixed(1)} Avg',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        CardExtension.highContrast(highContrast)(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
            child: SizedBox(
              height: 125,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int score = 1; score <= 10; score++) ...[
                    if (score > 1) const SizedBox(width: 6),
                    Expanded(
                      child: _HistogramBar(
                        score: score,
                        count: scores[score] ?? 0,
                        maxCount: maxCount,
                        isMean: score == roundedMean && meanScore > 0,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistogramBar extends StatelessWidget {
  const _HistogramBar({
    required this.score,
    required this.count,
    required this.maxCount,
    required this.isMean,
    required this.colorScheme,
  });

  final int score;
  final int count;
  final int maxCount;
  final bool isMean;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final fillHeight = maxCount > 0 ? (count / maxCount * 70).clamp(4.0, 70.0) : 4.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          count > 0 ? count.toString() : '',
          style: TextStyle(
            fontSize: 10,
            fontWeight: isMean ? FontWeight.w800 : FontWeight.w500,
            color: isMean ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: fillHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: isMean
                ? LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [colorScheme.primary, colorScheme.primaryContainer],
                  )
                : count > 0
                    ? LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          colorScheme.surfaceContainerHighest,
                          colorScheme.surfaceContainerHigh,
                        ],
                      )
                    : null,
            color: count == 0 ? colorScheme.surfaceContainerLowest : null,
            border: isMean
                ? Border.all(color: colorScheme.primary, width: 1.5)
                : Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 1),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: isMean ? FontWeight.w800 : FontWeight.w600,
            color: isMean ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Dynamic Spie Chart (Varying Slice Angle & Radii Bloom)
class SpieChart extends StatelessWidget {
  const SpieChart({
    required this.title,
    required this.names,
    required this.values,
    this.radiiValues,
    required this.highContrast,
    super.key,
  }) : assert(names.length == values.length);

  final String title;
  final List<String> names;
  final List<int> values;
  final List<num>? radiiValues;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final total = values.fold<int>(0, (prev, val) => prev + val);

    final colors = _generatePalette(colorScheme, names.length);

    int dominantIndex = 0;
    int dominantMax = 0;
    for (int i = 0; i < values.length; i++) {
      if (values[i] > dominantMax) {
        dominantMax = values[i];
        dominantIndex = i;
      }
    }
    final dominantPct = total > 0 ? (dominantMax / total * 100).toStringAsFixed(0) : '0';
    final dominantLabel = names.isNotEmpty ? names[dominantIndex] : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        CardExtension.highContrast(highContrast)(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Spie Canvas with Center Metric
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(140, 140),
                        painter: _SpiePainter(
                          values: values,
                          radiiValues: radiiValues,
                          colors: colors,
                          outlineColor: colorScheme.surface,
                        ),
                      ),
                      // Center Hole Badge
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dominantPct%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.primary,
                              ),
                            ),
                            Text(
                              dominantLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < names.length; i++) ...[
                        if (i > 0) const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colors[i],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                names[i],
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${values[i]}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static List<Color> _generatePalette(ColorScheme scheme, int count) {
    if (count == 0) return [];
    final baseHsl = HSLColor.fromColor(scheme.primary);
    final palette = <Color>[];

    for (int i = 0; i < count; i++) {
      final hue = (baseHsl.hue + (i * 360 / count)) % 360;
      palette.add(HSLColor.fromAHSL(1.0, hue, 0.75, 0.55).toColor());
    }
    return palette;
  }
}

class _SpiePainter extends CustomPainter {
  _SpiePainter({
    required this.values,
    required this.radiiValues,
    required this.colors,
    required this.outlineColor,
  });

  final List<int> values;
  final List<num>? radiiValues;
  final List<Color> colors;
  final Color outlineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<int>(0, (prev, val) => prev + val);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 4;
    const innerRadius = 28.0;

    num maxRadiiVal = 1.0;
    if (radiiValues != null && radiiValues!.isNotEmpty) {
      maxRadiiVal = radiiValues!.fold<num>(1.0, (p, v) => v > p ? v : p);
    }

    double currentAngle = -math.pi / 2;
    const gapAngle = 0.04;

    for (int i = 0; i < values.length; i++) {
      final share = values[i] / total;
      final sweepAngle = (share * 2 * math.pi) - gapAngle;

      if (sweepAngle <= 0) continue;

      double sliceRadius = maxRadius;
      if (radiiValues != null && i < radiiValues!.length && maxRadiiVal > 0) {
        final rRatio = (radiiValues![i] / maxRadiiVal).clamp(0.4, 1.0);
        sliceRadius = innerRadius + (rRatio * (maxRadius - innerRadius));
      }

      final startAngle = currentAngle + (gapAngle / 2);

      final path = Path()
        ..arcTo(
          Rect.fromCircle(center: center, radius: sliceRadius),
          startAngle,
          sweepAngle,
          false,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: innerRadius),
          startAngle + sweepAngle,
          -sweepAngle,
          false,
        )
        ..close();

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);

      currentAngle += share * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(covariant _SpiePainter oldDelegate) => true;
}
