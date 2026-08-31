import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/extension/action_chip_extension.dart';
import 'package:risutaku/extension/card_extension.dart';
import 'package:risutaku/feature/discover/discover_filter_model.dart';
import 'package:risutaku/feature/media/media_provider.dart';
import 'package:risutaku/feature/tag/tag_model.dart';
import 'package:risutaku/util/routes.dart';
import 'package:risutaku/util/theming.dart';
import 'package:risutaku/widget/bento_card.dart';
import 'package:risutaku/widget/html_content.dart';
import 'package:risutaku/widget/loaders.dart';
import 'package:risutaku/widget/table_list.dart';
import 'package:risutaku/feature/discover/discover_filter_provider.dart';
import 'package:risutaku/feature/media/media_models.dart';
import 'package:risutaku/widget/dialogs.dart';
import 'package:risutaku/extension/snack_bar_extension.dart';

class MediaOverviewSubview extends StatelessWidget {
  const MediaOverviewSubview.asFragment({
    required this.info,
    required this.ref,
    required this.highContrast,
    required ScrollController this.scrollCtrl,
  }) : header = null;

  const MediaOverviewSubview.withHeader({
    required this.info,
    required this.ref,
    required this.highContrast,
    required Widget this.header,
  }) : scrollCtrl = null;

  final WidgetRef ref;
  final MediaInfo info;
  final Widget? header;
  final ScrollController? scrollCtrl;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    String? release;
    if (info.startDate != null) {
      if (info.endDate != null) {
        if (info.startDate != info.endDate) {
          release = '${info.startDate} - ${info.endDate}';
        } else {
          release = info.startDate!;
        }
      } else {
        release = '${info.startDate} - ?';
      }
    }

    final details = [
      if (release != null) ('Release', release),
      if (info.status != null) ('Status', info.status!.label),
      if (info.episodes != null) ('Episodes', info.episodes!.toString()),
      if (info.duration != null) ('Duration', info.duration!),
      if (info.chapters != null) ('Chapters', info.chapters!.toString()),
      if (info.volumes != null) ('Volumes', info.volumes!.toString()),
      if (info.season != null) ('Season', info.season!),
      if (info.source != null) ('Source', info.source!.label),
      if (info.countryOfOrigin != null) ('Origin', info.countryOfOrigin!.label),
    ];

    final titles = [
      if (info.hashtag != null) ('Hashtag', info.hashtag!),
      if (info.romajiTitle != null) ('Romaji', info.romajiTitle!),
      if (info.englishTitle != null) ('English', info.englishTitle!),
      if (info.nativeTitle != null) ('Native', info.nativeTitle!),
      ...info.synonyms.map((s) => ('Synonym', s)),
    ];

    const spacing = SliverToBoxAdapter(child: SizedBox(height: Theming.offset));
    final mediaQuery = MediaQuery.of(context);
    final refreshControl = SliverRefreshControl(
      onRefresh: () => ref.invalidate(mediaProvider(info.id)),
    );

    return CustomScrollView(
      controller: scrollCtrl,
      physics: Theming.bouncyPhysics,
      slivers: [
        if (header != null) ...[
          header!,
          MediaQuery(
            data: mediaQuery.copyWith(padding: mediaQuery.padding.copyWith(top: 0)),
            child: refreshControl,
          ),
        ] else
          refreshControl,
        SliverPadding(
          padding: const .symmetric(horizontal: Theming.offset),
          sliver: SliverMainAxisGroup(
            slivers: [
              if (info.description.isNotEmpty) _Description(info.description, highContrast),
              SliverToBoxAdapter(
                child: _BentoStatsGrid(info: info, highContrast: highContrast),
              ),
              spacing,
              SliverTableList(details, highContrast: highContrast),
              if (info.genres.isNotEmpty)
                _Wrap(
                  title: 'Genres',
                  children: info.genres
                      .map((genre) => _buildGenreActionChip(context, genre, highContrast))
                      .toList(),
                ),
              if (info.tags.isNotEmpty)
                _TagsWrap(
                  ref: ref,
                  tags: info.tags,
                  isAnime: info.isAnime,
                  highContrast: highContrast,
                ),
              if (info.studios.isNotEmpty)
                _Wrap(
                  title: 'Studios',
                  children: info.studios.entries
                      .map(
                        (studio) =>
                            _buildStudioActionChip(context, studio.key, studio.value, highContrast),
                      )
                      .toList(),
                ),
              if (info.producers.isNotEmpty)
                _Wrap(
                  title: 'Producers',
                  children: info.producers.entries
                      .map(
                        (studio) =>
                            _buildStudioActionChip(context, studio.key, studio.value, highContrast),
                      )
                      .toList(),
                ),
              if (info.externalLinks.isNotEmpty)
                _Wrap(
                  title: 'External links',
                  children: info.externalLinks
                      .map((link) => _buildExternalLinkChip(context, link, highContrast))
                      .toList(),
                ),
              spacing,
              spacing,
              SliverTableList(titles, highContrast: highContrast),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.paddingOf(context).bottom + Theming.normalTapTarget + 26,
          ),
        ),
      ],
    );
  }

