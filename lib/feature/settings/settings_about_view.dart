import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/extension/date_time_extension.dart';
import 'package:risutaku/feature/viewer/persistence_model.dart';
import 'package:risutaku/feature/viewer/persistence_provider.dart';
import 'package:risutaku/util/theming.dart';
import 'package:risutaku/widget/cached_image.dart';
import 'package:risutaku/extension/snack_bar_extension.dart';

class SettingsAboutSubview extends StatelessWidget {
  const SettingsAboutSubview(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final padding = MediaQuery.paddingOf(context);
        final persistence = ref.watch(persistenceProvider);
        final lastBackgroundJob = persistence.appMeta.lastBackgroundJob;
        final lastJobTimestamp = lastBackgroundJob?.formattedDateTimeFromSeconds(
          persistence.options.analogClock,
        );

        return ListView(
          controller: scrollCtrl,
          physics: Theming.bouncyPhysics,
          padding: EdgeInsets.only(
            top: Theming.offset,
            left: padding.left + Theming.offset,
            right: padding.right + Theming.offset,
            bottom: padding.bottom + Theming.offset,
          ),
          children: [
            Align(
              child: Image.asset(
                'assets/icons/about.png',
                color: ColorScheme.of(context).primary,
                width: 90,
                height: 90,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Risutaku - v.$appVersion',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            const Text('An expressive Material 3 AniList client', textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(LucideIcons.code),
              title: const Text('Source Code'),
              subtitle: const Text('Tvastr-ops/otraku'),
              onTap: () =>
                  SnackBarExtension.launch(context, 'https://github.com/Tvastr-ops/otraku'),
            ),
            ListTile(
              leading: const Icon(LucideIcons.heart),
              title: const Text('Upstream Project'),
              subtitle: const Text('Forked with appreciation from Otraku by lotusprey'),
              onTap: () =>
                  SnackBarExtension.launch(context, 'https://github.com/lotusprey/otraku'),
            ),
            ListTile(
              leading: const Icon(LucideIcons.globe),
              title: const Text('AniList'),
              subtitle: const Text('anilist.co'),
              onTap: () => SnackBarExtension.launch(context, 'https://anilist.co'),
            ),
            ListTile(
              leading: const Icon(LucideIcons.messagesSquare),
              title: const Text('Discord'),
              onTap: () => SnackBarExtension.launch(context, 'https://discord.gg/YN2QWVbFef'),
            ),
            ListTile(
              leading: const Icon(LucideIcons.coffee),
              title: const Text('Donate'),
              onTap: () => SnackBarExtension.launch(context, 'https://ko-fi.com/lotusgate'),
            ),
            ListTile(
              leading: const Icon(LucideIcons.shieldCheck),
              title: const Text('Privacy Policy'),
              onTap: () => SnackBarExtension.launch(
                context,
                'https://sites.google.com/view/otraku/privacy-policy',
              ),
            ),
            const ListTile(
              leading: Icon(LucideIcons.trash2),
              title: Text('Clear Image Cache'),
              onTap: clearImageCache,
            ),
            ListTile(
              leading: Icon(LucideIcons.rotateCcw),
              title: Text('Reset Options'),
              onTap: () => ref.read(persistenceProvider.notifier).setOptions(Options.empty()),
            ),
            if (lastJobTimestamp != null)
              Padding(
                padding: const EdgeInsets.only(left: Theming.offset, right: Theming.offset, top: 20),
                child: Text(
                  'Performed a notification check around $lastJobTimestamp.',
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }
}
