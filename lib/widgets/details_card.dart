import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'confirm_dialog.dart';

/// Общая разметка карточки записи: поля, ссылки и кнопки удаления.
class DetailsCard extends StatelessWidget {
  const DetailsCard({
    super.key,
    required this.title,
    required this.rows,
    required this.deleted,
    required this.backTo,
    required this.onSoftDelete,
    required this.onRestore,
    required this.onHardDelete,
    this.links = const [],
  });

  final String title;
  final Map<String, String> rows;
  final bool deleted;
  final String backTo;
  final List<Widget> links;
  final Future<void> Function() onSoftDelete;
  final Future<void> Function() onRestore;
  final Future<void> Function() onHardDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => context.go(backTo),
                icon: const Icon(Icons.arrow_back),
                label: const Text('К списку'),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.headlineSmall),
                      if (deleted) ...[
                        const SizedBox(height: 8),
                        Chip(
                          avatar: Icon(Icons.delete,
                              color: theme.colorScheme.error, size: 18),
                          label: const Text('Запись удалена'),
                        ),
                      ],
                      const SizedBox(height: 12),
                      for (final e in rows.entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 140,
                                child: Text(e.key,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.outline)),
                              ),
                              Expanded(child: Text(e.value)),
                            ],
                          ),
                        ),
                      if (links.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(spacing: 8, runSpacing: 8, children: links),
                      ],
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (deleted)
                            OutlinedButton.icon(
                              onPressed: onRestore,
                              icon: const Icon(Icons.restore_from_trash),
                              label: const Text('Восстановить'),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: onSoftDelete,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Удалить'),
                            ),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.error),
                            onPressed: () async {
                              final ok = await confirm(
                                context,
                                title: 'Удалить навсегда?',
                                message: '«$title» будет стёрто без '
                                    'возможности восстановления.',
                                action: 'Удалить навсегда',
                              );
                              if (ok) await onHardDelete();
                            },
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Удалить навсегда'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Запись не найдена — например, адрес с несуществующим номером.
class NotFoundBody extends StatelessWidget {
  const NotFoundBody({super.key, required this.message, required this.backTo});

  final String message;
  final String backTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('404', style: theme.textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go(backTo),
              icon: const Icon(Icons.arrow_back),
              label: const Text('К списку'),
            ),
          ],
        ),
      ),
    );
  }
}
