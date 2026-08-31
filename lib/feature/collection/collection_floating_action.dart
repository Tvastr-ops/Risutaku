import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/feature/collection/collection_models.dart';
import 'package:risutaku/feature/collection/collection_provider.dart';
import 'package:risutaku/feature/home/home_provider.dart';
import 'package:risutaku/widget/input/cascading_pill_sheet.dart';
import 'package:risutaku/widget/swipe_switcher.dart';
import 'package:risutaku/widget/sheets.dart';

class CollectionFloatingAction extends StatelessWidget {
  CollectionFloatingAction(this.tag) : super(key: Key('${tag.userId}${tag.ofAnime}'));

  final CollectionTag tag;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final collection = ref.watch(
          collectionProvider(tag).select((s) => s.unwrapPrevious().value),
        );

        return switch (collection) {
          null => const SizedBox(),
          PreviewCollection _ => FloatingActionButton(
            tooltip: 'Load Entire Collection',
            child: const Icon(LucideIcons.arrowDownToLine),
            onPressed: () => ref.read(homeProvider.notifier).expandCollection(tag.ofAnime),
          ),
          FullCollection c => _fullCollectionActionButton(context, ref, c.lists, c.index),
        };
      },
    );
  }

  Widget _fullCollectionActionButton(
    BuildContext context,
    WidgetRef ref,
    List<EntryList> lists,
    int index,
  ) {
    final allCount = lists.fold(0, (v, l) => v + l.entries.length);

    // Build items with original indices
    final rawItems = [
      (
        item: CascadingPillItem<int>(
          value: -1,
          label: 'All',
          count: allCount.toString(),
          icon: LucideIcons.layers,
        ),
        priority: 0,
        originalIndex: 0,
      ),
      for (int i = 0; i < lists.length; i++)
        (
          item: CascadingPillItem<int>(
            value: i,
            label: lists[i].name,
            count: lists[i].entries.length.toString(),
            icon: _listIcon(lists[i].name),
          ),
          priority: _listPriority(lists[i].name),
          originalIndex: i + 1,
        ),
    ];

    // Sort by priority so standard AniList lists are at the top
    rawItems.sort((a, b) {
      final pComp = a.priority.compareTo(b.priority);
      if (pComp != 0) return pComp;
      return a.originalIndex.compareTo(b.originalIndex);
    });

    final sortedItems = rawItems.map((e) => e.item).toList();

    return FloatingActionButton(
      tooltip: 'Lists',
      onPressed: () {
        HapticFeedback.selectionClick();
        showSheet(
          context,
          SimpleSheet(
            builder: (context, _) => CascadingPillSheet<int>(
              title: 'Select List',
              items: sortedItems,
              selectedValue: index,
              onSelected: (val) {
                ref.read(collectionProvider(tag).notifier).changeIndex(val);
              },
            ),
          ),
        );
      },
      child: SwipeSwitcher(
        index: index + 1,
        children: List.filled(lists.length + 1, const Icon(LucideIcons.listFilter)),
        onChanged: (index) => ref.read(collectionProvider(tag).notifier).changeIndex(index - 1),
      ),
    );
  }

  static int _listPriority(String name) {
    final lower = name.toLowerCase().trim();
    if (lower == 'all') return 0;
    if (lower.contains('watch') || lower.contains('read') || lower == 'current') return 1;
    if (lower.contains('complete')) return 2;
    if (lower.contains('plan')) return 3;
    if (lower.contains('pause') || lower.contains('hold')) return 4;
    if (lower.contains('drop')) return 5;
    return 100;
  }

  static IconData _listIcon(String name) {
    final lower = name.toLowerCase().trim();
    if (lower.contains('watch') || lower.contains('read') || lower == 'current') {
      return LucideIcons.play;
    }
    if (lower.contains('complete')) return LucideIcons.checkCheck;
    if (lower.contains('plan')) return LucideIcons.bookmark;
    if (lower.contains('pause') || lower.contains('hold')) return LucideIcons.pause;
    if (lower.contains('drop')) return LucideIcons.x;
    return LucideIcons.list;
  }
}

List<Widget> buildFullCollectionSelectionItems(BuildContext context, List<EntryList> lists) {
  final listItems = [
    (name: 'All', count: lists.fold(0, (v, l) => v + l.entries.length).toString()),
    ...lists.map((l) => (name: l.name, count: l.entries.length.toString())),
  ];

  final listItemToWidget = (({String name, String count}) item) => Row(
    spacing: 5,
    children: [
      Expanded(child: Text(item.name)),
      Text(item.count, style: TextTheme.of(context).labelMedium),
    ],
  );

  return listItems.map(listItemToWidget).toList();
}
