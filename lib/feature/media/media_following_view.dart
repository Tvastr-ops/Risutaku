import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:risutaku/extension/build_context_extension.dart';
import 'package:risutaku/extension/card_extension.dart';
import 'package:risutaku/util/routes.dart';
import 'package:risutaku/util/theming.dart';
import 'package:risutaku/widget/cached_image.dart';
import 'package:risutaku/widget/input/note_label.dart';
import 'package:risutaku/widget/input/score_label.dart';
import 'package:risutaku/widget/grid/sliver_grid_delegates.dart';
import 'package:risutaku/widget/paged_view.dart';
import 'package:risutaku/feature/media/media_models.dart';
import 'package:risutaku/feature/media/media_provider.dart';

class MediaFollowingSubview extends StatelessWidget {
  const MediaFollowingSubview({
    required this.id,
    required this.scrollCtrl,
    required this.highContrast,
  });

  final int id;
  final ScrollController scrollCtrl;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return PagedView(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(mediaFollowingProvider(id)),
      provider: mediaFollowingProvider(id),
      onData: (data) => _MediaFollowingGrid(data.items, highContrast),
    );
  }
}

class _MediaFollowingGrid extends StatelessWidget {
  const _MediaFollowingGrid(this.items, this.highContrast);

  final List<MediaFollowing> items;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final bodyMediumLineHeight = context.lineHeight(TextTheme.of(context).bodyMedium!);
    final tileHeight = bodyMediumLineHeight + max(bodyMediumLineHeight, 35) + 5;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(minWidth: 300, height: tileHeight),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => GestureDetector(
          behavior: .opaque,
          onTap: () => context.push(Routes.user(items[i].userId, items[i].userAvatar)),
          child: CardExtension.highContrast(highContrast)(
            child: Row(
              children: [
                Hero(
                  tag: items[i].userId,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Theming.radiusSmall),
                    child: CachedImage(items[i].userAvatar, width: tileHeight),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const .only(top: 5, left: Theming.offset, right: Theming.offset),
                    child: Column(
                      mainAxisAlignment: .spaceBetween,
                      crossAxisAlignment: .start,
                      children: [
                        Text(items[i].userName, overflow: .ellipsis, maxLines: 1),
                        SizedBox(
                          height: 35,
                          child: Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  items[i].entryStatus.label(null),
                                  overflow: .ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              NotesLabel(items[i].notes),
                              ScoreLabel(items[i].score, items[i].scoreFormat),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
