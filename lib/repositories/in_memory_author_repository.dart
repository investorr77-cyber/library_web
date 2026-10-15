import '../data/seed.dart';
import '../models/author.dart';
import '../models/author_query.dart';
import '../models/page_result.dart';
import '../services/fake_network.dart';
import 'author_repository.dart';

class InMemoryAuthorRepository implements AuthorRepository {
  InMemoryAuthorRepository(this._network);

  final FakeNetwork _network;
  final List<Author> _authors = [...seedAuthors];
  late int _nextId =
      _authors.map((a) => a.id).fold(0, (a, b) => a > b ? a : b) + 1;

  @override
  Future<PageResult<Author>> find(AuthorQuery q) async {
    await _network.roundTrip();

    var rows =
        _authors.where((a) => q.includeDeleted || !a.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((a) =>
              a.lastName.toLowerCase().contains(needle) ||
              a.country.toLowerCase().contains(needle))
          .toList();
    }
    if (q.country != null) {
      rows = rows.where((a) => a.country == q.country).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'country' => a.country.compareTo(b.country),
        'birthYear' => a.birthYear.compareTo(b.birthYear),
        _ => a.lastName.compareTo(b.lastName),
      };
      return q.sortAscending ? result : -result;
    });

    return PageResult.slice(rows, q.page, q.size);
  }

  @override
  Future<List<String>> countries() async =>
      (_authors.map((a) => a.country).toSet().toList()..sort());

  @override
  Future<List<Author>> findByIds(List<int> ids) async {
    await _network.roundTrip();
    return _authors.where((a) => ids.contains(a.id)).toList();
  }

  @override
  Future<Author?> findById(int id) async {
    await _network.roundTrip();
    for (final a in _authors) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Future<Author> create(Author author) async {
    await _network.roundTrip();
    final created = author.copyWith(id: _nextId++);
    _authors.add(created);
    return created;
  }

  @override
  Future<Author> update(Author author) async {
    await _network.roundTrip();
    final i = _authors.indexWhere((a) => a.id == author.id);
    if (i == -1) throw StateError('Автор ${author.id} не найден');
    _authors[i] = author;
    return author;
  }

  @override
  Future<void> softDelete(int id) async {
    await _network.roundTrip();
    final i = _authors.indexWhere((a) => a.id == id);
    if (i == -1) throw StateError('Автор $id не найден');
    _authors[i] = _authors[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    await _network.roundTrip();
    _authors.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> restore(int id) async {
    await _network.roundTrip();
    final i = _authors.indexWhere((a) => a.id == id);
    if (i == -1) throw StateError('Автор $id не найден');
    _authors[i] = _authors[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    await _network.roundTrip();
    var count = 0;
    for (final id in ids) {
      final i = _authors.indexWhere((a) => a.id == id && !a.isDeleted);
      if (i != -1) {
        _authors[i] = _authors[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
