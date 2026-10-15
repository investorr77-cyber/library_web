import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/author_query.dart';
import '../state/author_list_notifier.dart';
import '../widgets/debounced_field.dart';
import '../widgets/entity_list_view.dart';
import '../widgets/entity_table.dart';
import '../widgets/row_actions.dart';

/// Список авторов. Использует те же EntityListView и EntityTable,
/// что и книги, — отличается только описанием колонок и фильтров.
class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key, required this.query});

  final AuthorQuery query;

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(AuthorsScreen old) {
    super.didUpdateWidget(old);
    if (old.query != widget.query) _sync();
  }

  void _sync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthorListNotifier>().applyQuery(widget.query);
    });
  }

  void _go(AuthorQuery q) => context.go(q.toLocation());

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AuthorListNotifier>();
    final q = widget.query;

    final columns = <TableColumnSpec<Author>>[
      TableColumnSpec(
          label: 'Фамилия',
          sortField: 'lastName',
          build: (a) => Text(a.lastName)),
      TableColumnSpec(label: 'Имя', build: (a) => Text(a.firstName)),
      TableColumnSpec(
          label: 'Страна', sortField: 'country', build: (a) => Text(a.country)),
      TableColumnSpec(
          label: 'Год рождения',
          sortField: 'birthYear',
          numeric: true,
          build: (a) => Text('${a.birthYear}')),
    ];

    return EntityListView<Author, AuthorQuery>(
      notifier: notifier,
      columns: columns,
      isDeleted: (a) => a.isDeleted,
      onOpen: (a) => context.go('/authors/${a.id}'),
      onSort: (field) => _go(q.copyWith(
        sortField: field,
        sortAscending: field == q.sortField ? !q.sortAscending : true,
      )),
      onPage: (p) => _go(q.copyWith(page: p)),
      onSize: (s) => _go(q.copyWith(size: s)),
      onReset: q.hasFilters ? () => _go(const AuthorQuery()) : null,
      actions: (a) => rowActions(context,
          notifier: notifier,
          item: a,
          deleted: a.isDeleted,
          name: a.fullName),
      filters: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DebouncedField(
            label: 'Поиск по фамилии или стране',
            icon: Icons.search,
            value: q.search,
            onChanged: (v) => _go(q.copyWith(search: v)),
          ),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String?>(
              key: ValueKey('country-${q.country}-${notifier.countries.length}'),
              value: notifier.countries.contains(q.country) ? q.country : null,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Страна',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Все')),
                for (final c in notifier.countries)
                  DropdownMenuItem<String?>(value: c, child: Text(c)),
              ],
              onChanged: (v) => _go(q.copyWith(country: v)),
            ),
          ),
          FilterChip(
            label: const Text('Показать удалённых'),
            selected: q.includeDeleted,
            onSelected: (v) => _go(q.copyWith(includeDeleted: v)),
          ),
        ],
      ),
    );
  }
}
