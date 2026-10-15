import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/book_query.dart';
import '../state/book_list_notifier.dart';
import '../state/lookups.dart';
import '../widgets/debounced_field.dart';
import '../widgets/entity_list_view.dart';
import '../widgets/entity_table.dart';
import '../widgets/row_actions.dart';

/// Список книг. Условия отбора приходят из адреса: экран лишь передаёт
/// их в состояние, а любое действие пользователя меняет адрес.
class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key, required this.query});

  final BookQuery query;

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(BooksScreen old) {
    super.didUpdateWidget(old);
    if (old.query != widget.query) _sync();
  }

  /// Адрес → состояние. Вызывается при открытии и при каждой смене адреса,
  /// в том числе по кнопке «назад» браузера.
  void _sync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BookListNotifier>().applyQuery(widget.query);
    });
  }

  /// Состояние → адрес. Новый адрес попадает в историю браузера.
  void _go(BookQuery q) => context.go(q.toLocation());

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BookListNotifier>();
    final lookups = context.read<Lookups>();
    final q = widget.query;

    final columns = <TableColumnSpec<Book>>[
      TableColumnSpec(
          label: 'Название', sortField: 'title', build: (b) => Text(b.title)),
      TableColumnSpec(label: 'ISBN', build: (b) => Text(b.isbn)),
      TableColumnSpec(
          label: 'Год',
          sortField: 'year',
          numeric: true,
          build: (b) => Text('${b.year}')),
      TableColumnSpec(
          label: 'Страниц',
          sortField: 'pages',
          numeric: true,
          build: (b) => Text('${b.pages}')),
      TableColumnSpec(
          label: 'Жанры',
          build: (b) => Text(b.genreIds.map(lookups.genreName).join(', '))),
      TableColumnSpec(
          label: 'Издательство',
          build: (b) => Text(lookups.publisherName(b.publisherId))),
      TableColumnSpec(
          label: 'В наличии',
          numeric: true,
          build: (b) => Text('${b.copiesAvailable} / ${b.copiesTotal}')),
    ];

    return EntityListView<Book, BookQuery>(
      notifier: notifier,
      columns: columns,
      isDeleted: (b) => b.isDeleted,
      onOpen: (b) => context.go('/books/${b.id}'),
      onSort: (field) => _go(q.copyWith(
        sortField: field,
        sortAscending: field == q.sortField ? !q.sortAscending : true,
      )),
      onPage: (p) => _go(q.copyWith(page: p)),
      onSize: (s) => _go(q.copyWith(size: s)),
      onReset: q.hasFilters ? () => _go(const BookQuery()) : null,
      actions: (b) => rowActions(context,
          notifier: notifier, item: b, deleted: b.isDeleted, name: b.title),
      filters: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DebouncedField(
            label: 'Поиск по названию или ISBN',
            icon: Icons.search,
            value: q.search,
            onChanged: (v) => _go(q.copyWith(search: v)),
          ),
          _Dropdown(
            label: 'Жанр',
            value: q.genreId,
            items: {for (final g in lookups.genres) g.id: g.name},
            onChanged: (v) => _go(q.copyWith(genreId: v)),
          ),
          _Dropdown(
            label: 'Издательство',
            value: q.publisherId,
            items: {for (final p in lookups.publishers) p.id: p.name},
            onChanged: (v) => _go(q.copyWith(publisherId: v)),
          ),
          DebouncedField(
            label: 'Год с',
            width: 110,
            numeric: true,
            value: q.yearFrom?.toString() ?? '',
            onChanged: (v) => _go(q.copyWith(yearFrom: int.tryParse(v))),
          ),
          DebouncedField(
            label: 'Год по',
            width: 110,
            numeric: true,
            value: q.yearTo?.toString() ?? '',
            onChanged: (v) => _go(q.copyWith(yearTo: int.tryParse(v))),
          ),
          FilterChip(
            label: const Text('Показать удалённые'),
            selected: q.includeDeleted,
            onSelected: (v) => _go(q.copyWith(includeDeleted: v)),
          ),
          if (q.hasFilters)
            TextButton.icon(
              onPressed: () => _go(BookQuery(
                  includeDeleted: q.includeDeleted,
                  size: q.size,
                  sortField: q.sortField,
                  sortAscending: q.sortAscending)),
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Сбросить'),
            ),
        ],
      ),
    );
  }
}

/// Выпадающий список фильтра с пунктом «Все».
class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final Map<int, String> items;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<int?>(
        // key пересоздаёт поле, когда значение меняется через адрес
        key: ValueKey('$label-$value'),
        value: items.containsKey(value) ? value : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('Все')),
          for (final e in items.entries)
            DropdownMenuItem<int?>(value: e.key, child: Text(e.value)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
