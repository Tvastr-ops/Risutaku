import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/util/theming.dart';

class ChipGrid extends StatelessWidget {
  const ChipGrid({
    required this.title,
    required this.placeholder,
    required this.children,
    required this.onEdit,
    this.onClear,
  });

  final String title;
  final String placeholder;
  final List<Widget> children;
  final void Function() onEdit;
  final void Function()? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        Row(
          children: [
            Text(title),
            const Spacer(),
            if (onClear != null && children.isNotEmpty)
              SizedBox(
                height: 35,
                child: IconButton(
                  key: const ValueKey('Clear'),
                  icon: const Icon(LucideIcons.x),
                  tooltip: 'Clear',
                  onPressed: onClear!,
                  color: ColorScheme.of(context).onSurface,
                  padding: const .symmetric(horizontal: Theming.offset),
                ),
              ),
            SizedBox(
              height: 35,
              child: IconButton(
                icon: const Icon(LucideIcons.circlePlus),
                tooltip: 'Edit',
                onPressed: onEdit,
                color: ColorScheme.of(context).onSurface,
                padding: const .symmetric(horizontal: Theming.offset),
              ),
            ),
          ],
        ),
        children.isNotEmpty
            ? Wrap(spacing: 5, children: children)
            : SizedBox(
                height: Theming.minTapTarget,
                child: Center(
                  child: Text('No $placeholder', style: TextTheme.of(context).labelMedium),
                ),
              ),
      ],
    );
  }
}
