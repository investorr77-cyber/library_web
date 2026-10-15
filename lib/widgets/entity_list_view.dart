import 'package:flutter/material.dart';

import '../models/list_query.dart';
import '../state/entity_list_notifier.dart';
import 'confirm_dialog.dart';
import 'entity_card_list.dart';
import 'entity_table.dart';
import 'list_states.dart';
import 'pagination_bar.dart';

/// Ширина, начиная с которой вместо карточек показывается таблица.
const tableBreakpoint = 600.0;

/// Всё, что одинаково у любого списка: состояния загрузки, выделение,
/// множественное удаление, смена таблицы на карточки и пагинация.
class EntityListView<T, Q extends ListQuery> extends StatelessWidget {
  const EntityListView({
    super.key,
    required this.notifier,
    required this.columns,
    required this.filters,
    required this.isDeleted,
    required this.onSort,
    required this.onPage,
    required this.onSize,
    required this.onOpen,
    required this.actions,
    this.onReset,
  });

  final EntityListNotifier<T, Q> notifier;
  final List<TableColumnSpec<T>> columns;
  final Widget filters;
  final bool Function(T item) isDeleted;
  final void Function(String field) onSort;
  final ValueChanged<int> onPage;
  final ValueChanged<int> onSize;
  final ValueChanged<T> onOpen;
  final List<Widget> Function(T item) actions;
  final VoidCallback? onReset;

  Future<void> _deleteSelected(BuildContext context) async {
    final n = notifier.selected.length;
    final ok = await confirm(
      context,
      title: 'Удалить выбранные?',
      message: 'Будет удалено записей: $n. Их можно будет восстановить, '
          'включив показ удалённых.',
    );
    if (!ok || !context.mounted) return;
    final count = await notifier.deleteSelected();
    if (context.mounted) showMessage(context, 'Удалено записей: $count');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= tableBreakpoint;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            Padding(padding: const EdgeInsets.all(8), child: filters)
          else
            // На узком экране фильтры сворачиваются, чтобы оставить место списку
            ExpansionTile(
              leading: const Icon(Icons.filter_list),
              title: const Text('Поиск и фильтры'),
              childrenPadding: const EdgeInsets.all(8),
              expandedAlignment: Alignment.centerLeft,
              children: [filters],
            ),
          _toolbar(context, wide),
          if (notifier.status == LoadStatus.loading &&
              notifier.result.items.isNotEmpty)
            const LinearProgressIndicator(),
          Expanded(child: _content(context, wide)),
          if (notifier.status != LoadStatus.error) const Divider(height: 1),
          if (notifier.status != LoadStatus.error)
            PaginationBar(
              result: notifier.result,
              onPage: onPage,
              onSize: onSize,
            ),
        ],
      );
    });
  }

  Widget _toolbar(BuildContext context, bool wide) {
    final theme = Theme.of(context);
    final q = notifier.query;
    final sortable = columns.where((c) => c.sortField != null).toList();
    // Минимальная высота не даёт таблице прыгать при появлении кнопок выделения
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          if (notifier.hasSelection) ...[
            Text('Выбрано: ${notifier.selected.length}',
                style: theme.textTheme.titleSmall),
            TextButton(
              onPressed: notifier.clearSelection,
              child: const Text('Снять выделение'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error),
              onPressed: () => _deleteSelected(context),
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Удалить выбранные'),
            ),
          ] else
            Text('Отметьте записи флажками для множественного удаления',
                style: theme.textTheme.bodySmall),
          // В режиме карточек заголовков колонок нет — сортировка списком
          if (!wide && sortable.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Сортировка: '),
                DropdownButton<String>(
                  value: q.sortField,
                  underline: const SizedBox(),
                  items: [
                    for (final c in sortable)
                      DropdownMenuItem(value: c.sortField, child: Text(c.label)),
                  ],
                  onChanged: (f) => f == null ? null : onSort(f),
                ),
                IconButton(
                  tooltip: 'Направление сортировки',
                  icon: Icon(q.sortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward),
                  onPressed: () => onSort(q.sortField),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, bool wide) {
    final items = notifier.result.items;
    switch (notifier.status) {
      case LoadStatus.idle:
        return const LoadingView();
      case LoadStatus.loading when items.isEmpty:
        return const LoadingView();
      case LoadStatus.error:
        return ErrorView(
          message: notifier.error ?? 'Неизвестная ошибка',
          onRetry: notifier.load,
        );
      case LoadStatus.success when items.isEmpty:
        return EmptyView(onReset: onReset);
      default:
        break;
    }

    if (wide) {
      return EntityTable<T>(
        columns: columns,
        items: items,
        idOf: notifier.idOf,
        isDeleted: isDeleted,
        selected: notifier.selected,
        onToggleSelect: notifier.toggleSelection,
        onToggleAll: notifier.togglePage,
        sortField: notifier.query.sortField,
        sortAscending: notifier.query.sortAscending,
        onSort: onSort,
        actions: actions,
        onOpen: onOpen,
      );
    }
    return EntityCardList<T>(
      columns: columns,
      items: items,
      idOf: notifier.idOf,
      isDeleted: isDeleted,
      selected: notifier.selected,
      onToggleSelect: notifier.toggleSelection,
      actions: actions,
      onOpen: onOpen,
    );
  }
}
