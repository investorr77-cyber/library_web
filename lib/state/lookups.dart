import '../data/seed.dart';
import '../models/reference.dart';

/// Справочники жанров и издательств для фильтров и подписей.
class Lookups {
  const Lookups({this.genres = seedGenres, this.publishers = seedPublishers});

  final List<Genre> genres;
  final List<Publisher> publishers;

  String genreName(int id) =>
      genres.where((g) => g.id == id).map((g) => g.name).firstOrNull ?? '—';

  String publisherName(int id) =>
      publishers.where((p) => p.id == id).map((p) => p.name).firstOrNull ??
      '—';
}
