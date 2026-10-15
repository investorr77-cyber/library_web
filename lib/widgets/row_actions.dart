import 'package:flutter/material.dart';

import '../state/entity_list_notifier.dart';
import 'confirm_dialog.dart';

/// Кнопки действий строки: логическое удаление или восстановление
/// и физическое удаление. Одинаковы для всех сущностей.
List<Widget> rowActions<T>(
  BuildContext context, {
  required EntityListNotifier<T, dynamic> notifier,
  required T item,
  required bool deleted,
  required String name,
}) {
  final id = notifier.idOf(item);
  final error = Theme.of(context).colorScheme.error;
  return [
    if (!deleted)
      IconButton(
        tooltip: 'Удалить (можно восстановить)',
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          await notifier.softDelete(id);
          if (context.mounted) showMessage(context, '«$name» перемещено в удалённые');
        },
      )
    else
      IconButton(
        tooltip: 'Восстановить',
        icon: const Icon(Icons.restore_from_trash),
        onPressed: () async {
          await notifier.restore(id);
          if (context.mounted) showMessage(context, '«$name» восстановлено');
        },
      ),
    IconButton(
      tooltip: 'Удалить навсегда',
      icon: Icon(Icons.delete_forever, color: error),
      onPressed: () async {
        final ok = await confirm(
          context,
          title: 'Удалить навсегда?',
          message: '«$name» будет стёрто без возможности восстановления.',
          action: 'Удалить навсегда',
        );
        if (!ok) return;
        await notifier.hardDelete(id);
        if (context.mounted) showMessage(context, '«$name» удалено навсегда');
      },
    ),
  ];
}
