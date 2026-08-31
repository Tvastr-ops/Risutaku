import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/feature/character/character_item_grid.dart';
import 'package:risutaku/feature/discover/discover_filter_provider.dart';
import 'package:risutaku/feature/discover/discover_media_grid.dart';
import 'package:risutaku/feature/discover/discover_media_simple_grid.dart';
import 'package:risutaku/feature/discover/discover_model.dart';
import 'package:risutaku/feature/discover/discover_provider.dart';
import 'package:risutaku/feature/discover/discover_recommendations_grid.dart';
import 'package:risutaku/feature/staff/staff_item_grid.dart';
import 'package:risutaku/feature/studio/studio_item_grid.dart';
import 'package:risutaku/feature/user/user_item_grid.dart';
import 'package:risutaku/feature/review/review_grid.dart';
import 'package:risutaku/feature/viewer/persistence_provider.dart';
import 'package:risutaku/util/theming.dart';
import 'package:risutaku/widget/input/pill_selector.dart';
import 'package:risutaku/widget/paged_view.dart';

class DiscoverSubview extends StatelessWidget {
  const DiscoverSubview(this.scrollCtrl, this.formFactor);

  final ScrollController scrollCtrl;
  final FormFactor formFactor;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final options = ref.watch(persistenceProvider.select((s) => s.options));
        final type = ref.watch(discoverFilterProvider.select((s) => s.type));
        final onRefresh = (invalidate) => invalidate(discoverProvider);

        final content = switch (type) {
          .anime => PagedView(
            scrollCtrl: scrollCtrl,
            onRefresh: onRefresh,
            provider: discoverProvider.select(
              (s) => s.whenData((data) => (data as DiscoverAnimeItems).pages),
            ),
            onData: (data) => options.discoverItemView == .simple
                ? DiscoverMediaSimpleGrid(data.items, highContrast: options.highContrast)
                : DiscoverMediaGrid(data.items, highContrast: options.highContrast),
          ),
          .manga => PagedView(
            scrollCtrl: scrollCtrl,
            onRefresh: onRefresh,
            provider: discoverProvider.select(
              (s) => s.whenData((data) => (data as DiscoverMangaItems).pages),
            ),
            onData: (data) => options.discoverItemView == .simple
                ? DiscoverMediaSimpleGrid(data.items, highContrast: options.highContrast)
                : DiscoverMediaGrid(data.items, highContrast: options.highContrast),
          ),
          .character => PagedView(
            scrollCtrl: scrollCtrl,
            onRefresh: onRefresh,
            provider: discoverProvider.select(
              (s) => s.whenData((data) => (data as DiscoverCharacterItems).pages),
            ),
            onData: (data) => CharacterItemGrid(data.items, highContrast: options.highContrast),
          ),
          .staff => PagedView(
            scrollCtrl: scrollCtrl,
            onRefresh: onRefresh,
            provider: discoverProvider.select(
              (s) => s.whenData((data) => (data as DiscoverStaffItems).pages),
            ),
            onData: (data) => StaffItemGrid(data.items, highContrast: options.highContrast),
          ),
          .studio => PagedView(
            scrollCtrl: scrollCtrl,
            onRefresh: onRefresh,
            provider: discoverProvider.select(
              (s) => s.whenData((data) => (data as DiscoverStudioItems).pages),
            ),
            onData: (data) => StudioItemGrid(data.items, highContrast: options.highContrast),
          ),
          .user => PagedView(
            scrollCtrl: scrollCtrl,
            onRefresh: onRefresh,
            provider: discoverProvider.select(
              (s) => s.whenData((data) => (data as DiscoverUserItems).pages),
            ),
            onData: (data) => UserItemGrid(data.items, highContrast: options.highContrast),
          ),
          .review => PagedView(
            scrollCtrl: scrollCtrl,
            onRefresh: onRefresh,
            provider: discoverProvider.select(
              (s) => s.whenData((data) => (data as DiscoverReviewItems).pages),
            ),
            onData: (data) => ReviewGrid(data.items, options.highContrast),
          ),
          .recommendation => PagedView(
            scrollCtrl: scrollCtrl,
            onRefresh: onRefresh,
            provider: discoverProvider.select(
              (s) => s.whenData((data) => (data as DiscoverRecommendationItems).pages),
            ),
            onData: (data) => DiscoverRecommendationsGrid(
              data.items,
              onRate: (mediaId, recommendedMediaId, rating) => ref
                  .read(discoverProvider.notifier)
                  .rateRecommendation(mediaId, recommendedMediaId, rating),
              highContrast: options.highContrast,
            ),
          ),
        };

        if (formFactor == .phone) {
          return Column(
            children: [
              _DiscoverCategoryChips(currentType: type),
              Expanded(child: content),
            ],
          );
        }

        return Row(
          children: [
            PillSelector(
              selected: type.index,
              maxWidth: 180,
              items: DiscoverType.values.map((v) => Text(v.label)).toList(),
              onTap: (i) => ref
                  .read(discoverFilterProvider.notifier)
                  .update((s) => s.copyWith(type: DiscoverType.values[i])),
            ),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}

class _DiscoverCategoryChips extends StatelessWidget {
  const _DiscoverCategoryChips({required this.currentType});

  final DiscoverType currentType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: Theming.bouncyPhysics,
        padding: const EdgeInsets.symmetric(horizontal: Theming.offset),
        itemCount: DiscoverType.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final type = DiscoverType.values[i];
          final isSelected = currentType == type;

          return Consumer(
            builder: (context, ref, _) {
              return ChoiceChip(
                showCheckmark: false,
                selected: isSelected,
                avatar: Icon(
                  _typeIcon(type),
                  size: 14,
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                ),
                label: Text(type.label),
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  ref.read(discoverFilterProvider.notifier).update((s) => s.copyWith(type: type));
                },
              );
            },
          );
        },
      ),
    );
  }

  static IconData _typeIcon(DiscoverType type) => switch (type) {
    .anime => LucideIcons.tv,
    .manga => LucideIcons.bookOpen,
    .character => LucideIcons.user,
    .staff => LucideIcons.mic,
    .studio => LucideIcons.building2,
    .user => LucideIcons.users,
    .review => LucideIcons.fileText,
    .recommendation => LucideIcons.thumbsUp,
  };
}
