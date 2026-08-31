import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risutaku/feature/viewer/persistence_provider.dart';
import 'package:risutaku/feature/home/home_model.dart';

final homeProvider = NotifierProvider.autoDispose<HomeNotifier, Home>(HomeNotifier.new);

class HomeNotifier extends Notifier<Home> {
  @override
  Home build() {
    final options = ref.watch(persistenceProvider.select((s) => s.options));

    return switch (stateOrNull) {
      Home oldState => oldState,
      null => Home(
        didExpandAnimeCollection: !options.animeCollectionPreview,
        didExpandMangaCollection: !options.mangaCollectionPreview,
      ),
    };
  }

  void expandCollection(bool ofAnime) => state = state.withExpandedCollection(ofAnime);
}
