import '../models/author.dart';
import '../models/author_query.dart';
import 'entity_repository.dart';

abstract interface class AuthorRepository
    implements EntityRepository<Author, AuthorQuery> {
  /// Список всех стран — для фильтра.
  Future<List<String>> countries();

  /// Авторы по идентификаторам — для карточки книги.
  Future<List<Author>> findByIds(List<int> ids);
}
