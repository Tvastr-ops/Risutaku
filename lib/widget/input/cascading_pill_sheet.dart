import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:risutaku/util/theming.dart';

class CascadingPillItem<T> {
  const CascadingPillItem({
    required this.value,
    required this.label,
    this.count,
    this.icon,
  });

  final T value;
  final String label;
  final String? count;
  final IconData? icon;
}

class CascadingPillSheet<T> extends StatelessWidget {
  const CascadingPillSheet({
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    super.key,
  });

  final String title;
  final List<CascadingPillItem<T>> items;
  final T selectedValue;
  final void Function(T value) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final padding = MediaQuery.paddingOf(context);

    return SingleChildScrollView(
      physics: Theming.bouncyPhysics,
      padding: EdgeInsets.only(
        left: padding.left + Theming.offset * 1.5,
        right: padding.right + Theming.offset * 1.5,
        top: Theming.offset * 1.5,
        bottom: padding.bottom + Theming.offset * 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: Theming.offset),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Theming.offset * 1.2),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: items.map((item) {
              final isSelected = item.value == selectedValue;

              return Material(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelected(item.value);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.icon != null) ...[
                          Icon(
                            item.icon,
                            size: 16,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          item.label,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                          ),
                        ),
                        if (item.count != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.onPrimary.withValues(alpha: 0.2)
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.count!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
