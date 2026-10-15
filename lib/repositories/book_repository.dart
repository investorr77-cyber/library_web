import '../models/book.dart';
import '../models/book_query.dart';
import 'entity_repository.dart';

/// Что приложение умеет делать с книгами, безотносительно того, где они лежат.
abstract interface class BookRepository
    implements EntityRepository<Book, BookQuery> {}
