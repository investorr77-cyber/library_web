import 'package:flutter/material.dart';

import 'entity_table.dart';

/// Тот же список в виде карточек для узкого окна.
/// Использует те же описания колонок, что и [EntityTable].
class EntityCardList<T> extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final bool Function(T item)? isDeleted;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final List<Widget> Function(T item)? actions;
  final ValueChanged<T>? onOpen;

  const EntityCardList({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.isDeleted,
    this.selected = const {},
    this.onToggleSelect,
    this.actions,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final id = idOf(item);
        final deleted = isDeleted?.call(item) == true;
        final isSelected = selected.contains(id);
        return Card(
          margin: EdgeInsets.zero,
          color: isSelected ? theme.colorScheme.secondaryContainer : null,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onOpen == null ? null : () => onOpen!(item),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (onToggleSelect != null)
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onToggleSelect!(id),
                    ),
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: deleted
                          ? TextStyle(
                              color: theme.colorScheme.outline,
                              decoration: TextDecoration.lineThrough,
                            )
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Первая колонка — заголовок карточки
                          DefaultTextStyle.merge(
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: deleted ? theme.colorScheme.outline : null,
                              decoration:
                                  deleted ? TextDecoration.lineThrough : null,
                            ),
                            child: columns.first.build(item),
                          ),
                          const SizedBox(height: 4),
                          for (final c in columns.skip(1))
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                children: [
                                  Text('${c.label}: ',
                                      style: theme.textTheme.bodySmall),
                                  Flexible(child: c.build(item)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (actions != null)
                    Column(mainAxisSize: MainAxisSize.min, children: actions!(item)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
