import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/feature/edit/edit_model.dart';
import 'package:risutaku/feature/edit/edit_view.dart';
import 'package:risutaku/feature/media/media_models.dart';
import 'package:risutaku/widget/sheets.dart';

/// A floating quick-action dock anchored to the bottom of the media page.
/// Provides immediate 1-tap access to status switching, progress incrementing, and full editing.
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

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status / Add Button
                      Flexible(
                        child: Material(
                          color: status == null
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => showSheet(
                              context,
                              EditView(
                                (id: media.info.id, setComplete: false),
                                callback: onEditComplete,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    status == null ? LucideIcons.plus : LucideIcons.check,
                                    size: 16,
                                    color: status == null
                                        ? colorScheme.onPrimary
                                        : colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      status == null
                                          ? 'Add to List'
                                          : status.label(isAnime),
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: status == null
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (status != null) ...[
                        const SizedBox(width: 8),
                        // Progress Readout
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            maxCount != null
                                ? '${isAnime ? "Ep" : "Ch"} $progress / $maxCount'
                                : '${isAnime ? "Ep" : "Ch"} $progress',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // +1 Increment Button
                        if (canIncrement)
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.primaryContainer,
                              foregroundColor: colorScheme.onPrimaryContainer,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(36, 36),
                            ),
                            tooltip: 'Increment +1',
                            icon: const Icon(LucideIcons.plus, size: 16),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              onProgressIncrement();
                            },
                          ),

                        const SizedBox(width: 4),

                        // Full Edit Button
                        IconButton(
                          style: IconButton.styleFrom(
                            minimumSize: const Size(36, 36),
                            padding: EdgeInsets.zero,
                          ),
                          tooltip: 'Edit details',
                          icon: const Icon(LucideIcons.slidersHorizontal, size: 16),
                          onPressed: () => showSheet(
                            context,
                            EditView(
                              (id: media.info.id, setComplete: false),
                              callback: onEditComplete,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
