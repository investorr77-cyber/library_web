import 'list_query.dart';

class BookQuery implements ListQuery {
  @override
  final String search;
  final int? genreId;
  final int? publisherId;
  final int? yearFrom;
  final int? yearTo;
  @override
  final String sortField;
  @override
  final bool sortAscending;
  @override
  final int page;
  @override
  final int size;
  @override
  final bool includeDeleted;

  static const sortFields = ['title', 'year', 'pages'];

  const BookQuery({
    this.search = '',
    this.genreId,
    this.publisherId,
    this.yearFrom,
    this.yearTo,
    this.sortField = 'title',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  bool get hasFilters =>
      search.isNotEmpty ||
      genreId != null ||
      publisherId != null ||
      yearFrom != null ||
      yearTo != null;

  BookQuery copyWith({
    String? search,
    Object? genreId = _unset,
    Object? publisherId = _unset,
    Object? yearFrom = _unset,
    Object? yearTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return BookQuery(
      search: search ?? this.search,
      genreId: genreId == _unset ? this.genreId : genreId as int?,
      publisherId:
          publisherId == _unset ? this.publisherId : publisherId as int?,
      yearFrom: yearFrom == _unset ? this.yearFrom : yearFrom as int?,
      yearTo: yearTo == _unset ? this.yearTo : yearTo as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      // Любое изменение условий отбора возвращает на первую страницу
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  static const _unset = Object();

  /// Восстанавливает условия отбора из параметров адреса.
  /// Некорректные значения молча заменяются значениями по умолчанию.
  factory BookQuery.fromParams(Map<String, String> p) {
    final (field, asc) =
        ListQuery.decodeSort(p['sort'], 'title', sortFields);
    return BookQuery(
      search: p['search'] ?? '',
      genreId: int.tryParse(p['genreId'] ?? ''),
      publisherId: int.tryParse(p['publisherId'] ?? ''),
      yearFrom: int.tryParse(p['yearFrom'] ?? ''),
      yearTo: int.tryParse(p['yearTo'] ?? ''),
      sortField: field,
      sortAscending: asc,
      page: ListQuery.parsePage(p['page']),
      size: ListQuery.parseSize(p['size']),
      includeDeleted: p['deleted'] == 'true',
    );
  }

  Map<String, String> toParams() => {
        ...ListQuery.commonParams(this, 'title'),
        if (genreId != null) 'genreId': '$genreId',
        if (publisherId != null) 'publisherId': '$publisherId',
        if (yearFrom != null) 'yearFrom': '$yearFrom',
        if (yearTo != null) 'yearTo': '$yearTo',
      };

  @override
  String toLocation() {
    final params = toParams();
    return Uri(path: '/books', queryParameters: params.isEmpty ? null : params)
        .toString();
  }

  @override
  bool operator ==(Object other) =>
      other is BookQuery && other.toLocation() == toLocation();

  @override
  int get hashCode => toLocation().hashCode;
}
