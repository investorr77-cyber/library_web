/// Общая часть условий отбора любого списка: поиск, сортировка,
/// страница и показ удалённых. Нужна обобщённому состоянию списка.
abstract class ListQuery {
  String get search;
  String get sortField;
  bool get sortAscending;
  int get page;
  int get size;
  bool get includeDeleted;

  static const pageSizes = [10, 25, 50];

  /// Адрес списка со всеми условиями отбора в параметрах.
  String toLocation();

  /// `sort=year,desc` — так сортировка хранится в адресе.
  static String encodeSort(String field, bool asc) =>
      asc ? field : '$field,desc';

  static (String, bool) decodeSort(String? raw, String fallback,
      List<String> allowed) {
    if (raw == null || raw.isEmpty) return (fallback, true);
    final parts = raw.split(',');
    final field = allowed.contains(parts.first) ? parts.first : fallback;
    final asc = parts.length < 2 || parts[1] != 'desc';
    return (field, asc);
  }

  static int parsePage(String? raw) {
    final v = int.tryParse(raw ?? '');
    return v == null || v < 1 ? 1 : v;
  }

  static int parseSize(String? raw) {
    final v = int.tryParse(raw ?? '');
    return pageSizes.contains(v) ? v! : pageSizes.first;
  }

  /// Общие параметры адреса; значения по умолчанию в адрес не попадают.
  static Map<String, String> commonParams(ListQuery q, String defaultSort) {
    return {
      if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
      if (q.sortField != defaultSort || !q.sortAscending)
        'sort': encodeSort(q.sortField, q.sortAscending),
      if (q.page != 1) 'page': '${q.page}',
      if (q.size != pageSizes.first) 'size': '${q.size}',
      if (q.includeDeleted) 'deleted': 'true',
    };
  }
}