  Widget _buildGenreActionChip(BuildContext context, String genre, bool highContrast) {
    return ActionChipExtension.highContrast(highContrast)(
      label: Text(genre),
      tooltip: 'Filter By Genre',
      onPressed: () {
        final notifier = ref.read(discoverFilterProvider.notifier);
        final filter = notifier.state.copyWith(
          type: info.isAnime ? .anime : .manga,
          search: '',
          mediaFilter: DiscoverMediaFilter(notifier.state.mediaFilter.sort),
        )..mediaFilter.genreIn.add(genre);
        notifier.state = filter;

        context.go(Routes.home(.discover));
      },
    );
  }

  Widget _buildStudioActionChip(BuildContext context, String name, int id, bool highContrast) {
    return ActionChipExtension.highContrast(highContrast)(
      label: Text(name),
      tooltip: 'Open Studio',
      onPressed: () => context.push(Routes.studio(id, name)),
    );
  }

  Widget _buildExternalLinkChip(BuildContext context, ExternalLink link, bool highContrast) {
    return _Chip(
      label: link.countryCode == null ? Text(link.site) : Text('${link.site} ${link.countryCode}'),
      onTap: () => SnackBarExtension.launch(context, link.url),
      onLongTap: () => SnackBarExtension.copy(context, link.url),
      onTapHint: 'open external link',
      onLongTapHint: 'copy external link',
      highContrast: highContrast,
      leading: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(borderRadius: Theming.borderRadiusSmall, color: link.color),
      ),
    );
  }
}

class _Description extends StatefulWidget {
  const _Description(this.text, this.highContrast);

  final String text;
  final bool highContrast;

  @override
  State<_Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<_Description> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final content = _expanded
        ? HtmlContent(widget.text)
        : ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment(0.0, 0.3),
              end: Alignment(0.0, 1.0),
              colors: [Colors.white, Colors.transparent],
            ).createShader(bounds),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 72),
              child: HtmlContent(widget.text),
            ),
          );

    return SliverToBoxAdapter(
      child: Padding(
        padding: const .only(bottom: Theming.offset),
        child: CardExtension.highContrast(widget.highContrast)(
          child: InkWell(
            borderRadius: Theming.borderRadiusSmall,
            onTap: () => setState(() => _expanded = !_expanded),
            onLongPress: () {
              final text = widget.text.replaceAll(RegExp(r'<br>'), '');
              SnackBarExtension.copy(context, text);
            },
            child: Padding(padding: const .all(Theming.offset), child: content),
          ),
        ),
      ),
    );
  }
}

class _BentoStatsGrid extends StatelessWidget {
  const _BentoStatsGrid({required this.info, required this.highContrast});

