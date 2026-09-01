import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:risutaku/extension/card_extension.dart';
import 'package:risutaku/extension/scroll_controller_extension.dart';
import 'package:risutaku/feature/media/media_models.dart';
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
                        scoreFormat: data.scoreFormat,
                        tag: tag,
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
                        scoreFormat: data.scoreFormat,
                        tag: tag,
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

class _StatisticsView extends ConsumerWidget {
  const _StatisticsView({
    required this.statistics,
    required this.ofAnime,
    required this.scrollCtrl,
    required this.scoreFormat,
    required this.tag,
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
  final ScoreFormat scoreFormat;
  final UserTag tag;
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
  Widget build(BuildContext context, WidgetRef ref) {
    const spacing = SliverToBoxAdapter(child: SizedBox(height: Theming.offset));

    return CustomScrollView(
      controller: scrollCtrl,
      physics: Theming.bouncyPhysics,
      slivers: [
        SliverRefreshControl(onRefresh: () => ref.refresh(userProvider(tag).future)),
        const SliverToBoxAdapter(
          child: SizedBox(height: Theming.offset),
        ),
        _BentoDetails(statistics, ofAnime, scoreFormat, highContrast),

        // Dynamic Skyscraper Score Histogram (Supports all rating scales with decimal labels & toggle)
        if (statistics.scores.isNotEmpty) ...[
          spacing,
          _ScoreHistogramChart(
            scores: statistics.scores,
            meanScore: statistics.meanScore,
            scoreFormat: scoreFormat,
            ofAnime: ofAnime,
            initialTab: scoreTab(),
            onTabChanged: onScoreTabChanged,
            highContrast: highContrast,
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
          _TopPeopleGrid(
            people: statistics.voiceActors,
            isVoiceActor: true,
            ofAnime: ofAnime,
            highContrast: highContrast,
          ),
        ],

        // Top Staff / Directors
        if (statistics.staff.isNotEmpty) ...[
          spacing,
          _SectionTitle(ofAnime ? 'Top Staff & Creators' : 'Top Authors & Artists'),
          _TopPeopleGrid(
            people: statistics.staff,
            isVoiceActor: false,
            ofAnime: ofAnime,
            highContrast: highContrast,
          ),
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
            highContrast: highContrast,
          ),
        ],

        // Spie Distribution Charts (Format, Status, Country)
        if (statistics.count > 0) ...[
          spacing,
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 340,
              height: 200,
            ),
            delegate: SliverChildListDelegate([
              if (statistics.formats.isNotEmpty)
                SpieChart(
                  title: 'Format Distribution',
                  names: statistics.formats.map((f) => f.value).toList(),
                  values: statistics.formats.map((f) => f.count).toList(),
                  highContrast: highContrast,
                ),
              if (statistics.statuses.isNotEmpty)
                SpieChart(
                  title: 'Status Distribution',
                  names: statistics.statuses.map((s) => s.value).toList(),
                  values: statistics.statuses.map((s) => s.count).toList(),
                  highContrast: highContrast,
                ),
              if (statistics.countries.isNotEmpty)
                SpieChart(
                  title: 'Country Distribution',
                  names: statistics.countries.map((c) => c.value).toList(),
                  values: statistics.countries.map((c) => c.count).toList(),
                  highContrast: highContrast,
                ),
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

/// Asymmetrical Modern Bento Grid
class _BentoDetails extends StatelessWidget {
  const _BentoDetails(this.statistics, this.ofAnime, this.scoreFormat, this.highContrast);

  final Statistics statistics;
  final bool ofAnime;
  final ScoreFormat scoreFormat;
  final bool highContrast;

  String _formatMean(double mean) {
    if (mean <= 0) return '—';
    switch (scoreFormat) {
      case ScoreFormat.point100:
        return '${mean.toStringAsFixed(1)}%';
      case ScoreFormat.point10Decimal:
        final dec = mean > 10 ? mean / 10.0 : mean;
        return dec.toStringAsFixed(2);
      case ScoreFormat.point10:
        final dec = mean > 10 ? mean / 10.0 : mean;
        return dec.toStringAsFixed(1);
      case ScoreFormat.point5:
        final stars = mean > 5 ? mean / 20.0 : mean;
        return '${stars.toStringAsFixed(2)} ★';
      case ScoreFormat.point3:
        final smiley = mean > 3 ? mean / 33.33 : mean;
        return smiley.toStringAsFixed(2);
    }
  }

  String _formatStdDev(double stdDev) {
    if (stdDev <= 0) return '—';
    switch (scoreFormat) {
      case ScoreFormat.point100:
        return stdDev.toStringAsFixed(1);
      case ScoreFormat.point10Decimal:
      case ScoreFormat.point10:
        final dec = stdDev > 10 ? stdDev / 10.0 : stdDev;
        return dec.toStringAsFixed(2);
      case ScoreFormat.point5:
        final stars = stdDev > 5 ? stdDev / 20.0 : stdDev;
        return stars.toStringAsFixed(2);
      case ScoreFormat.point3:
        final smiley = stdDev > 3 ? stdDev / 33.33 : stdDev;
        return smiley.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final heroTitle = ofAnime ? 'Time Watched' : 'Reading Progress';
    final heroValue = ofAnime
        ? '${((statistics.amountConsumed / 1440) * 10).round() / 10} Days'
        : '${statistics.partsConsumed} Chapters';
    final heroSubtitle = ofAnime
        ? '${statistics.partsConsumed} Episodes total'
        : '${statistics.amountConsumed} Volumes read';

    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Hero Bento Banner (Full Width)
          CardExtension.highContrast(highContrast)(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: Theming.borderRadiusBig,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.8),
                    colorScheme.surfaceContainerHigh,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: Theming.borderRadiusSmall,
                    ),
                    child: Icon(
                      ofAnime ? LucideIcons.hourglass : LucideIcons.bookOpen,
                      size: 26,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          heroTitle.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          heroValue,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          heroSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Secondary Bento Row 1: Titles & Consumed Parts
          Row(
            children: [
              // Total Titles
              Expanded(
                child: CardExtension.highContrast(highContrast)(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(ofAnime ? LucideIcons.film : LucideIcons.bookOpen, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              ofAnime ? 'Total Anime' : 'Total Manga',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${statistics.count}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Parts Consumed (Episodes / Chapters)
              Expanded(
                child: CardExtension.highContrast(highContrast)(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(ofAnime ? LucideIcons.play : LucideIcons.bookmarkCheck, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              ofAnime ? 'Episodes Watched' : 'Chapters Read',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${statistics.partsConsumed}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Secondary Bento Row 2: Mean Score & Standard Deviation
          Row(
            children: [
              // Mean Score Cell
              Expanded(
                child: CardExtension.highContrast(highContrast)(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.star, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Mean Score',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatMean(statistics.meanScore),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Standard Deviation Cell
              Expanded(
                child: CardExtension.highContrast(highContrast)(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.calculator, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Standard Deviation',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatStdDev(statistics.standardDeviation),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreHistogramChart extends StatefulWidget {
  const _ScoreHistogramChart({
    required this.scores,
    required this.meanScore,
    required this.scoreFormat,
    required this.ofAnime,
    required this.initialTab,
    required this.onTabChanged,
    required this.highContrast,
  });

  final List<AmountStatistics> scores;
  final double meanScore;
  final ScoreFormat scoreFormat;
  final bool ofAnime;
  final int initialTab;
  final void Function(int) onTabChanged;
  final bool highContrast;

  @override
  State<_ScoreHistogramChart> createState() => _ScoreHistogramChartState();
}

class _ScoreHistogramChartState extends State<_ScoreHistogramChart> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final sortedScores = List<AmountStatistics>.from(widget.scores)
      ..sort((a, b) => (double.tryParse(a.type) ?? 0).compareTo(double.tryParse(b.type) ?? 0));

    final names = sortedScores.map((s) => s.type).toList();
    final values = _tab == 0
        ? sortedScores.map((s) => s.count).toList()
        : sortedScores.map((s) => s.amount).toList();

    return SliverToBoxAdapter(
      child: ScoreHistogram(
        title: 'Score Distribution',
        names: names,
        values: values,
        meanScore: widget.meanScore,
        scoreFormat: widget.scoreFormat,
        highContrast: widget.highContrast,
        toolbar: SegmentedButton<int>(
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          segments: [
            const ButtonSegment(
              value: 0,
              label: Text('Titles', softWrap: false, maxLines: 1),
              icon: Icon(LucideIcons.hash, size: 16),
            ),
            ButtonSegment(
              value: 1,
              label: Text(widget.ofAnime ? 'Hours' : 'Chapters', softWrap: false, maxLines: 1),
              icon: Icon(widget.ofAnime ? LucideIcons.clock : LucideIcons.bookmark, size: 16),
            ),
          ],
          selected: {_tab},
          onSelectionChanged: (v) {
            setState(() => _tab = v.first);
            widget.onTabChanged(v.first);
          },
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
        toolbar: SegmentedButton<int>(
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          segments: [
            const ButtonSegment(
              value: 0,
              label: Text('Titles', softWrap: false, maxLines: 1),
              icon: Icon(LucideIcons.hash, size: 16),
            ),
            ButtonSegment(
              value: 1,
              label: Text(widget.ofAnime ? 'Hours' : 'Chapters', softWrap: false, maxLines: 1),
              icon: Icon(widget.ofAnime ? LucideIcons.clock : LucideIcons.bookmark, size: 16),
            ),
            if (widget.full && widget.statistics.any((s) => s.meanScore > 0))
              const ButtonSegment(
                value: 2,
                label: Text('Score', softWrap: false, maxLines: 1),
                icon: Icon(LucideIcons.star, size: 16),
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
        toolbar: SegmentedButton<int>(
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          segments: [
            const ButtonSegment(
              value: 0,
              label: Text('Titles', softWrap: false, maxLines: 1),
              icon: Icon(LucideIcons.hash, size: 16),
            ),
            ButtonSegment(
              value: 1,
              label: Text(widget.ofAnime ? 'Hours' : 'Chapters', softWrap: false, maxLines: 1),
              icon: Icon(widget.ofAnime ? LucideIcons.clock : LucideIcons.bookmark, size: 16),
            ),
            if (displayGenres.any((g) => g.meanScore > 0))
              const ButtonSegment(
                value: 2,
                label: Text('Score', softWrap: false, maxLines: 1),
                icon: Icon(LucideIcons.star, size: 16),
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

class _TopStudiosGrid extends StatefulWidget {
  const _TopStudiosGrid({required this.studios, required this.highContrast});

  final List<StudioStatistic> studios;
  final bool highContrast;

  @override
  State<_TopStudiosGrid> createState() => _TopStudiosGridState();
}

class _TopStudiosGridState extends State<_TopStudiosGrid> {
  int _sortTab = 0; // 0: Count, 1: Score

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sorted = List<StudioStatistic>.from(widget.studios);
    if (_sortTab == 0) {
      sorted.sort((a, b) => b.count.compareTo(a.count));
    } else {
      sorted.sort((a, b) => b.meanScore.compareTo(a.meanScore));
    }

    final displayStudios = sorted.take(12).toList();

    return SliverMainAxisGroup(
      slivers: [
        if (widget.studios.any((s) => s.meanScore > 0))
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SegmentedButton<int>(
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Most Titles', softWrap: false, maxLines: 1),
                    icon: Icon(LucideIcons.film, size: 16),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Highest Rated', softWrap: false, maxLines: 1),
                    icon: Icon(LucideIcons.star, size: 16),
                  ),
                ],
                selected: {_sortTab},
                onSelectionChanged: (v) => setState(() => _sortTab = v.first),
              ),
            ),
          ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
            minWidth: 140,
            height: 72,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          delegate: SliverChildBuilderDelegate(
            childCount: displayStudios.length,
            (context, i) {
              final studio = displayStudios[i];
              final badgeColor = i == 0
                  ? const Color(0xFFFFD700) // Gold
                  : i == 1
                      ? const Color(0xFFC0C0C0) // Silver
                      : i == 2
                          ? const Color(0xFFCD7F32) // Bronze
                          : colorScheme.primaryContainer;
              final textColor = i < 3 ? Colors.black : colorScheme.onPrimaryContainer;

              final scoreText = studio.meanScore > 10
                  ? (studio.meanScore / 10.0).toStringAsFixed(1)
                  : (studio.meanScore > 0 ? studio.meanScore.toStringAsFixed(1) : '');

              return CardExtension.highContrast(widget.highContrast)(
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
                            color: badgeColor,
                            borderRadius: Theming.borderRadiusSmall,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '#${i + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: textColor,
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
                                  if (scoreText.isNotEmpty) ...[
                                    const Text(' • '),
                                    Icon(LucideIcons.star, size: 11, color: colorScheme.primary),
                                    const SizedBox(width: 2),
                                    Text(
                                      scoreText,
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
        ),
      ],
    );
  }
}

class _TopPeopleGrid extends StatefulWidget {
  const _TopPeopleGrid({
    required this.people,
    required this.isVoiceActor,
    required this.ofAnime,
    required this.highContrast,
  });

  final List<PersonStatistic> people;
  final bool isVoiceActor;
  final bool ofAnime;
  final bool highContrast;

  @override
  State<_TopPeopleGrid> createState() => _TopPeopleGridState();
}

class _TopPeopleGridState extends State<_TopPeopleGrid> {
  int _sortTab = 0; // 0: Count, 1: Score, 2: Time

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sorted = List<PersonStatistic>.from(widget.people);
    if (_sortTab == 0) {
      sorted.sort((a, b) => b.count.compareTo(a.count));
    } else if (_sortTab == 1) {
      sorted.sort((a, b) => b.meanScore.compareTo(a.meanScore));
    } else {
      sorted.sort((a, b) => b.amount.compareTo(a.amount));
    }

    final displayPeople = sorted.take(16).toList();

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SegmentedButton<int>(
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              segments: [
                ButtonSegment(
                  value: 0,
                  label: Text(widget.isVoiceActor ? 'Roles' : 'Works', softWrap: false, maxLines: 1),
                  icon: Icon(
                    widget.isVoiceActor
                        ? LucideIcons.mic
                        : (widget.ofAnime ? LucideIcons.clapperboard : LucideIcons.bookOpen),
                    size: 16,
                  ),
                ),
                if (widget.people.any((p) => p.meanScore > 0))
                  const ButtonSegment(
                    value: 1,
                    label: Text('Score', softWrap: false, maxLines: 1),
                    icon: Icon(LucideIcons.star, size: 16),
                  ),
                if (widget.people.any((p) => p.amount > 0))
                  ButtonSegment(
                    value: 2,
                    label: Text(widget.ofAnime ? 'Hours' : 'Chapters', softWrap: false, maxLines: 1),
                    icon: Icon(widget.ofAnime ? LucideIcons.clock : LucideIcons.bookmark, size: 16),
                  ),
              ],
              selected: {_sortTab},
              onSelectionChanged: (v) => setState(() => _sortTab = v.first),
            ),
          ),
        ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
            minWidth: 140,
            height: 72,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          delegate: SliverChildBuilderDelegate(
            childCount: displayPeople.length,
            (context, i) {
              final person = displayPeople[i];
              final podiumBorderColor = i == 0
                  ? const Color(0xFFFFD700)
                  : i == 1
                      ? const Color(0xFFC0C0C0)
                      : i == 2
                          ? const Color(0xFFCD7F32)
                          : Colors.transparent;

              final scoreText = person.meanScore > 10
                  ? (person.meanScore / 10.0).toStringAsFixed(1)
                  : (person.meanScore > 0 ? person.meanScore.toStringAsFixed(1) : '');

              return CardExtension.highContrast(widget.highContrast)(
                child: InkWell(
                  borderRadius: Theming.borderRadiusSmall,
                  onTap: () => context.push(Routes.staff(person.id, person.avatarUrl)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: podiumBorderColor,
                                  width: i < 3 ? 2.0 : 0.0,
                                ),
                              ),
                              child: ClipOval(
                                child: person.avatarUrl != null
                                    ? CachedImage(person.avatarUrl!)
                                    : Container(
                                        color: colorScheme.surfaceContainerHighest,
                                        child: Icon(LucideIcons.user, size: 20, color: colorScheme.onSurfaceVariant),
                                      ),
                              ),
                            ),
                            if (i < 3)
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: podiumBorderColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '#${i + 1}',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                          ],
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
                                    _sortTab == 2 && person.amount > 0
                                        ? '${person.amount} ${widget.ofAnime ? "hrs" : "ch"}'
                                        : '${person.count} ${widget.isVoiceActor ? "roles" : "works"}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (scoreText.isNotEmpty) ...[
                                    const Text(' • '),
                                    Icon(LucideIcons.star, size: 11, color: colorScheme.primary),
                                    const SizedBox(width: 2),
                                    Text(
                                      scoreText,
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
        ),
      ],
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
    final displayTags = tags.take(28).toList();
    final maxCount = displayTags.fold<int>(1, (prev, t) => t.count > prev ? t.count : prev);

    return SliverToBoxAdapter(
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final tag in displayTags) ...[
            Builder(
              builder: (context) {
                final ratio = (tag.count / maxCount).clamp(0.0, 1.0);
                final isHot = ratio >= 0.5;

                return Material(
                  color: isHot
                      ? colorScheme.primaryContainer.withValues(alpha: 0.6 + (ratio * 0.4))
                      : colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: Theming.borderRadiusSmall,
                    side: BorderSide(
                      color: isHot
                          ? colorScheme.primary.withValues(alpha: 0.5)
                          : colorScheme.outlineVariant.withValues(alpha: 0.35),
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
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: isHot ? FontWeight.w700 : FontWeight.w600,
                            color: isHot ? colorScheme.onPrimaryContainer : null,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isHot
                                ? colorScheme.primary
                                : colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${tag.count}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isHot ? colorScheme.onPrimary : colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
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
    required this.highContrast,
  });

  final List<YearStatistic> years;
  final bool ofAnime;
  final int initialTab;
  final void Function(int) onTabChanged;
  final bool highContrast;

  @override
  State<_YearsTimelineChart> createState() => _YearsTimelineChartState();
}

class _YearsTimelineChartState extends State<_YearsTimelineChart> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    // Filter out invalid/zero dates and sort chronologically ascending
    final validYears = widget.years.where((y) {
      final yNum = int.tryParse(y.year) ?? 0;
      return yNum > 0 && y.count > 0;
    }).toList();

    validYears.sort((a, b) => (int.tryParse(a.year) ?? 0).compareTo(int.tryParse(b.year) ?? 0));

    late List<num> values;
    late List<String> subtitles;
    if (_tab == 0) {
      values = validYears.map((y) => y.count).toList();
      subtitles = validYears
          .map((y) => '${y.count} ${widget.ofAnime ? "titles" : "manga"}')
          .toList();
    } else if (_tab == 1) {
      values = validYears.map((y) => y.amount).toList();
      subtitles = validYears
          .map((y) => '${y.amount} ${widget.ofAnime ? "hours" : "chapters"}')
          .toList();
    } else {
      values = validYears.map((y) => y.meanScore).toList();
      subtitles = validYears
          .map((y) => '${y.meanScore.toStringAsFixed(1)}% score')
          .toList();
    }

    return SliverToBoxAdapter(
      child: ScrollableTimelineChart(
        title: 'Release Year Timeline',
        years: validYears.map((y) => y.year).toList(),
        values: values,
        subtitles: subtitles,
        highContrast: widget.highContrast,
        toolbar: SegmentedButton<int>(
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          segments: [
            const ButtonSegment(
              value: 0,
              label: Text('Titles', softWrap: false, maxLines: 1),
              icon: Icon(LucideIcons.hash, size: 16),
            ),
            ButtonSegment(
              value: 1,
              label: Text(widget.ofAnime ? 'Hours' : 'Chapters', softWrap: false, maxLines: 1),
              icon: Icon(widget.ofAnime ? LucideIcons.clock : LucideIcons.bookmark, size: 16),
            ),
            if (validYears.any((y) => y.meanScore > 0))
              const ButtonSegment(
                value: 2,
                label: Text('Score', softWrap: false, maxLines: 1),
                icon: Icon(LucideIcons.star, size: 16),
              ),
          ],
          selected: {_tab},
          onSelectionChanged: (v) {
            setState(() => _tab = v.first);
            widget.onTabChanged(v.first);
          },
        ),
      ),
    );
  }
}
