import '../data/seed.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import '../services/fake_network.dart';
import 'book_repository.dart';

class InMemoryBookRepository implements BookRepository {
  InMemoryBookRepository(this._network);

  final FakeNetwork _network;
  final List<Book> _books = [...seedBooks];
  late int _nextId =
      _books.map((b) => b.id).fold(0, (a, b) => a > b ? a : b) + 1;

  @override
  Future<PageResult<Book>> find(BookQuery q) async {
    await _network.roundTrip();

    var rows = _books.where((b) => q.includeDeleted || !b.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((b) =>
              b.title.toLowerCase().contains(needle) ||
              b.isbn.toLowerCase().contains(needle))
          .toList();
    }
    if (q.genreId != null) {
      rows = rows.where((b) => b.genreIds.contains(q.genreId)).toList();
    }
    if (q.publisherId != null) {
      rows = rows.where((b) => b.publisherId == q.publisherId).toList();
    }
    if (q.yearFrom != null) {
      rows = rows.where((b) => b.year >= q.yearFrom!).toList();
    }
    if (q.yearTo != null) {
      rows = rows.where((b) => b.year <= q.yearTo!).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'year' => a.year.compareTo(b.year),
        'pages' => a.pages.compareTo(b.pages),
        _ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    return PageResult.slice(rows, q.page, q.size);
  }

  @override
  Future<Book?> findById(int id) async {
    await _network.roundTrip();
    for (final b in _books) {
      if (b.id == id) return b;
    }
    return null;
  }

  @override
  Future<Book> create(Book book) async {
    await _network.roundTrip();
    final created = book.copyWith(id: _nextId++);
    _books.add(created);
    return created;
  }

  @override
  Future<Book> update(Book book) async {
    await _network.roundTrip();
    final i = _books.indexWhere((b) => b.id == book.id);
    if (i == -1) throw StateError('Книга ${book.id} не найдена');
    _books[i] = book;
    return book;
  }

  @override
  Future<void> softDelete(int id) async {
    await _network.roundTrip();
    final i = _books.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Книга $id не найдена');
    _books[i] = _books[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    await _network.roundTrip();
    _books.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> restore(int id) async {
    await _network.roundTrip();
    final i = _books.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Книга $id не найдена');
    _books[i] = _books[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    await _network.roundTrip();
    var count = 0;
    for (final id in ids) {
      // Исправлено: было `!b[i].isDeleted` — обращение к переменной i
      // внутри её же инициализатора и индексация объекта Book.
      // Проверять нужно саму книгу b из лямбды.
      final i = _books.indexWhere((b) => b.id == id && !b.isDeleted);
      if (i != -1) {
        _books[i] = _books[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
