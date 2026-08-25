import 'package:isar/isar.dart';

part 'cached_entry.g.dart';

@collection
class CachedEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String cacheKey;

  late String rawJson;

  late DateTime cachedAt;
}
