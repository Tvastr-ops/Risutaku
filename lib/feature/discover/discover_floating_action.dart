import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/feature/discover/discover_filter_provider.dart';
import 'package:risutaku/feature/discover/discover_model.dart';
import 'package:risutaku/widget/input/pill_selector.dart';
import 'package:risutaku/widget/swipe_switcher.dart';
import 'package:risutaku/widget/sheets.dart';

class DiscoverFloatingAction extends StatelessWidget {
  const DiscoverFloatingAction() : super(key: const Key('switchDiscover'));

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final type = ref.watch(discoverFilterProvider.select((s) => s.type));

        return FloatingActionButton(
          tooltip: 'Types',
          onPressed: () {
            showSheet(
              context,
              SimpleSheet(
                initialHeight: PillSelector.expectedMinHeight(DiscoverType.values.length),
                builder: (context, scrollCtrl) => PillSelector(
                  scrollCtrl: scrollCtrl,
                  selected: type.index,
                  items: DiscoverType.values.map((v) => Text(v.label)).toList(),
                  onTap: (i) {
                    HapticFeedback.selectionClick();
                    ref
                        .read(discoverFilterProvider.notifier)
                        .update((s) => s.copyWith(type: DiscoverType.values[i]));
                    Navigator.pop(context);
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
