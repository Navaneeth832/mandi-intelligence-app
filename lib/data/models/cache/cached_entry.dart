class CachedEntry {
  final String cacheKey;
  final String rawJson;
  final DateTime cachedAt;

  CachedEntry({
    required this.cacheKey,
    required this.rawJson,
    required this.cachedAt,
  });
}
