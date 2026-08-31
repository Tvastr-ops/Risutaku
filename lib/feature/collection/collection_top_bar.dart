import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/feature/collection/collection_entries_provider.dart';
import 'package:risutaku/feature/collection/collection_filter_provider.dart';
import 'package:risutaku/feature/collection/collection_models.dart';
import 'package:risutaku/feature/collection/collection_provider.dart';
import 'package:risutaku/feature/collection/collection_filter_view.dart';
import 'package:risutaku/feature/viewer/persistence_provider.dart';
import 'package:risutaku/util/routes.dart';
import 'package:risutaku/util/debounce.dart';
import 'package:risutaku/widget/input/search_field.dart';
import 'package:risutaku/widget/dialogs.dart';
import 'package:risutaku/widget/sheets.dart';

class CollectionTopBarTrailingContent extends StatelessWidget {
  const CollectionTopBarTrailingContent(this.tag, this.focusNode);

  final CollectionTag tag;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final filter = ref.watch(collectionFilterProvider(tag));

        final filterIcon = IconButton(
          tooltip: 'Filter',
          icon: const Icon(LucideIcons.slidersHorizontal),
          onPressed: () => showSheet(
            context,
            CollectionFilterView(
              tag: tag,
              filter: filter.mediaFilter,
              onChanged: (mediaFilter) => ref
                  .read(collectionFilterProvider(tag).notifier)
                  .update((s) => s.copyWith(mediaFilter: mediaFilter)),
            ),
          ),
        );

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: SearchField(
                  debounce: Debounce(),
                  focusNode: focusNode,
                  hint: ref.watch(collectionProvider(tag).select((s) => s.value?.listName ?? '')),
                  value: filter.search,
                  onChanged: (search) => ref
                      .read(collectionFilterProvider(tag).notifier)
                      .update((s) => s.copyWith(search: search)),
                ),
              ),
              IconButton(
                tooltip: 'Random',
                icon: const Icon(LucideIcons.shuffle),
                onPressed: () {
                  final lists = ref.read(collectionEntriesProvider(tag));
                  if (lists.isEmpty) {
                    ConfirmationDialog.show(context, title: 'No entries');
                    return;
                  }

                  final list = lists[Random().nextInt(lists.length)];
                  if (list.entries.isEmpty) {
                    ConfirmationDialog.show(context, title: 'No entries');
                    return;
                  }

                  final entry = list.entries[Random().nextInt(list.entries.length)];
                  context.push(Routes.media(entry.mediaId, entry.imageUrl));
                },
              ),
              IconButton(
                tooltip: ref.watch(
                  persistenceProvider.select(
                    (s) => s.options.collectionItemView == CollectionItemView.simple
                        ? 'Switch to List View'
                        : 'Switch to Grid View',
                  ),
                ),
                icon: Icon(
                  ref.watch(
                    persistenceProvider.select(
                      (s) => s.options.collectionItemView == CollectionItemView.simple
                          ? LucideIcons.list
                          : LucideIcons.layoutGrid,
                    ),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  final current = ref.read(persistenceProvider).options;
                  final nextView = current.collectionItemView == CollectionItemView.simple
                      ? CollectionItemView.detailed
                      : CollectionItemView.simple;
                  ref.read(persistenceProvider.notifier).setOptions(
                    current.copyWith(collectionItemView: nextView),
                  );
                },
              ),
              if (filter.mediaFilter.isActive)
                Badge(
                  smallSize: 10,
                  alignment: Alignment.topLeft,
                  backgroundColor: ColorScheme.of(context).primary,
                  child: filterIcon,
                )
              else
                filterIcon,
            ],
          ),
        );
      },
    );
  }
}
