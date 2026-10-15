import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../state/author_list_notifier.dart';
import '../widgets/details_card.dart';
import '../widgets/list_states.dart';

/// Карточка автора: /authors/:id
class AuthorDetailsScreen extends StatefulWidget {
  const AuthorDetailsScreen({super.key, required this.id});

  final int? id;

  @override
  State<AuthorDetailsScreen> createState() => _AuthorDetailsScreenState();
}

class _AuthorDetailsScreenState extends State<AuthorDetailsScreen> {
  late Future<Author?> _future = _load();

  Future<Author?> _load() async => widget.id == null
      ? null
      : context.read<AuthorListNotifier>().findById(widget.id!);

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<AuthorListNotifier>();
    final backTo = notifier.query.toLocation();

    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        if (snap.hasError) {
          return ErrorView(
              message: 'Не удалось загрузить автора: ${snap.error}',
              onRetry: _reload);
        }
        final author = snap.data;
        if (author == null) {
          return NotFoundBody(
              message: 'Автор с номером ${widget.id ?? '?'} не найден',
              backTo: backTo);
        }
        return DetailsCard(
          title: author.fullName,
          deleted: author.isDeleted,
          backTo: backTo,
          rows: {
            'Фамилия': author.lastName,
            'Имя': author.firstName,
            'Страна': author.country,
            'Год рождения': '${author.birthYear}',
          },
          onSoftDelete: () async {
            await notifier.softDelete(author.id);
            _reload();
          },
          onRestore: () async {
            await notifier.restore(author.id);
            _reload();
          },
          onHardDelete: () async {
            await notifier.hardDelete(author.id);
            if (context.mounted) context.go(backTo);
          },
        );
      },
    );
  }
}
