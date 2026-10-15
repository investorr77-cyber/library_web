import 'list_query.dart';

class AuthorQuery implements ListQuery {
  @override
  final String search;
  final String? country;
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

  static const sortFields = ['lastName', 'country', 'birthYear'];

  const AuthorQuery({
    this.search = '',
    this.country,
    this.sortField = 'lastName',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  bool get hasFilters => search.isNotEmpty || country != null;

  AuthorQuery copyWith({
    String? search,
    Object? country = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return AuthorQuery(
      search: search ?? this.search,
      country: country == _unset ? this.country : country as String?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      // Любое изменение условий отбора возвращает на первую страницу
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  static const _unset = Object();

  factory AuthorQuery.fromParams(Map<String, String> p) {
    final (field, asc) =
        ListQuery.decodeSort(p['sort'], 'lastName', sortFields);
    final country = p['country'];
    return AuthorQuery(
      search: p['search'] ?? '',
      country: country == null || country.isEmpty ? null : country,
      sortField: field,
      sortAscending: asc,
      page: ListQuery.parsePage(p['page']),
      size: ListQuery.parseSize(p['size']),
      includeDeleted: p['deleted'] == 'true',
    );
  }

  Map<String, String> toParams() => {
        ...ListQuery.commonParams(this, 'lastName'),
        if (country != null) 'country': country!,
      };

  @override
  String toLocation() {
    final params = toParams();
    return Uri(
            path: '/authors', queryParameters: params.isEmpty ? null : params)
        .toString();
  }

  @override
  bool operator ==(Object other) =>
      other is AuthorQuery && other.toLocation() == toLocation();

  @override
  int get hashCode => toLocation().hashCode;
}
