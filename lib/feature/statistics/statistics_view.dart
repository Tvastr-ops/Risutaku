import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/extension/build_context_extension.dart';
import 'package:risutaku/extension/card_extension.dart';
import 'package:risutaku/extension/scroll_controller_extension.dart';
import 'package:risutaku/feature/statistics/statistics_model.dart';
import 'package:risutaku/feature/user/user_model.dart';
import 'package:risutaku/feature/user/user_providers.dart';
import 'package:risutaku/feature/statistics/charts.dart';
import 'package:risutaku/feature/viewer/persistence_provider.dart';
import 'package:risutaku/util/routes.dart';
import 'package:risutaku/util/theming.dart';
import 'package:risutaku/extension/snack_bar_extension.dart';
import 'package:risutaku/widget/cached_image.dart';
import 'package:risutaku/widget/grid/sliver_grid_delegates.dart';
import 'package:risutaku/widget/layout/adaptive_scaffold.dart';
import 'package:risutaku/widget/layout/constrained_view.dart';
import 'package:risutaku/widget/layout/top_bar.dart';
import 'package:risutaku/widget/loaders.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView(this.id);

  final int id;

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> with SingleTickerProviderStateMixin {
  late final tag = idUserTag(widget.id);
  late final _tabCtrl = TabController(length: 2, vsync: this);
  final _scrollCtrl = ScrollController();

  int _scoreBarChartTab = 0;
  int _lengthBarChartTab = 0;
  int _genreBarChartTab = 0;
  int _yearBarChartTab = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue<User>>(
          userProvider(tag),
          (_, s) =>
              s.whenOrNull(error: (error, _) => SnackBarExtension.show(context, error.toString())),
        );

        final options = ref.watch(persistenceProvider.select((s) => s.options));

        return ref
            .watch(userProvider(tag))
            .when(
              loading: () => const Center(child: Loader()),
              error: (_, _) => const Center(child: Text('Failed to load statistics')),
              data: (data) {
                return TabBarView(
                  controller: _tabCtrl,
                  children: [
                    ConstrainedView(
                      child: _StatisticsView(
                        statistics: data.animeStats,
                        ofAnime: true,
                        scrollCtrl: _scrollCtrl,
                        scoreTab: () => _scoreBarChartTab,
                        lengthTab: () => _lengthBarChartTab,
                        genreTab: () => _genreBarChartTab,
                        yearTab: () => _yearBarChartTab,
                        onScoreTabChanged: (i) => _scoreBarChartTab = i,
                        onLengthTabChanged: (i) => _lengthBarChartTab = i,
                        onGenreTabChanged: (i) => _genreBarChartTab = i,
                        onYearTabChanged: (i) => _yearBarChartTab = i,
                        highContrast: options.highContrast,
                      ),
                    ),
                    ConstrainedView(
                      child: _StatisticsView(
                        statistics: data.mangaStats,
                        ofAnime: false,
                        scrollCtrl: _scrollCtrl,
                        scoreTab: () => _scoreBarChartTab,
                        lengthTab: () => _lengthBarChartTab,
                        genreTab: () => _genreBarChartTab,
                        yearTab: () => _yearBarChartTab,
                        onScoreTabChanged: (i) => _scoreBarChartTab = i,
                        onLengthTabChanged: (i) => _lengthBarChartTab = i,
                        onGenreTabChanged: (i) => _genreBarChartTab = i,
                        onYearTabChanged: (i) => _yearBarChartTab = i,
                        highContrast: options.highContrast,
                      ),
                    ),
                  ],
                );
              },
            );
      },
    );

    return AdaptiveScaffold(
      topBar: _tabCtrl.index == 0
          ? const TopBar(key: Key('0'), title: 'Anime Statistics')
          : const TopBar(key: Key('1'), title: 'Manga Statistics'),
      navigationConfig: NavigationConfig(
        selected: _tabCtrl.index,
        onChanged: (i) => _tabCtrl.index = i,
        onSame: (_) => _scrollCtrl.scrollToTop(),
        items: const {'Anime': LucideIcons.tv, 'Manga': LucideIcons.bookOpen},
      ),
      child: child,
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView({
    required this.statistics,
    required this.ofAnime,
    required this.scrollCtrl,
    required this.scoreTab,
    required this.lengthTab,
    required this.genreTab,
    required this.yearTab,
    required this.onScoreTabChanged,
    required this.onLengthTabChanged,
    required this.onGenreTabChanged,
    required this.onYearTabChanged,
    required this.highContrast,
  });

  final Statistics statistics;
  final bool ofAnime;
  final ScrollController scrollCtrl;
  final int Function() scoreTab;
  final int Function() lengthTab;
  final int Function() genreTab;
  final int Function() yearTab;
  final void Function(int) onScoreTabChanged;
  final void Function(int) onLengthTabChanged;
  final void Function(int) onGenreTabChanged;
  final void Function(int) onYearTabChanged;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    const spacing = SliverToBoxAdapter(child: SizedBox(height: Theming.offset));

    return CustomScrollView(
      controller: scrollCtrl,
      physics: Theming.bouncyPhysics,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.paddingOf(context).top + Theming.offset),
        ),
        _Details(statistics, ofAnime, highContrast),

        // Score Distribution
        if (statistics.scores.isNotEmpty) ...[
          spacing,
          _BarChart(
            title: 'Score Distribution',
            statistics: statistics.scores,
            ofAnime: ofAnime,
            full: false,
            initialTab: scoreTab(),
            onTabChanged: onScoreTabChanged,
          ),
        ],

        // Lengths (Episodes / Chapters)
        if (statistics.lengths.isNotEmpty) ...[
          spacing,
          _BarChart(
            title: ofAnime ? 'Episode Lengths' : 'Chapter Lengths',
            statistics: statistics.lengths,
            ofAnime: ofAnime,
            full: true,
            initialTab: lengthTab(),
            onTabChanged: onLengthTabChanged,
          ),
        ],

        // Top Genres
        if (statistics.genres.isNotEmpty) ...[
          spacing,
          _TopGenresChart(
            genres: statistics.genres,
            ofAnime: ofAnime,
            initialTab: genreTab(),
            onTabChanged: onGenreTabChanged,
          ),
        ],

        // Top Studios (Anime only)
        if (ofAnime && statistics.studios.isNotEmpty) ...[
          spacing,
          _SectionTitle('Top Studios'),
          _TopStudiosGrid(studios: statistics.studios, highContrast: highContrast),
        ],

        // Top Voice Actors (Anime only)
        if (ofAnime && statistics.voiceActors.isNotEmpty) ...[
          spacing,
          _SectionTitle('Top Voice Actors'),
          _TopPeopleGrid(people: statistics.voiceActors, isVoiceActor: true, highContrast: highContrast),
        ],

        // Top Staff / Directors
        if (statistics.staff.isNotEmpty) ...[
          spacing,
          _SectionTitle(ofAnime ? 'Top Staff & Creators' : 'Top Authors & Artists'),
          _TopPeopleGrid(people: statistics.staff, isVoiceActor: false, highContrast: highContrast),
        ],

        // Top Tags & Themes
        if (statistics.tags.isNotEmpty) ...[
          spacing,
          _SectionTitle('Top Tags & Themes'),
          _TopTagsWrap(tags: statistics.tags, highContrast: highContrast),
        ],

        // Release Years Timeline
        if (statistics.releaseYears.isNotEmpty) ...[
          spacing,
          _YearsTimelineChart(
            years: statistics.releaseYears,
            ofAnime: ofAnime,
            initialTab: yearTab(),
            onTabChanged: onYearTabChanged,
          ),
        ],

        // Distributions (Format, Status, Country)
        if (statistics.count > 0) ...[
          spacing,
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 340,
              height: 200,
            ),
            delegate: SliverChildListDelegate([
              _PieChart('Format Distribution', statistics.formats, highContrast),
              _PieChart('Status Distribution', statistics.statuses, highContrast),
              _PieChart('Country Distribution', statistics.countries, highContrast),
            ]),
          ),
        ],
        const SliverFooter(),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Text(title, style: TextTheme.of(context).titleSmall),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  _Details(Statistics statistics, bool ofAnime, this.highContrast) {
    subtitles.add(statistics.count);
    subtitles.add(statistics.partsConsumed);

    if (ofAnime) {
      subtitles.add(((statistics.amountConsumed / 1440) * 10).round() / 10);
      icons.add(LucideIcons.tv);
      icons.add(LucideIcons.play);
      icons.add(LucideIcons.calendar);
      titles.add('Total Anime');
      titles.add('Episodes Watched');
      titles.add('Days Watched');
    } else {
      subtitles.add(statistics.amountConsumed);
      icons.add(LucideIcons.bookOpen);
      icons.add(LucideIcons.bookMarked);
      icons.add(LucideIcons.library);
      titles.add('Total Manga');
      titles.add('Chapters Read');
      titles.add('Volumes Read');
    }
    icons.add(LucideIcons.star);
    icons.add(LucideIcons.calculator);
    titles.add('Mean Score');
    titles.add('Standard Deviation');
    subtitles.add(statistics.meanScore);
    subtitles.add(statistics.standardDeviation);
  }

  final icons = <IconData>[];
  final titles = <String>[];
  final subtitles = <num>[];
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final bodyMediumLineHeight = context.lineHeight(textTheme.bodyMedium!);
    final labelMediumLineHeight = context.lineHeight(textTheme.labelMedium!);
    final tileHeight = max(bodyMediumLineHeight + labelMediumLineHeight, Theming.iconBig) + 10;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 190,
        height: tileHeight,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: titles.length,
        (context, i) => Tooltip(
          message: titles[i],
          triggerMode: .tap,
          child: CardExtension.highContrast(highContrast)(
            child: Padding(
              padding: const .symmetric(horizontal: Theming.offset, vertical: 5),
              child: Row(
                spacing: Theming.offset,
                children: [
                  Icon(icons[i], size: Theming.iconBig),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          child: Text(
                            titles[i],
                            style: TextTheme.of(context).labelMedium,
                            overflow: .ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Text(subtitles[i].toString()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarChart extends StatefulWidget {
  const _BarChart({
    required this.statistics,
    required this.title,
    required this.initialTab,
    required this.ofAnime,
    required this.full,
    required this.onTabChanged,
  });

  final List<AmountStatistics> statistics;
  final String title;
  final int initialTab;
  final bool ofAnime;
  final bool full;
  final void Function(int) onTabChanged;

  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    late List<num> values;
    if (_tab == 0) {
      values = widget.statistics.map((s) => s.count).toList();
    } else if (_tab == 1) {
      values = widget.statistics.map((s) => s.amount).toList();
    } else {
      values = widget.statistics.map((s) => s.meanScore).toList();
    }

    return SliverToBoxAdapter(
      child: BarChart(
        title: widget.title,
        toolbar: SegmentedButton(
          segments: [
            const ButtonSegment(
              value: 0,
              label: Text('Titles'),
              icon: Icon(Icons.numbers_outlined),
            ),
            if (widget.ofAnime)
              const ButtonSegment(
                value: 1,
                label: Text('Hours'),
                icon: Icon(Icons.hourglass_bottom_outlined),
              )
            else
              const ButtonSegment(
                value: 1,
                label: Text('Chapters'),
                icon: Icon(Icons.hourglass_bottom_outlined),
              ),
            if (widget.full && widget.statistics.any((s) => s.meanScore > 0))
              const ButtonSegment(
                value: 2,
                label: Text('Score'),
                icon: Icon(Icons.star_half_outlined),
              ),
          ],
          selected: {_tab},
          onSelectionChanged: (v) {
            setState(() => _tab = v.first);
            widget.onTabChanged(v.first);
          },
        ),
        names: widget.statistics.map((s) => s.type).toList(),
        values: values,
      ),
    );
  }
}

class _TopGenresChart extends StatefulWidget {
  const _TopGenresChart({
    required this.genres,
    required this.ofAnime,
    required this.initialTab,
    required this.onTabChanged,
  });

  final List<NamedStatistic> genres;
  final bool ofAnime;
  final int initialTab;
  final void Function(int) onTabChanged;

  @override
  State<_TopGenresChart> createState() => _TopGenresChartState();
}

class _TopGenresChartState extends State<_TopGenresChart> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final displayGenres = widget.genres.take(12).toList();
    late List<num> values;
    if (_tab == 0) {
      values = displayGenres.map((g) => g.count).toList();
    } else if (_tab == 1) {
      values = displayGenres.map((g) => g.amount).toList();
    } else {
      values = displayGenres.map((g) => g.meanScore).toList();
    }

    return SliverToBoxAdapter(
      child: BarChart(
        title: 'Top Genres',
        toolbar: SegmentedButton(
          segments: [
            const ButtonSegment(
              value: 0,
              label: Text('Titles'),
              icon: Icon(Icons.numbers_outlined),
            ),
            ButtonSegment(
              value: 1,
              label: Text(widget.ofAnime ? 'Hours' : 'Chapters'),
              icon: const Icon(Icons.hourglass_bottom_outlined),
            ),
            if (displayGenres.any((g) => g.meanScore > 0))
              const ButtonSegment(
                value: 2,
                label: Text('Score'),
                icon: Icon(Icons.star_half_outlined),
              ),
          ],
          selected: {_tab},
          onSelectionChanged: (v) {
            setState(() => _tab = v.first);
            widget.onTabChanged(v.first);
          },
        ),
        names: displayGenres.map((g) => g.name).toList(),
        values: values,
      ),
    );
  }
}

class _TopStudiosGrid extends StatelessWidget {
  const _TopStudiosGrid({required this.studios, required this.highContrast});

  final List<StudioStatistic> studios;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayStudios = studios.take(10).toList();

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 175,
        height: 72,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: displayStudios.length,
        (context, i) {
          final studio = displayStudios[i];
          return CardExtension.highContrast(highContrast)(
            child: InkWell(
              borderRadius: Theming.borderRadiusSmall,
              onTap: () => context.push(Routes.studio(studio.id, studio.name)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: Theming.borderRadiusSmall,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '#${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studio.name,
                            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${studio.count} anime',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (studio.meanScore > 0) ...[
                                const Text(' • '),
                                Icon(LucideIcons.star, size: 11, color: colorScheme.primary),
                                const SizedBox(width: 2),
                                Text(
                                  '${studio.meanScore.toStringAsFixed(0)}%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopPeopleGrid extends StatelessWidget {
  const _TopPeopleGrid({
    required this.people,
    required this.isVoiceActor,
    required this.highContrast,
  });

  final List<PersonStatistic> people;
  final bool isVoiceActor;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayPeople = people.take(10).toList();

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 180,
        height: 72,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: displayPeople.length,
        (context, i) {
          final person = displayPeople[i];
          return CardExtension.highContrast(highContrast)(
            child: InkWell(
              borderRadius: Theming.borderRadiusSmall,
              onTap: () => context.push(Routes.staff(person.id, person.avatarUrl)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: person.avatarUrl != null
                            ? CachedImage(person.avatarUrl!)
                            : Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(LucideIcons.user, size: 20, color: colorScheme.onSurfaceVariant),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person.name,
                            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${person.count} ${isVoiceActor ? "roles" : "works"}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (person.meanScore > 0) ...[
                                const Text(' • '),
                                Icon(LucideIcons.star, size: 11, color: colorScheme.primary),
                                const SizedBox(width: 2),
                                Text(
                                  '${person.meanScore.toStringAsFixed(0)}%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopTagsWrap extends StatelessWidget {
  const _TopTagsWrap({required this.tags, required this.highContrast});

  final List<TagStatistic> tags;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayTags = tags.take(18).toList();

    return SliverToBoxAdapter(
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final tag in displayTags)
            Material(
              color: colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: Theming.borderRadiusSmall,
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag.name,
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tag.count}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _YearsTimelineChart extends StatefulWidget {
  const _YearsTimelineChart({
    required this.years,
    required this.ofAnime,
    required this.initialTab,
    required this.onTabChanged,
  });

  final List<YearStatistic> years;
  final bool ofAnime;
  final int initialTab;
  final void Function(int) onTabChanged;

  @override
  State<_YearsTimelineChart> createState() => _YearsTimelineChartState();
}

class _YearsTimelineChartState extends State<_YearsTimelineChart> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    // Sort chronologically ascending for the timeline
    final sortedYears = List<YearStatistic>.from(widget.years)
      ..sort((a, b) => (int.tryParse(a.year) ?? 0).compareTo(int.tryParse(b.year) ?? 0));
    final displayYears = sortedYears.take(20).toList();

    late List<num> values;
    if (_tab == 0) {
      values = displayYears.map((y) => y.count).toList();
    } else if (_tab == 1) {
      values = displayYears.map((y) => y.amount).toList();
    } else {
      values = displayYears.map((y) => y.meanScore).toList();
    }

    return SliverToBoxAdapter(
      child: BarChart(
        title: 'Release Year Timeline',
        toolbar: SegmentedButton(
          segments: [
            const ButtonSegment(
              value: 0,
              label: Text('Titles'),
              icon: Icon(Icons.numbers_outlined),
            ),
            ButtonSegment(
              value: 1,
              label: Text(widget.ofAnime ? 'Hours' : 'Chapters'),
              icon: const Icon(Icons.hourglass_bottom_outlined),
            ),
            if (displayYears.any((y) => y.meanScore > 0))
              const ButtonSegment(
                value: 2,
                label: Text('Score'),
                icon: Icon(Icons.star_half_outlined),
              ),
          ],
          selected: {_tab},
          onSelectionChanged: (v) {
            setState(() => _tab = v.first);
            widget.onTabChanged(v.first);
          },
        ),
        names: displayYears.map((y) => y.year).toList(),
        values: values,
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart(this.title, this.stats, this.highContrast);

  final String title;
  final List<TypeStatistics> stats;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final names = stats.map((s) => s.value).toList();
    final values = stats.map((s) => s.count).toList();
    return PieChart(title: title, names: names, values: values, highContrast: highContrast);
  }
}

