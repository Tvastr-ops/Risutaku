import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/feature/activity/activities_filter_model.dart';
import 'package:risutaku/feature/activity/activities_model.dart';
import 'package:risutaku/util/theming.dart';
import 'package:risutaku/widget/sheets.dart';
import 'package:risutaku/feature/activity/activities_filter_provider.dart';

void showActivityFilterSheet(BuildContext context, WidgetRef ref, ActivitiesTag tag) {
  ActivitiesFilter filter = ref.read(activitiesFilterProvider(tag));
  double initialHeight = Theming.normalTapTarget * ActivityType.values.length + Theming.offset;

  if (filter is HomeActivitiesFilter) {
    initialHeight += Theming.normalTapTarget * 2.5;
  }

  showSheet(
    context,
    SimpleSheet(
      initialHeight: initialHeight,
      builder: (context, scrollCtrl) => _ActivityFilterSheet(
        scrollCtrl: scrollCtrl,
        filter: filter,
        onChanged: (filter) => ref.read(activitiesFilterProvider(tag).notifier).state = filter,
      ),
    ),
  );
}

class _ActivityFilterSheet extends StatefulWidget {
  const _ActivityFilterSheet({
    required this.scrollCtrl,
    required this.filter,
    required this.onChanged,
  });

  final ScrollController scrollCtrl;
  final ActivitiesFilter filter;
  final void Function(ActivitiesFilter) onChanged;

  @override
  State<_ActivityFilterSheet> createState() => _ActivityFilterSheetState();
}

class _ActivityFilterSheetState extends State<_ActivityFilterSheet> {
  late ActivitiesFilter _filter = widget.filter.copy();

  @override
  Widget build(BuildContext context) {
    final typeIn = switch (_filter) {
      HomeActivitiesFilter(:final typeIn) => typeIn,
      UserActivitiesFilter(:final typeIn) => typeIn,
      MediaActivitiesFilter _ => [],
    };

    return ListView(
      controller: widget.scrollCtrl,
      physics: Theming.bouncyPhysics,
      padding: const EdgeInsets.symmetric(vertical: Theming.offset),
      children: [
        for (final a in ActivityType.values)
          CheckboxListTile(
            title: Text(a.label),
            value: typeIn.contains(a),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  typeIn.add(a);
                } else if (val == false) {
                  typeIn.remove(a);
                }
              });

              widget.onChanged(_filter.copy());
            },
          ),
        ...switch (_filter) {
          UserActivitiesFilter _ || MediaActivitiesFilter _ => const [],
          HomeActivitiesFilter filter => [
            const Divider(),
            CheckboxListTile(
              title: const Text('My Activities'),
              value: filter.withViewerActivities,
              onChanged: (v) {
                setState(() => _filter = filter.copyWith(withViewerActivities: v!));

                widget.onChanged(_filter.copy());
              },
            ),
            Padding(
              padding: const .only(
                top: Theming.offset,
                left: Theming.offset,
                right: Theming.offset,
              ),
              child: SegmentedButton(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('Following'),
                    icon: Icon(LucideIcons.users),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('Global'),
                    icon: Icon(LucideIcons.globe),
                  ),
                ],
                selected: {filter.onFollowing},
                onSelectionChanged: (v) {
                  setState(() => _filter = filter.copyWith(onFollowing: v.first));

                  widget.onChanged(_filter.copy());
                },
              ),
            ),
          ],
        },
      ],
    );
  }
}
