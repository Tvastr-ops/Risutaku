import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:risutaku/feature/media/media_models.dart';
import 'package:risutaku/util/routes.dart';
import 'package:risutaku/widget/grid/mono_relation_grid.dart';
import 'package:risutaku/widget/paged_view.dart';
import 'package:risutaku/feature/media/media_provider.dart';

class MediaStaffSubview extends StatelessWidget {
  const MediaStaffSubview({required this.id, required this.scrollCtrl, required this.highContrast});

  final int id;
  final ScrollController scrollCtrl;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return PagedView<MediaRelatedItem>(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(mediaConnectionsProvider(id)),
      provider: mediaConnectionsProvider(
        id,
      ).select((s) => s.unwrapPrevious().whenData((data) => data.staff)),
      onData: (data) => MonoRelationGrid(
        items: data.items,
        onTap: (item) => context.push(Routes.staff(item.tileId, item.tileImageUrl)),
        highContrast: highContrast,
      ),
    );
  }
}
