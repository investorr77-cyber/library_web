# Практическая работа 2. Списки, поиск, фильтрация и пагинация

Клиент библиотечной системы на Flutter Web: каталог книг и авторов.
Данные хранятся в памяти; при перезагрузке страницы восстанавливается начальный набор
(25 книг, 11 авторов).

## Запуск

```bash
flutter pub get
flutter run -d chrome --release --web-hostname=127.0.0.1 --web-port=5555
```

Проверка: `flutter analyze`, `flutter test`.

## Схема слоёв

```
screens  ──►  widgets  ──►  state (provider)  ──►  repositories  ──►  data (seed)
   │                            │                     │
   └───────────── models ◄──────┴─────────────────────┘
```

| Слой | Каталог | Что внутри |
|---|---|---|
| Модели | `lib/models` | `Book`, `Author` с `copyWith`; `PageResult<T>`; `BookQuery`, `AuthorQuery` — условия отбора |
| Данные | `lib/data` | начальный набор записей |
| Репозитории | `lib/repositories` | интерфейсы `BookRepository`, `AuthorRepository` и реализации в памяти |
| Состояние | `lib/state` | `EntityListNotifier<T, Q>` (ChangeNotifier) и наследники для книг и авторов |
| Виджеты | `lib/widgets` | `EntityTable<T>`, `EntityCardList<T>`, `EntityListView`, пагинация, поле с задержкой |
| Экраны | `lib/screens` | списки и карточки книг и авторов |

Виджеты и экраны не обращаются к репозиторию напрямую — только через `provider` и notifier.

## Адрес как состояние

Все условия отбора хранятся в адресе:

```
/books?search=война&genreId=2&publisherId=1&yearFrom=1900&yearTo=1960&sort=year,desc&page=3&size=25&deleted=true
/authors?search=рос&country=Россия&sort=birthYear,desc
```

Экран списка получает `BookQuery.fromParams(state.uri.queryParameters)` от роутера и передаёт его
в notifier. Любое действие пользователя (поиск, фильтр, сортировка, страница) вызывает
`context.go(query.toLocation())`, поэтому ссылку можно отправить коллеге, а кнопка «назад»
браузера возвращает предыдущий набор условий.

## Почему таблица вынесена в обобщённый виджет

Списков в приложении будет много: книги, авторы, жанры, издательства, читатели, выдачи.
`EntityTable<T>` настраивается списком `TableColumnSpec<T>` и один раз реализует выделение,
сортировку со стрелкой, действия строки и двумерную прокрутку. Книги и авторы отличаются
только описанием колонок. Те же описания колонок использует `EntityCardList<T>` для узкого окна.

## Ошибка в `deleteMany`

В исходном коде было:

```dart
final i = _books.indexWhere((b) => b.id == id && !b[i].isDeleted);
```

1. Переменная `i` используется внутри собственного инициализатора — Dart это запрещает.
2. `b` — это объект `Book`, а не список; индексировать его `[i]` нельзя.

Исправление — проверять саму книгу из лямбды:

```dart
final i = _books.indexWhere((b) => b.id == id && !b.isDeleted);
```
