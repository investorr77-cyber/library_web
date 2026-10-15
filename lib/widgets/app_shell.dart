import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/fake_network.dart';
import '../state/author_list_notifier.dart';
import '../state/book_list_notifier.dart';

/// Общая рамка приложения: заголовок, переключение разделов
/// (боковая панель на широком окне, нижняя — на узком).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  int get _index => location.startsWith('/authors') ? 1 : 0;

  void _go(BuildContext context, int i) {
    // Возвращаемся к последнему набору условий отбора раздела
    final target = i == 0
        ? context.read<BookListNotifier>().query.toLocation()
        : context.read<AuthorListNotifier>().query.toLocation();
    context.go(target);
  }

  @override
  Widget build(BuildContext context) {
    final network = context.watch<FakeNetwork>();
    final wide = MediaQuery.sizeOf(context).width >= 600;
    const destinations = [
      (Icons.menu_book, 'Книги'),
      (Icons.person, 'Авторы'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Библиотека'),
        actions: [
          Tooltip(
            message: 'Имитировать сбой сервера',
            child: Row(
              children: [
                Icon(network.failRequests ? Icons.cloud_off : Icons.cloud_done),
                Switch(
                  value: network.failRequests,
                  onChanged: (v) => network.failRequests = v,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: _index,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (i) => _go(context, i),
              destinations: [
                for (final (icon, label) in destinations)
                  NavigationRailDestination(
                      icon: Icon(icon), label: Text(label)),
              ],
            ),
          if (wide) const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => _go(context, i),
              destinations: [
                for (final (icon, label) in destinations)
                  NavigationDestination(icon: Icon(icon), label: label),
              ],
            ),
    );
  }
}
