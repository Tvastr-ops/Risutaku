import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/extension/card_extension.dart';
import 'package:risutaku/util/theming.dart';

typedef PieChart = SpieChart;

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
    required this.names,
    required this.values,
    required this.meanScore,
    this.toolbar,
    required this.highContrast,
    super.key,
  }) : assert(names.length == values.length);

  final String title;
  final List<String> names;
  final List<num> values;
  final double meanScore;
  final Widget? toolbar;
  final bool highContrast;

  String _formatScore(String raw) {
    final val = double.tryParse(raw);
    if (val == null) return raw;
    if (val > 10) {
      final dec = val / 10.0;
      return dec % 1 == 0 ? dec.toInt().toString() : dec.toStringAsFixed(1);
    }
    return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final maxValue = values.fold<num>(0, (prev, val) => val > prev ? val : prev);

    final displayMean = meanScore > 10
        ? (meanScore / 10.0).toStringAsFixed(2)
        : (meanScore > 0 ? meanScore.toStringAsFixed(2) : '—');

    int closestIdx = -1;
    double minDiff = double.infinity;
    for (int i = 0; i < names.length; i++) {
      final val = double.tryParse(names[i]);
      if (val != null && meanScore > 0) {
        final normalizedVal = val <= 10 ? val * 10 : val;
        final normalizedMean = meanScore <= 10 ? meanScore * 10 : meanScore;
        final diff = (normalizedVal - normalizedMean).abs();
        if (diff < minDiff) {
          minDiff = diff;
          closestIdx = i;
        }
      }
    }

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
                        '★ $displayMean Avg',
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
        if (toolbar != null) ...[
          SizedBox(width: double.infinity, child: toolbar!),
          const SizedBox(height: Theming.offset),
        ],
        CardExtension.highContrast(highContrast)(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useScroll = names.length > 10;
                final colWidth = useScroll
                    ? math.max(34.0, (constraints.maxWidth - 24) / names.length)
                    : null;

                Widget content = Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 0; i < names.length; i++) ...[
                      if (i > 0) SizedBox(width: useScroll ? 6 : 4),
                      useScroll
                          ? SizedBox(
                              width: colWidth,
                              child: _HistogramBar(
                                label: _formatScore(names[i]),
                                count: values[i],
                                maxCount: maxValue,
                                isMean: i == closestIdx,
                                colorScheme: colorScheme,
                              ),
                            )
                          : Expanded(
                              child: _HistogramBar(
                                label: _formatScore(names[i]),
                                count: values[i],
                                maxCount: maxValue,
                                isMean: i == closestIdx,
                                colorScheme: colorScheme,
                              ),
                            ),
                    ],
                  ],
                );

                return SizedBox(
                  height: 135,
                  child: useScroll
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: Theming.bouncyPhysics,
                          child: content,
                        )
                      : content,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HistogramBar extends StatelessWidget {
  const _HistogramBar({
    required this.label,
    required this.count,
    required this.maxCount,
    required this.isMean,
    required this.colorScheme,
  });

  final String label;
  final num count;
  final num maxCount;
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
            fontSize: 9.5,
            fontWeight: isMean ? FontWeight.w800 : FontWeight.w600,
            color: isMean ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isMean ? FontWeight.w800 : FontWeight.w500,
            color: isMean ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final spieSize = math.min(130.0, constraints.maxWidth * 0.40).clamp(90.0, 130.0);
                final centerBadgeSize = spieSize * 0.40;

                return Row(
                  children: [
                    // Spie Canvas with Center Metric
                    SizedBox(
                      width: spieSize,
                      height: spieSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size(spieSize, spieSize),
                            painter: _SpiePainter(
                              values: values,
                              radiiValues: radiiValues,
                              colors: colors,
                              outlineColor: colorScheme.surface,
                            ),
                          ),
                          // Center Hole Badge
                          Container(
                            width: centerBadgeSize,
                            height: centerBadgeSize,
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
                                    fontSize: centerBadgeSize > 45 ? 12 : 10,
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                if (centerBadgeSize > 42)
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
                    const SizedBox(width: 12),
                    // Legend
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < names.length; i++) ...[
                            if (i > 0) const SizedBox(height: 5),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colors[i],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    names[i],
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${values[i]}',
                                  style: TextStyle(
                                    fontSize: 11,
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
                );
              },
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

/// Interactive Line + Bar Timeline Chart with horizontal scroll
class ScrollableTimelineChart extends StatefulWidget {
  const ScrollableTimelineChart({
    required this.title,
    required this.years,
    required this.values,
    this.subtitles,
    this.toolbar,
    required this.highContrast,
    super.key,
  }) : assert(years.length == values.length);

  final String title;
  final List<String> years;
  final List<num> values;
  final List<String>? subtitles;
  final Widget? toolbar;
  final bool highContrast;

  @override
  State<ScrollableTimelineChart> createState() => _ScrollableTimelineChartState();
}

class _ScrollableTimelineChartState extends State<ScrollableTimelineChart> {
  final _scrollCtrl = ScrollController();
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients && _scrollCtrl.position.maxScrollExtent > 0) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ScrollableTimelineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _selectedIndex = null;
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const itemWidth = 44.0;
    const padding = 16.0;
    final totalWidth = padding * 2 + widget.years.length * itemWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(widget.title, style: theme.textTheme.titleSmall),
        ),
        if (widget.toolbar != null) ...[
          SizedBox(width: double.infinity, child: widget.toolbar!),
          const SizedBox(height: Theming.offset),
        ],
        CardExtension.highContrast(widget.highContrast)(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 190,
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                scrollDirection: Axis.horizontal,
                physics: Theming.bouncyPhysics,
                child: GestureDetector(
                  onTapDown: (details) {
                    final dx = details.localPosition.dx - padding;
                    if (dx >= 0) {
                      final idx = (dx / itemWidth).floor();
                      if (idx >= 0 && idx < widget.years.length) {
                        setState(() {
                          _selectedIndex = _selectedIndex == idx ? null : idx;
                        });
                      }
                    }
                  },
                  child: CustomPaint(
                    size: Size(math.max(totalWidth, MediaQuery.sizeOf(context).width - 32), 190),
                    painter: _TimelinePainter(
                      years: widget.years,
                      values: widget.values,
                      subtitles: widget.subtitles,
                      selectedIndex: _selectedIndex,
                      colorScheme: colorScheme,
                      itemWidth: itemWidth,
                      padding: padding,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    required this.years,
    required this.values,
    required this.subtitles,
    required this.selectedIndex,
    required this.colorScheme,
    required this.itemWidth,
    required this.padding,
  });

  final List<String> years;
  final List<num> values;
  final List<String>? subtitles;
  final int? selectedIndex;
  final ColorScheme colorScheme;
  final double itemWidth;
  final double padding;

  @override
  void paint(Canvas canvas, Size size) {
    if (years.isEmpty) return;

    final maxValue = values.fold<num>(0.0, (p, v) => v > p ? v : p);
    final topPadding = selectedIndex != null ? 36.0 : 20.0;
    const bottomPadding = 32.0;
    final graphHeight = size.height - topPadding - bottomPadding;
    final bottomY = size.height - bottomPadding;

    final points = <Offset>[];

    for (int i = 0; i < years.length; i++) {
      final x = padding + (i * itemWidth) + (itemWidth / 2);
      final ratio = maxValue > 0 ? (values[i] / maxValue).clamp(0.0, 1.0) : 0.0;
      final y = bottomY - (ratio * graphHeight);
      points.add(Offset(x, y));
    }

    // 1. Draw Subtle Vertical Pillar Bars
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isSelected = selectedIndex == i;

      final barRect = Rect.fromLTRB(p.dx - 4, p.dy, p.dx + 4, bottomY);
      final barPaint = Paint()
        ..color = isSelected
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(2.5)),
        barPaint,
      );
    }

    // 2. Draw Area Gradient & Glowing Curve Line
    if (points.length > 1) {
      final linePath = Path();
      final areaPath = Path();

      linePath.moveTo(points.first.dx, points.first.dy);
      areaPath.moveTo(points.first.dx, bottomY);
      areaPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlX = (p0.dx + p1.dx) / 2;

        linePath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
        areaPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      }

      areaPath.lineTo(points.last.dx, bottomY);
      areaPath.close();

      // Area gradient
      final areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withValues(alpha: 0.28),
            colorScheme.primary.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTRB(0, topPadding, size.width, bottomY))
        ..style = PaintingStyle.fill;

      canvas.drawPath(areaPath, areaPaint);

      // Stroke line
      final linePaint = Paint()
        ..color = colorScheme.primary
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(linePath, linePaint);
    }

    // 3. Draw Points & Tooltips & Year Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isSelected = selectedIndex == i;

      // Circle Dot
      final dotPaint = Paint()
        ..color = isSelected ? colorScheme.primary : colorScheme.surface
        ..style = PaintingStyle.fill;
      final ringPaint = Paint()
        ..color = isSelected ? colorScheme.onPrimary : colorScheme.primary
        ..strokeWidth = isSelected ? 2.5 : 1.8
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(p, isSelected ? 5.5 : 3.5, dotPaint);
      canvas.drawCircle(p, isSelected ? 5.5 : 3.5, ringPaint);

      // Year Label on bottom
      final yearStr = years[i];
      final label = yearStr.length == 4 && int.tryParse(yearStr) != null && int.parse(yearStr) >= 2000
          ? "'${yearStr.substring(2)}"
          : yearStr;

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(p.dx - (textPainter.width / 2), bottomY + 8),
      );

      // Floating Tooltip Bubble
      if (isSelected) {
        final valText = values[i] is double
            ? (values[i] as double).toStringAsFixed(1)
            : values[i].toString();
        final subText = subtitles != null && i < subtitles!.length ? ' • ${subtitles![i]}' : '';
        final tipString = '${years[i]}: $valText$subText';

        textPainter.text = TextSpan(
          text: tipString,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.onPrimary,
          ),
        );
        textPainter.layout();

        final bubbleWidth = textPainter.width + 16;
        const bubbleHeight = 24.0;
        final bubbleRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(p.dx, math.max(14, p.dy - 18)),
            width: bubbleWidth,
            height: bubbleHeight,
          ),
          const Radius.circular(12),
        );

        final bubblePaint = Paint()
          ..color = colorScheme.primary
          ..style = PaintingStyle.fill;

        canvas.drawRRect(bubbleRect, bubblePaint);
        textPainter.paint(
          canvas,
          Offset(p.dx - (textPainter.width / 2), math.max(14, p.dy - 18) - (textPainter.height / 2)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.values != values ||
      oldDelegate.years != years;
}

