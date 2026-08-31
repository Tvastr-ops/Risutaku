import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/feature/collection/collection_models.dart';
import 'package:risutaku/feature/edit/edit_model.dart';
import 'package:risutaku/feature/edit/edit_view.dart';
import 'package:risutaku/feature/media/media_models.dart';
import 'package:risutaku/widget/sheets.dart';

/// A sleek Material 3 Expressive quick-action pill for media entries.
/// Adapts responsively between an Extended Add FAB and a cohesive multi-action status dock.
class QuickActionDock extends StatelessWidget {
  const QuickActionDock({
    super.key,
    required this.media,
    required this.onProgressIncrement,
    required this.onEditComplete,
  });

  final Media media;
  final VoidCallback onProgressIncrement;
  final ValueChanged<EntryEdit> onEditComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final entry = media.entryEdit;
    final isAnime = media.info.isAnime;
    final status = entry.listStatus;
    final progress = entry.progress;
    final maxCount = isAnime ? media.info.episodes : media.info.chapters;
    final canIncrement = status != null && (maxCount == null || progress < maxCount);

    if (status == null) {
      return FloatingActionButton.extended(
        heroTag: 'media_action_${media.info.id}',
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: Text(
          'Add to List',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onPrimary,
            letterSpacing: 0.3,
          ),
        ),
        onPressed: () => showSheet(
          context,
          EditView(
            (id: media.info.id, setComplete: false),
            callback: onEditComplete,
          ),
        ),
      );
    }

    final statusColor = colorScheme.primary;
    final statusIcon = switch (status) {
      ListStatus.current => isAnime ? LucideIcons.play : LucideIcons.bookOpen,
      ListStatus.completed => LucideIcons.checkCheck,
      ListStatus.planning => LucideIcons.bookmark,
      ListStatus.paused => LucideIcons.pause,
      ListStatus.repeating => LucideIcons.repeat,
      ListStatus.dropped => LucideIcons.trash2,
    };

    return Material(
      color: colorScheme.surfaceContainerHigh,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        height: 50,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Button (Tap -> Full Edit)
            InkWell(
              onTap: () => showSheet(
                context,
                EditView(
                  (id: media.info.id, setComplete: false),
                  callback: onEditComplete,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 7),
                    Text(
                      status.label(isAnime),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Subtle divider
            Container(
              width: 1,
              height: 22,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),

            // Progress Readout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                maxCount != null
                    ? '${isAnime ? "Ep" : "Ch"} $progress / $maxCount'
                    : '${isAnime ? "Ep" : "Ch"} $progress',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            // +1 Quick Increment
            if (canIncrement) ...[
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onProgressIncrement();
                },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus, size: 15, color: colorScheme.primary),
                      const SizedBox(width: 2),
                      Text(
                        '1',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Edit Settings Icon
            InkWell(
              onTap: () => showSheet(
                context,
                EditView(
                  (id: media.info.id, setComplete: false),
                  callback: onEditComplete,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  LucideIcons.slidersHorizontal,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
