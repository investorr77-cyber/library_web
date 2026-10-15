import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/author_query.dart';
import 'models/book_query.dart';
import 'screens/author_details_screen.dart';
import 'screens/authors_screen.dart';
import 'screens/book_details_screen.dart';
import 'screens/books_screen.dart';
import 'widgets/app_shell.dart';
import 'widgets/details_card.dart';

final appRouter = GoRouter(
  initialLocation: '/books',
  routes: [
    GoRoute(path: '/', redirect: (_, __) => '/books'),
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(location: state.uri.path, child: child),
      routes: [
        // /books?search=война&genreId=2&sort=year,desc&page=3
        GoRoute(
          path: '/books',
          pageBuilder: (context, state) => NoTransitionPage(
            child: BooksScreen(
                query: BookQuery.fromParams(state.uri.queryParameters)),
          ),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => BookDetailsScreen(
                  key: ValueKey(state.uri.toString()),
                  id: int.tryParse(state.pathParameters['id']!)),
            ),
          ],
        ),
        GoRoute(
          path: '/authors',
          pageBuilder: (context, state) => NoTransitionPage(
            child: AuthorsScreen(
                query: AuthorQuery.fromParams(state.uri.queryParameters)),
          ),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => AuthorDetailsScreen(
                  key: ValueKey(state.uri.toString()),
                  id: int.tryParse(state.pathParameters['id']!)),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Библиотека')),
    body: NotFoundBody(
      message: 'Адрес «${state.uri}» не существует',
      backTo: '/books',
    ),
  ),
);
