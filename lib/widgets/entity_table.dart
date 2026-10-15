import 'package:flutter/material.dart';

/// Описание одной колонки: подпись, поле сортировки и способ отрисовки ячейки.
class TableColumnSpec<T> {
  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

/// Обобщённая таблица для любой сущности. Книги и авторы отличаются
/// только списком [columns]; выделение, сортировка и действия — общие.
class EntityTable<T> extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final bool Function(T item)? isDeleted;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final ValueChanged<bool>? onToggleAll;
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;
  final ValueChanged<T>? onOpen;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.isDeleted,
    this.selected = const {},
    this.onToggleSelect,
    this.onToggleAll,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortIndex = columns.indexWhere(
        (c) => c.sortField != null && c.sortField == sortField);

    final table = DataTable(
      showCheckboxColumn: onToggleSelect != null,
      sortColumnIndex: sortIndex == -1 ? null : sortIndex,
      sortAscending: sortAscending,
      onSelectAll: onToggleAll == null
          ? null
          : (value) => onToggleAll!(value ?? false),
      headingTextStyle:
          theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      columns: [
        for (final c in columns)
          DataColumn(
            label: Text(c.label),
            numeric: c.numeric,
            // Стрелку в активной колонке рисует сам DataTable
            onSort: c.sortField == null || onSort == null
                ? null
                : (_, __) => onSort!(c.sortField!),
          ),
        if (actions != null) const DataColumn(label: Text('Действия')),
      ],
      rows: [
        for (final item in items)
          DataRow(
            selected: selected.contains(idOf(item)),
            onSelectChanged: onToggleSelect == null
                ? null
                : (_) => onToggleSelect!(idOf(item)),
            cells: [
              for (final c in columns)
                DataCell(
                  DefaultTextStyle.merge(
                    style: isDeleted?.call(item) == true
                        ? TextStyle(
                            color: theme.colorScheme.outline,
                            decoration: TextDecoration.lineThrough,
                          )
                        : null,
                    child: c.build(item),
                  ),
                  onTap: onOpen == null ? null : () => onOpen!(item),
                ),
              if (actions != null)
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!(item),
                )),
            ],
          ),
      ],
    );

    // Двумерная прокрутка: таблица не уезжает за край окна
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: table,
          ),
        ),
      ),
    );
  }
}