  final MediaInfo info;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        final crossAxisCount = isWide ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: isWide ? 2.8 : 2.35,
          children: [
            if (info.averageScore > 0)
              BentoStatTile(
                label: 'Score',
                value: '${info.averageScore}%',
                icon: const Icon(LucideIcons.star),
                accentColor: colorScheme.primary,
              ),
            if (info.meanScore > 0)
              BentoStatTile(
                label: 'Mean',
                value: '${info.meanScore}%',
                icon: const Icon(LucideIcons.sparkles),
                accentColor: colorScheme.secondary,
              ),
            if (info.popularity > 0)
              BentoStatTile(
                label: 'Popularity',
                value: info.popularity.toString(),
                icon: const Icon(LucideIcons.users),
                accentColor: colorScheme.tertiary,
              ),
            if (info.favourites > 0)
              BentoStatTile(
                label: 'Favorites',
                value: info.favourites.toString(),
                icon: const Icon(LucideIcons.heart),
                accentColor: Colors.redAccent,
              ),
            if (info.format != null || info.episodes != null || info.chapters != null)
              BentoStatTile(
                label: info.isAnime ? 'Format & Eps' : 'Format & Chs',
                value: [
                  if (info.format != null) info.format!.label,
                  if (info.episodes != null) '${info.episodes} eps',
                  if (info.chapters != null) '${info.chapters} chs',
                ].join(' • '),
                icon: Icon(info.isAnime ? LucideIcons.tv : LucideIcons.bookOpen),
                accentColor: colorScheme.primary,
              ),
            if (info.status != null || info.season != null)
              BentoStatTile(
                label: 'Status',
                value: [
                  if (info.status != null) info.status!.label,
                  if (info.season != null) info.season!,
                ].join(' • '),
                icon: const Icon(LucideIcons.info),
                accentColor: colorScheme.secondary,
              ),
          ],
        );
      },
    );
  }
}

class _Wrap extends StatelessWidget {
  const _Wrap({required this.title, required this.children, this.trailingAction});

  final String title;
  final Widget? trailingAction;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title)),
              if (trailingAction != null)
                trailingAction!
              else
                const SizedBox(height: Theming.minTapTarget),
            ],
          ),
          Wrap(spacing: 5, children: children),
        ],
      ),
    );
  }
}

class _TagsWrap extends StatefulWidget {
  const _TagsWrap({
    required this.ref,
    required this.tags,
    required this.isAnime,
    required this.highContrast,
  });

  final WidgetRef ref;
  final List<Tag> tags;
  final bool isAnime;
  final bool highContrast;

  @override
  State<_TagsWrap> createState() => __TagsWrapState();
}

class __TagsWrapState extends State<_TagsWrap> {
  bool? _showSpoilers;

  @override
  void initState() {
    super.initState();
    for (final t in widget.tags) {
      if (t.isSpoiler) {
        _showSpoilers = false;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tags = _showSpoilers == null || _showSpoilers!
        ? widget.tags
        : widget.tags.where((t) => !t.isSpoiler).toList();

    final spoilerColor = ColorScheme.of(context).error;

    return _Wrap(
      title: 'Tags',
      trailingAction: _showSpoilers != null
          ? IconButton(
              icon: _showSpoilers!
                  ? const Icon(LucideIcons.eyeOff)
                  : const Icon(LucideIcons.eye),
              tooltip: _showSpoilers! ? 'Hide Spoilers' : 'Show Spoilers',
              onPressed: () => setState(() => _showSpoilers = !_showSpoilers!),
            )
          : null,
      children: tags.map((tag) => _buildTagChip(tag, spoilerColor)).toList(),
    );
  }

  Widget _buildTagChip(Tag tag, Color spoilerColor) {
    return _Chip(
      label: Text(
        '${tag.name} ${tag.rank}%',
        style: tag.isSpoiler ? TextStyle(color: spoilerColor) : null,
      ),
      onTapHint: 'filter by this tag',
      onLongTapHint: 'show tag description',
      highContrast: widget.highContrast,
      onTap: () {
        final notifier = widget.ref.read(discoverFilterProvider.notifier);
        final filter = notifier.state.copyWith(
          type: widget.isAnime ? .anime : .manga,
          search: '',
          mediaFilter: DiscoverMediaFilter(notifier.state.mediaFilter.sort),
        )..mediaFilter.tagIn.add(tag.name);
        notifier.state = filter;

        context.go(Routes.home(.discover));
      },
      onLongTap: () => showDialog(
        context: context,
        builder: (context) => TextDialog(title: tag.name, text: tag.desciption),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.highContrast,
    this.leading,
    this.onTap,
    this.onLongTap,
    this.onTapHint,
    this.onLongTapHint,
  });

  final Widget label;
  final Widget? leading;
  final void Function()? onTap;
  final void Function()? onLongTap;
  final String? onTapHint;
  final String? onLongTapHint;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        onTapHint: onTapHint,
        onLongPressHint: onLongTapHint,
        child: GestureDetector(
          onLongPress: onLongTap,
          child: ActionChipExtension.highContrast(highContrast)(
            label: label,
            avatar: leading,
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}
