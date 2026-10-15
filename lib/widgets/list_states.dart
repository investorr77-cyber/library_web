import 'package:flutter/material.dart';

/// Состояние «загружается».
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Загрузка…'),
          ],
        ),
      );
}

/// Состояние «успешно, но пусто» — выглядит иначе, чем ошибка.
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.onReset});

  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('Ничего не найдено', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Попробуйте изменить условия поиска или фильтры.',
                textAlign: TextAlign.center),
            if (onReset != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Сбросить фильтры'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Состояние «ошибка».
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text('Ошибка',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.error)),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
