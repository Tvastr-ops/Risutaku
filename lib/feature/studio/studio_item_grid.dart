import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:risutaku/extension/build_context_extension.dart';
import 'package:risutaku/extension/card_extension.dart';
import 'package:risutaku/feature/studio/studio_item_model.dart';
import 'package:risutaku/util/routes.dart';
import 'package:risutaku/util/theming.dart';
import 'package:risutaku/widget/grid/sliver_grid_delegates.dart';

class StudioItemGrid extends StatelessWidget {
  const StudioItemGrid(this.items, {required this.highContrast});

  final List<StudioItem> items;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final lineHeight = context.lineHeight(TextTheme.of(context).bodyMedium!);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 230,
        height: lineHeight + 20,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (_, i) => InkWell(
          borderRadius: Theming.borderRadiusSmall,
          onTap: () => context.push(Routes.studio(items[i].id, items[i].name)),
          child: CardExtension.highContrast(highContrast)(
            child: Padding(
              padding: Theming.paddingAll,
              child: Hero(
                tag: items[i].id,
                child: Text(
                  items[i].name,
                  style: TextTheme.of(context).bodyMedium,
                  overflow: .ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
