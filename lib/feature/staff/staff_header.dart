import 'package:flutter/material.dart';
import 'package:risutaku/extension/snack_bar_extension.dart';
import 'package:risutaku/feature/staff/staff_model.dart';
import 'package:risutaku/util/theming.dart';
import 'package:risutaku/widget/layout/content_header.dart';
import 'package:risutaku/widget/table_list.dart';

class StaffHeader extends StatelessWidget {
  const StaffHeader.withTabBar({
    required this.id,
    required this.imageUrl,
    required this.staff,
    required this.tabCtrl,
    required this.scrollToTop,
    required this.toggleFavorite,
    required this.highContrast,
  });

  const StaffHeader.withoutTabBar({
    required this.id,
    required this.imageUrl,
    required this.staff,
    required this.toggleFavorite,
    required this.highContrast,
  }) : tabCtrl = null,
       scrollToTop = null;

  final int id;
  final String? imageUrl;
  final Staff? staff;
  final TabController? tabCtrl;
  final void Function()? scrollToTop;
  final Future<Object?> Function() toggleFavorite;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return ContentHeader(
      imageUrl: imageUrl ?? staff?.imageUrl,
      imageHeightToWidthRatio: Theming.coverHtoWRatio,
      imageHeroTag: id,
      siteUrl: staff?.siteUrl,
      title: staff?.preferredName,
      details: staff != null
          ? [
              TableList([
                ('Favorites', staff!.favorites.toString()),
                if (staff!.gender != null) ('Gender', staff!.gender!),
              ], highContrast: highContrast),
            ]
          : const [],
      tabBarConfig: tabCtrl != null && scrollToTop != null
          ? (tabCtrl: tabCtrl!, scrollToTop: scrollToTop!, tabs: tabsWithOverview)
          : null,
      trailingTopButtons: [if (staff != null) _FavoriteButton(staff!, toggleFavorite)],
    );
  }

  static const tabsWithoutOverview = [Tab(text: 'Characters'), Tab(text: 'Roles')];

  static const tabsWithOverview = [Tab(text: 'Overview'), ...tabsWithoutOverview];
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton(this.staff, this.toggleFavorite);

  final Staff staff;
  final Future<Object?> Function() toggleFavorite;

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final staff = widget.staff;

    return IconButton(
      tooltip: staff.isFavorite ? 'Unfavourite' : 'Favourite',
      icon: staff.isFavorite ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
      onPressed: () async {
        setState(() => staff.isFavorite = !staff.isFavorite);

        final err = await widget.toggleFavorite();
        if (err == null) return;

        setState(() => staff.isFavorite = !staff.isFavorite);
        if (context.mounted) SnackBarExtension.show(context, err.toString());
      },
    );
  }
}
