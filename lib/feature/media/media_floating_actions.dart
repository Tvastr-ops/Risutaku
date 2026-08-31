import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risutaku/feature/collection/collection_models.dart';
import 'package:risutaku/feature/media/media_models.dart';
import 'package:risutaku/feature/viewer/repository_provider.dart';
import 'package:risutaku/util/graphql.dart';
import 'package:risutaku/widget/quick_action_dock.dart';

class MediaEditButton extends ConsumerStatefulWidget {
  const MediaEditButton(this.media);

  final Media media;

  @override
  ConsumerState<MediaEditButton> createState() => _MediaEditButtonState();
}

class _MediaEditButtonState extends ConsumerState<MediaEditButton> {
  @override
  Widget build(BuildContext context) {
    final media = widget.media;

    return QuickActionDock(
      media: media,
      onProgressIncrement: () async {
        final entry = media.entryEdit;
        final newProgress = entry.progress + 1;
        final maxCount = media.info.isAnime ? media.info.episodes : media.info.chapters;
        final isCompleted = maxCount != null && newProgress >= maxCount;

        setState(() {
          media.entryEdit = entry.copyWith(
            progress: newProgress,
            listStatus: isCompleted ? ListStatus.completed : (entry.listStatus ?? ListStatus.current),
          );
        });

        try {
          await ref.read(repositoryProvider).request(GqlMutation.updateProgress, {
            'mediaId': media.info.id,
            'progress': newProgress,
            if (isCompleted) 'status': ListStatus.completed.value,
          });
        } catch (_) {}
      },
      onEditComplete: (entryEdit) => setState(() => media.entryEdit = entryEdit),
    );
  }
}
