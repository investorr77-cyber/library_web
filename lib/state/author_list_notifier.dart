import '../models/author.dart';
import '../models/author_query.dart';
import '../repositories/author_repository.dart';
import 'entity_list_notifier.dart';

class AuthorListNotifier extends EntityListNotifier<Author, AuthorQuery> {
  AuthorListNotifier(this._authors)
      : super(_authors, const AuthorQuery(), (a) => a.id) {
    _authors.countries().then((c) {
      _countries = c;
      notifyListeners();
    });
  }

  final AuthorRepository _authors;
  List<String> _countries = const [];

  /// Страны для фильтра.
  List<String> get countries => _countries;
}
