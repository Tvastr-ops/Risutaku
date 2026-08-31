import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risutaku/util/graphql.dart';
import 'package:risutaku/feature/tag/tag_model.dart';
import 'package:risutaku/feature/viewer/repository_provider.dart';

final tagsProvider = FutureProvider(
  (ref) async => TagCollection(await ref.read(repositoryProvider).request(GqlQuery.genresAndTags)),
);
