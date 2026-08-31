import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/feature/viewer/persistence_provider.dart';
import 'package:risutaku/widget/input/chip_selector.dart';
import 'package:risutaku/feature/media/media_models.dart';
import 'package:risutaku/feature/studio/studio_filter_provider.dart';
import 'package:risutaku/util/theming.dart';
import 'package:risutaku/widget/sheets.dart';

class StudioFilterButton extends StatelessWidget {
  const StudioFilterButton(this.id, this.ref);

  final int id;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Filter',
      heroTag: 'filter',
      child: const Icon(LucideIcons.slidersHorizontal),
      onPressed: () {
        var filter = ref.read(studioFilterProvider(id));
        final onDone = (_) => ref.read(studioFilterProvider(id).notifier).state = filter;
        final highContrast = ref.watch(persistenceProvider.select((s) => s.options.highContrast));

        showSheet(
          context,
          SimpleSheet(
            initialHeight: Theming.normalTapTarget * 4 + MediaQuery.paddingOf(context).bottom + 40,
            builder: (context, scrollCtrl) => ListView(
              controller: scrollCtrl,
              physics: Theming.bouncyPhysics,
              padding: const .symmetric(horizontal: Theming.offset, vertical: 20),
              children: [
                ChipSelector.ensureSelected(
                  title: 'Sort',
                  items: MediaSort.values.map((v) => (v.label, v)).toList(),
                  value: filter.sort,
                  onChanged: (v) => filter = filter.copyWith(sort: v),
                  highContrast: highContrast,
                ),
                ChipSelector(
                  title: 'List Presence',
                  items: const [('In Lists', true), ('Not in Lists', false)],
                  value: filter.inLists,
                  onChanged: (v) => filter = filter.copyWith(inLists: (v,)),
                  highContrast: highContrast,
                ),
                ChipSelector(
                  title: 'Main Studio',
                  items: const [('Is Main', true), ('Is Not Main', false)],
                  value: filter.isMain,
                  onChanged: (v) => filter = filter.copyWith(isMain: (v,)),
                  highContrast: highContrast,
                ),
              ],
            ),
          ),
        ).then(onDone);
      },
    );
  }
}
