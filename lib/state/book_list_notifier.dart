import '../models/author.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../repositories/author_repository.dart';
import '../repositories/book_repository.dart';
import 'entity_list_notifier.dart';

class BookListNotifier extends EntityListNotifier<Book, BookQuery> {
  BookListNotifier(BookRepository books, this._authors)
      : super(books, const BookQuery(), (b) => b.id);

  final AuthorRepository _authors;

  /// Авторы книги — для карточки. Экран не обращается к репозиторию сам.
  Future<List<Author>> authorsOf(Book book) =>
      _authors.findByIds(book.authorIds);
}
