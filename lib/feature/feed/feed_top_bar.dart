import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/extension/snack_bar_extension.dart';
import 'package:risutaku/feature/activity/activities_model.dart';
import 'package:risutaku/feature/activity/activity_filter_sheet.dart';
import 'package:risutaku/feature/settings/settings_provider.dart';
import 'package:risutaku/feature/viewer/persistence_provider.dart';
import 'package:risutaku/util/routes.dart';

class FeedTopBarTrailingContent extends StatelessWidget {
  const FeedTopBarTrailingContent();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final count = ref.watch(settingsProvider.select((s) => s.value?.unreadNotifications ?? 0));

        final openNotifications = ref.watch(viewerIdProvider) != null
            ? () {
                ref.read(settingsProvider.notifier).clearUnread();
                context.push(Routes.notifications);
              }
            : () => SnackBarExtension.show(context, 'Log in to view notifications');

        Widget notificationIcon = IconButton(
          tooltip: 'Notifications',
          icon: const Icon(LucideIcons.bell),
          onPressed: openNotifications,
        );

        if (count > 0) {
          notificationIcon = Badge.count(
            count: count,
            maxCount: 99,
            offset: Offset.zero,
            alignment: Alignment.topLeft,
            child: notificationIcon,
          );
        }

        return Row(
          children: [
            IconButton(
              tooltip: 'Forum',
              icon: const Icon(LucideIcons.messagesSquare),
              onPressed: () => context.push(Routes.forum),
            ),
            notificationIcon,
            IconButton(
              tooltip: 'Filter',
              icon: const Icon(LucideIcons.slidersHorizontal),
              onPressed: () => showActivityFilterSheet(context, ref, HomeActivitiesTag.instance),
            ),
          ],
        );
      },
    );
  }
}
