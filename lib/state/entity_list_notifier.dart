import 'package:flutter/foundation.dart';

import '../models/list_query.dart';
import '../models/page_result.dart';
import '../repositories/entity_repository.dart';

enum LoadStatus { idle, loading, success, error }

/// Состояние экрана списка. Одна реализация на все сущности:
/// книги и авторы отличаются только типами T и Q.
class EntityListNotifier<T, Q extends ListQuery> extends ChangeNotifier {
  EntityListNotifier(this._repository, this._query, this._idOf);

  final EntityRepository<T, Q> _repository;
  final int Function(T item) _idOf;

  Q _query;
  PageResult<T> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};

  Q get query => _query;
  PageResult<T> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  int idOf(T item) => _idOf(item);

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить список: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Применяет условия отбора. Повторный вызов с теми же условиями
  /// ничего не делает: так экран может безопасно синхронизироваться с адресом.
  Future<void> applyQuery(Q next, {bool force = false}) async {
    if (!force && next == _query && _status != LoadStatus.idle) return;
    if (next != _query) {
      _selected.clear(); // выделение теряет смысл при смене условий отбора
    }
    _query = next;
    await load();
  }

  void toggleSelection(int id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    notifyListeners();
  }

  /// Выделить или снять выделение со всех записей текущей страницы.
  void togglePage(bool select) {
    final ids = _result.items.map(_idOf);
    select ? _selected.addAll(ids) : _selected.removeAll(ids);
    notifyListeners();
  }

  void clearSelection() {
    _selected.clear();
    notifyListeners();
  }

  /// Выполняет изменяющую операцию и перезапрашивает список.
  /// Ошибку операции показывает как состояние ошибки экрана.
  Future<void> _mutate(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      _error = 'Операция не выполнена: $e';
      _status = LoadStatus.error;
      notifyListeners();
      return;
    }
    await load();
  }

  Future<int> deleteSelected() async {
    var count = 0;
    await _mutate(() async {
      count = await _repository.deleteMany(_selected.toList());
      _selected.clear();
    });
    return count;
  }

  Future<void> softDelete(int id) =>
      _mutate(() => _repository.softDelete(id));

  Future<void> hardDelete(int id) => _mutate(() async {
        await _repository.hardDelete(id);
        _selected.remove(id);
      });

  Future<void> restore(int id) => _mutate(() => _repository.restore(id));

  Future<T?> findById(int id) => _repository.findById(id);
}
