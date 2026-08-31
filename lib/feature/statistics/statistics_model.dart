import 'package:risutaku/extension/string_extension.dart';
import 'package:risutaku/feature/media/media_models.dart';

class Statistics {
  Statistics._({
    required this.count,
    required this.meanScore,
    required this.standardDeviation,
    required this.partsConsumed,
    required this.amountConsumed,
    required this.scores,
    required this.lengths,
    required this.formats,
    required this.statuses,
    required this.countries,
    required this.genres,
    required this.tags,
    required this.studios,
    required this.voiceActors,
    required this.staff,
    required this.releaseYears,
    required this.startYears,
  });

  factory Statistics(Map<String, dynamic> map, bool ofAnime) {
    final scores = <AmountStatistics>[];
    final lengths = <AmountStatistics>[];
    final formats = <TypeStatistics>[];
    final statuses = <TypeStatistics>[];
    final countries = <TypeStatistics>[];
    final genres = <NamedStatistic>[];
    final tags = <TagStatistic>[];
    final studios = <StudioStatistic>[];
    final voiceActors = <PersonStatistic>[];
    final staff = <PersonStatistic>[];
    final releaseYears = <YearStatistic>[];
    final startYears = <YearStatistic>[];

    if (map['scores'] != null) {
      for (final s in map['scores']) {
        scores.add(AmountStatistics(s, 'score', ofAnime));
      }
    }
    if (map['lengths'] != null) {
      for (final l in map['lengths']) {
        lengths.add(AmountStatistics(l, 'length', ofAnime));
      }
    }
    if (map['formats'] != null) {
      for (final f in map['formats']) {
        formats.add(TypeStatistics(f, 'format'));
      }
    }
    if (map['statuses'] != null) {
      for (final s in map['statuses']) {
        statuses.add(TypeStatistics(s, 'status'));
      }
    }
    if (map['countries'] != null) {
      for (final c in map['countries']) {
        c['country'] = OriginCountry.fromCode(c['country'])?.label;
        countries.add(TypeStatistics(c, 'country'));
      }
    }
    if (map['genres'] != null) {
      for (final g in map['genres']) {
        genres.add(NamedStatistic.genre(g, ofAnime));
      }
    }
    if (map['tags'] != null) {
      for (final t in map['tags']) {
        tags.add(TagStatistic(t, ofAnime));
      }
    }
    if (map['studios'] != null) {
      for (final s in map['studios']) {
        studios.add(StudioStatistic(s));
      }
    }
    if (map['voiceActors'] != null) {
      for (final va in map['voiceActors']) {
        voiceActors.add(PersonStatistic.voiceActor(va));
      }
    }
    if (map['staff'] != null) {
      for (final st in map['staff']) {
        staff.add(PersonStatistic.staff(st, ofAnime));
      }
    }
    if (map['releaseYears'] != null) {
      for (final ry in map['releaseYears']) {
        releaseYears.add(YearStatistic.release(ry, ofAnime));
      }
    }
    if (map['startYears'] != null) {
      for (final sy in map['startYears']) {
        startYears.add(YearStatistic.start(sy, ofAnime));
      }
    }

    // The backend can't sort lengths naturally, so it has to be done locally.
    lengths.sort((a, b) {
      if (a.type == '?') return 1;
      if (b.type == '?') return -1;

      if (a.type[a.type.length - 1] == '+') return 1;
      if (b.type[b.type.length - 1] == '+') return -1;

      if (a.type.length > b.type.length) return 1;
      if (a.type.length < b.type.length) return -1;

      return a.type.compareTo(b.type);
    });

    return Statistics._(
      count: map['count'] ?? 0,
      meanScore: (map['meanScore'] ?? 0).toDouble(),
      standardDeviation: (map['standardDeviation'] ?? 0).toDouble(),
      partsConsumed: ofAnime ? (map['episodesWatched'] ?? 0) : (map['chaptersRead'] ?? 0),
      amountConsumed: ofAnime ? (map['minutesWatched'] ?? 0) : (map['volumesRead'] ?? 0),
      scores: scores,
      lengths: lengths,
      formats: formats,
      statuses: statuses,
      countries: countries,
      genres: genres,
      tags: tags,
      studios: studios,
      voiceActors: voiceActors,
      staff: staff,
      releaseYears: releaseYears,
      startYears: startYears,
    );
  }

  final int count;
  final double meanScore;
  final double standardDeviation;
  final int partsConsumed;
  final int amountConsumed;
  final List<AmountStatistics> scores;
  final List<AmountStatistics> lengths;
  final List<TypeStatistics> formats;
  final List<TypeStatistics> statuses;
  final List<TypeStatistics> countries;
  final List<NamedStatistic> genres;
  final List<TagStatistic> tags;
  final List<StudioStatistic> studios;
  final List<PersonStatistic> voiceActors;
  final List<PersonStatistic> staff;
  final List<YearStatistic> releaseYears;
  final List<YearStatistic> startYears;
}

class AmountStatistics {
  AmountStatistics._({
    required this.count,
    required this.meanScore,
    required this.amount,
    required this.type,
  });

  factory AmountStatistics(Map<String, dynamic> map, String key, bool ofAnime) =>
      AmountStatistics._(
        count: map['count'] ?? 0,
        meanScore: (map['meanScore'] ?? 0).toDouble(),
        amount: ofAnime ? (map['minutesWatched'] ?? 0) ~/ 60 : (map['chaptersRead'] ?? 0),
        type: (map[key] ?? '?').toString(),
      );

