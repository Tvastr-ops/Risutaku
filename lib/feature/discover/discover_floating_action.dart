import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/feature/discover/discover_filter_provider.dart';
import 'package:risutaku/feature/discover/discover_model.dart';
import 'package:risutaku/widget/input/cascading_pill_sheet.dart';
import 'package:risutaku/widget/swipe_switcher.dart';
import 'package:risutaku/widget/sheets.dart';

class DiscoverFloatingAction extends StatelessWidget {
  const DiscoverFloatingAction() : super(key: const Key('switchDiscover'));

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final type = ref.watch(discoverFilterProvider.select((s) => s.type));

        final items = DiscoverType.values
            .map(
              (v) => CascadingPillItem<DiscoverType>(
                value: v,
                label: v.label,
                icon: _typeIcon(v),
              ),
            )
            .toList();

        return FloatingActionButton(
          tooltip: 'Categories',
          onPressed: () {
            HapticFeedback.selectionClick();
            showSheet(
              context,
              SimpleSheet(
                builder: (context, _) => CascadingPillSheet<DiscoverType>(
                  title: 'Explore Categories',
                  items: items,
                  selectedValue: type,
                  onSelected: (selected) {
                    ref
                        .read(discoverFilterProvider.notifier)
                        .update((s) => s.copyWith(type: selected));
                  },
                ),
              ),
            );
          },
          child: SwipeSwitcher(
            index: type.index,
            onChanged: (index) {
              HapticFeedback.selectionClick();
              ref
                  .read(discoverFilterProvider.notifier)
                  .update((s) => s.copyWith(type: DiscoverType.values[index]));
            },
            children: DiscoverType.values.map((v) => Icon(_typeIcon(v))).toList(),
          ),
        );
      },
    );
  }

  static IconData _typeIcon(DiscoverType type) => switch (type) {
    .anime => LucideIcons.tv,
    .manga => LucideIcons.bookOpen,
    .character => LucideIcons.user,
    .staff => LucideIcons.mic,
    .studio => LucideIcons.building2,
    .user => LucideIcons.users,
    .review => LucideIcons.fileText,
    .recommendation => LucideIcons.thumbsUp,
  };
}
