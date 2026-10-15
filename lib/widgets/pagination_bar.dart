import 'package:flutter/material.dart';

import '../models/list_query.dart';
import '../models/page_result.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.result,
    required this.onPage,
    required this.onSize,
  });

  final PageResult result;
  final ValueChanged<int> onPage;
  final ValueChanged<int> onSize;

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 4,
        children: [
          Text('Страница ${r.page} из ${r.totalPages} · всего записей: ${r.total}'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('На странице: '),
              DropdownButton<int>(
                value: r.size,
                underline: const SizedBox(),
                items: [
                  for (final s in ListQuery.pageSizes)
                    DropdownMenuItem(value: s, child: Text('$s')),
                ],
                onChanged: (v) => v == null ? null : onSize(v),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Первая страница',
                icon: const Icon(Icons.first_page),
                onPressed: r.hasPrevious ? () => onPage(1) : null,
              ),
              IconButton(
                tooltip: 'Предыдущая страница',
                icon: const Icon(Icons.chevron_left),
                onPressed: r.hasPrevious ? () => onPage(r.page - 1) : null,
              ),
              IconButton(
                tooltip: 'Следующая страница',
                icon: const Icon(Icons.chevron_right),
                onPressed: r.hasNext ? () => onPage(r.page + 1) : null,
              ),
              IconButton(
                tooltip: 'Последняя страница',
                icon: const Icon(Icons.last_page),
                onPressed: r.hasNext ? () => onPage(r.totalPages) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
