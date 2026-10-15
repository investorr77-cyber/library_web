import 'package:flutter_test/flutter_test.dart';
import 'package:library_web/models/book_query.dart';
import 'package:library_web/repositories/in_memory_book_repository.dart';
import 'package:library_web/services/fake_network.dart';

void main() {
  late InMemoryBookRepository repo;

  setUp(() => repo = InMemoryBookRepository(FakeNetwork()));

  test('пагинация: 25 книг, страница 3 по 10 содержит 5 записей', () async {
    final r = await repo.find(const BookQuery(page: 3));
    expect(r.total, 25);
    expect(r.totalPages, 3);
    expect(r.items.length, 5);
  });

  test('фильтры комбинируются с поиском', () async {
    final r = await repo.find(const BookQuery(
        search: 'а', genreId: 7, yearFrom: 1900, yearTo: 1950));
    expect(r.items, isNotEmpty);
    for (final b in r.items) {
      expect(b.genreIds, contains(7));
      expect(b.year, inInclusiveRange(1900, 1950));
    }
  });

  test('сортировка по году по убыванию', () async {
    final r =
        await repo.find(const BookQuery(sortField: 'year', sortAscending: false));
    final years = r.items.map((b) => b.year).toList();
    expect(years, [...years]..sort((a, b) => b.compareTo(a)));
  });

  test('deleteMany помечает книги удалёнными и пропускает уже удалённые',
      () async {
    expect(await repo.deleteMany([1, 2]), 2);
    expect(await repo.deleteMany([1, 3]), 1);
    final visible = await repo.find(const BookQuery(size: 50));
    expect(visible.total, 22);
    final all =
        await repo.find(const BookQuery(size: 50, includeDeleted: true));
    expect(all.total, 25);
  });

  test('восстановление и физическое удаление', () async {
    await repo.softDelete(5);
    await repo.restore(5);
    expect((await repo.findById(5))!.isDeleted, isFalse);
    await repo.hardDelete(5);
    expect(await repo.findById(5), isNull);
  });

  test('условия отбора переживают перевод в адрес и обратно', () {
    const q = BookQuery(
        search: 'война',
        genreId: 2,
        sortField: 'year',
        sortAscending: false,
        page: 3);
    final uri = Uri.parse(q.toLocation());
    expect(uri.queryParameters['sort'], 'year,desc');
    expect(BookQuery.fromParams(uri.queryParameters), q);
  });
}
