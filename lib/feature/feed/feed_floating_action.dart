import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risutaku/feature/activity/activities_model.dart';
import 'package:risutaku/feature/activity/activities_provider.dart';
import 'package:risutaku/feature/composition/composition_model.dart';
import 'package:risutaku/feature/composition/composition_view.dart';
import 'package:risutaku/widget/sheets.dart';

class FeedFloatingAction extends StatelessWidget {
  const FeedFloatingAction(this.ref) : super(key: const Key('newPost'));

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'New Post',
      child: const Icon(Icons.edit_outlined),
      onPressed: () => showSheet(
        context,
        CompositionView(
          tag: const StatusActivityCompositionTag(id: null),
          onSaved: (map) =>
              ref.read(activitiesProvider(HomeActivitiesTag.instance).notifier).prepend(map),
        ),
      ),
    );
  }
}
