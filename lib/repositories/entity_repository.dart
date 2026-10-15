import '../models/page_result.dart';

/// Операции, общие для всех сущностей каталога.
abstract interface class EntityRepository<T, Q> {
  Future<PageResult<T>> find(Q query);
  Future<T?> findById(int id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}
