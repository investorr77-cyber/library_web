import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../state/book_list_notifier.dart';
import '../state/lookups.dart';
import '../widgets/details_card.dart';
import '../widgets/list_states.dart';

/// Карточка книги: /books/:id
class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key, required this.id});

  final int? id;

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late Future<(Book?, List<Author>)> _future = _load();

  Future<(Book?, List<Author>)> _load() async {
    final notifier = context.read<BookListNotifier>();
    if (widget.id == null) return (null, <Author>[]);
    final book = await notifier.findById(widget.id!);
    if (book == null) return (null, <Author>[]);
    return (book, await notifier.authorsOf(book));
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<BookListNotifier>();
    final lookups = context.read<Lookups>();
    final backTo = notifier.query.toLocation();

    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        if (snap.hasError) {
          return ErrorView(message: 'Не удалось загрузить книгу: ${snap.error}', onRetry: _reload);
        }
        final (book, authors) = snap.data!;
        if (book == null) {
          return NotFoundBody(
              message: 'Книга с номером ${widget.id ?? '?'} не найдена',
              backTo: backTo);
        }
        return DetailsCard(
          title: book.title,
          deleted: book.isDeleted,
          backTo: backTo,
          rows: {
            'ISBN': book.isbn,
            'Авторы': authors.isEmpty
                ? '—'
                : authors.map((a) => a.fullName).join(', '),
            'Год издания': '${book.year}',
            'Страниц': '${book.pages}',
            'Жанры': book.genreIds.map(lookups.genreName).join(', '),
            'Издательство': lookups.publisherName(book.publisherId),
            'Экземпляров': '${book.copiesAvailable} в наличии из ${book.copiesTotal}',
          },
          links: [
            for (final a in authors)
              ActionChip(
                avatar: const Icon(Icons.person, size: 18),
                label: Text(a.fullName),
                onPressed: () => context.go('/authors/${a.id}'),
              ),
          ],
          onSoftDelete: () async {
            await notifier.softDelete(book.id);
            _reload();
          },
          onRestore: () async {
            await notifier.restore(book.id);
            _reload();
          },
          onHardDelete: () async {
            await notifier.hardDelete(book.id);
            if (context.mounted) context.go(backTo);
          },
        );
      },
    );
  }
}