  final int count;
  final double meanScore;
  final int amount;
  final String type;
}

class TypeStatistics {
  TypeStatistics._({
    required this.count,
    required this.meanScore,
    required this.hoursWatched,
    required this.chaptersRead,
    required this.value,
  });

  factory TypeStatistics(Map<String, dynamic> map, String key) => TypeStatistics._(
    count: map['count'] ?? 0,
    meanScore: (map['meanScore'] ?? 0).toDouble(),
    hoursWatched: (map['minutesWatched'] ?? 0) ~/ 60,
    chaptersRead: map['chaptersRead'] ?? 0,
    value: ((map[key] ?? '') as String).noScreamingSnakeCase,
  );

  final int count;
  final double meanScore;
  final int hoursWatched;
  final int chaptersRead;
  final String value;
}

class NamedStatistic {
  NamedStatistic._({
    required this.name,
    required this.count,
    required this.meanScore,
    required this.amount,
  });

  factory NamedStatistic.genre(Map<String, dynamic> map, bool ofAnime) => NamedStatistic._(
    name: map['genre'] ?? 'Unknown',
    count: map['count'] ?? 0,
    meanScore: (map['meanScore'] ?? 0).toDouble(),
    amount: ofAnime ? (map['minutesWatched'] ?? 0) ~/ 60 : (map['chaptersRead'] ?? 0),
  );

  final String name;
  final int count;
  final double meanScore;
  final int amount; // Hours or Chapters
}

class TagStatistic {
  TagStatistic._({
    required this.id,
    required this.name,
    required this.count,
    required this.meanScore,
    required this.amount,
  });

  factory TagStatistic(Map<String, dynamic> map, bool ofAnime) => TagStatistic._(
    id: map['tag']?['id'] ?? 0,
    name: map['tag']?['name'] ?? 'Unknown',
    count: map['count'] ?? 0,
    meanScore: (map['meanScore'] ?? 0).toDouble(),
    amount: ofAnime ? (map['minutesWatched'] ?? 0) ~/ 60 : (map['chaptersRead'] ?? 0),
  );

  final int id;
  final String name;
  final int count;
  final double meanScore;
  final int amount;
}

class StudioStatistic {
  StudioStatistic._({
    required this.id,
    required this.name,
    required this.count,
    required this.meanScore,
    required this.hoursWatched,
  });

  factory StudioStatistic(Map<String, dynamic> map) => StudioStatistic._(
    id: map['studio']?['id'] ?? 0,
    name: map['studio']?['name'] ?? 'Unknown',
    count: map['count'] ?? 0,
    meanScore: (map['meanScore'] ?? 0).toDouble(),
    hoursWatched: (map['minutesWatched'] ?? 0) ~/ 60,
  );

  final int id;
  final String name;
  final int count;
  final double meanScore;
  final int hoursWatched;
}

class PersonStatistic {
  PersonStatistic._({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.count,
    required this.meanScore,
    required this.amount,
  });

  factory PersonStatistic.voiceActor(Map<String, dynamic> map) => PersonStatistic._(
    id: map['voiceActor']?['id'] ?? 0,
    name: map['voiceActor']?['name']?['userPreferred'] ?? 'Unknown',
    avatarUrl: map['voiceActor']?['image']?['medium'],
    count: map['count'] ?? 0,
    meanScore: (map['meanScore'] ?? 0).toDouble(),
    amount: (map['minutesWatched'] ?? 0) ~/ 60,
  );

  factory PersonStatistic.staff(Map<String, dynamic> map, bool ofAnime) => PersonStatistic._(
    id: map['staff']?['id'] ?? 0,
    name: map['staff']?['name']?['userPreferred'] ?? 'Unknown',
    avatarUrl: map['staff']?['image']?['medium'],
    count: map['count'] ?? 0,
    meanScore: (map['meanScore'] ?? 0).toDouble(),
    amount: ofAnime ? (map['minutesWatched'] ?? 0) ~/ 60 : (map['chaptersRead'] ?? 0),
  );

  final int id;
  final String name;
  final String? avatarUrl;
  final int count;
  final double meanScore;
  final int amount; // Hours or Chapters
}

class YearStatistic {
  YearStatistic._({
    required this.year,
    required this.count,
    required this.meanScore,
    required this.amount,
  });

  factory YearStatistic.release(Map<String, dynamic> map, bool ofAnime) => YearStatistic._(
    year: (map['releaseYear'] ?? 0).toString(),
    count: map['count'] ?? 0,
    meanScore: (map['meanScore'] ?? 0).toDouble(),
    amount: ofAnime ? (map['minutesWatched'] ?? 0) ~/ 60 : (map['chaptersRead'] ?? 0),
  );

  factory YearStatistic.start(Map<String, dynamic> map, bool ofAnime) => YearStatistic._(
    year: (map['startYear'] ?? 0).toString(),
    count: map['count'] ?? 0,
    meanScore: (map['meanScore'] ?? 0).toDouble(),
    amount: ofAnime ? (map['minutesWatched'] ?? 0) ~/ 60 : (map['chaptersRead'] ?? 0),
  );

  final String year;
  final int count;
  final double meanScore;
  final int amount;
}
