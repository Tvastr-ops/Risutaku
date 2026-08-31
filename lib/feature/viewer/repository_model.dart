import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

/// Central repository gateway for all AniList GraphQL operations.
/// Features in-flight query deduplication, rate limit tracking, and resilient retry logic.
class Repository {
  static final _url = Uri.parse('https://graphql.anilist.co');

  // In-flight query deduplication cache to prevent duplicate simultaneous network hits.
  static final Map<String, Future<Map<String, dynamic>>> _inflightQueries = {};

  // Rate limit tracking metrics from AniList headers.
  static int? _rateLimitRemaining;
  static DateTime? _rateLimitReset;

  Repository(String? accessToken)
    : _headers = {
        'Accept': 'application/json',
        'Content-type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

  final Map<String, String> _headers;

  /// Returns the estimated number of AniList requests remaining in the current minute window.
  static int? get rateLimitRemaining => _rateLimitRemaining;

  Future<Map<String, dynamic>> request(
    String query, [
    Map<String, dynamic> variables = const {},
  ]) async {
    final isMutation = query.trimLeft().startsWith('mutation');
    final cacheKey = isMutation ? null : json.encode({
      'q': query,
      'v': variables,
      'auth': _headers['Authorization'] ?? '',
    });

    if (cacheKey != null && _inflightQueries.containsKey(cacheKey)) {
      return _inflightQueries[cacheKey]!;
    }

    final future = _executeWithRetry(query, variables);

    if (cacheKey != null) {
      _inflightQueries[cacheKey] = future;
      future.whenComplete(() => _inflightQueries.remove(cacheKey));
    }

    return future;
  }

  Future<Map<String, dynamic>> _executeWithRetry(
    String query,
    Map<String, dynamic> variables, {
    int retriesLeft = 1,
  }) async {
    // If we are known to be actively rate-limited, wait for the reset window
    if (_rateLimitReset != null && DateTime.now().isBefore(_rateLimitReset!)) {
      final waitDuration = _rateLimitReset!.difference(DateTime.now());
      if (waitDuration.inSeconds <= 10) {
        await Future.delayed(waitDuration);
      }
    }

    try {
      final response = await post(
        _url,
        body: json.encode({'query': query, 'variables': variables}),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      // Update rate limit tracking from AniList response headers
      final remainingHeader = response.headers['x-ratelimit-remaining'];
      if (remainingHeader != null) {
        _rateLimitRemaining = int.tryParse(remainingHeader);
      }

      // Handle 429 Too Many Requests
      if (response.statusCode == 429) {
        final retryAfterHeader = response.headers['retry-after'];
        final waitSeconds = int.tryParse(retryAfterHeader ?? '') ?? 5;
        _rateLimitReset = DateTime.now().add(Duration(seconds: waitSeconds));

        if (retriesLeft > 0 && waitSeconds <= 10) {
          await Future.delayed(Duration(seconds: waitSeconds));
          return await _executeWithRetry(query, variables, retriesLeft: retriesLeft - 1);
        }

        throw StateError('AniList rate limit reached. Please wait $waitSeconds seconds.');
      }

      if (response.statusCode >= 500) {
        throw Exception('AniList servers are temporarily unavailable (${response.statusCode}).');
      }

      final Map<String, dynamic> body = json.decode(response.body);

      if (body.containsKey('errors')) {
        throw StateError((body['errors'] as List).map((e) => e['message'].toString()).join(', '));
      }

      return body['data'];
    } on SocketException {
      throw Exception('Failed to connect to AniList');
    } on TimeoutException {
      throw Exception('AniList request timed out');
    }
  }
}
