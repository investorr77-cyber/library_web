import '../models/author.dart';
import '../models/book.dart';
import '../models/reference.dart';

/// Начальный набор данных. Хранится в памяти и восстанавливается
/// при каждой перезагрузке страницы.

const seedGenres = [
  Genre(1, 'Роман'),
  Genre(2, 'Классика'),
  Genre(3, 'Фантастика'),
  Genre(4, 'Антиутопия'),
  Genre(5, 'Фэнтези'),
  Genre(6, 'Поэзия'),
  Genre(7, 'Военная проза'),
];

const seedPublishers = [
  Publisher(1, 'АСТ'),
  Publisher(2, 'Эксмо'),
  Publisher(3, 'Азбука'),
  Publisher(4, 'Росмэн'),
  Publisher(5, 'Альпина'),
];

const seedAuthors = [
  Author(id: 1, lastName: 'Толстой', firstName: 'Лев', country: 'Россия', birthYear: 1828),
  Author(id: 2, lastName: 'Достоевский', firstName: 'Фёдор', country: 'Россия', birthYear: 1821),
  Author(id: 3, lastName: 'Пушкин', firstName: 'Александр', country: 'Россия', birthYear: 1799),
  Author(id: 4, lastName: 'Булгаков', firstName: 'Михаил', country: 'Россия', birthYear: 1891),
  Author(id: 5, lastName: 'Оруэлл', firstName: 'Джордж', country: 'Великобритания', birthYear: 1903),
  Author(id: 6, lastName: 'Хемингуэй', firstName: 'Эрнест', country: 'США', birthYear: 1899),
  Author(id: 7, lastName: 'Ремарк', firstName: 'Эрих Мария', country: 'Германия', birthYear: 1898),
  Author(id: 8, lastName: 'Брэдбери', firstName: 'Рэй', country: 'США', birthYear: 1920),
  Author(id: 9, lastName: 'Гюго', firstName: 'Виктор', country: 'Франция', birthYear: 1802),
  Author(id: 10, lastName: 'Толкин', firstName: 'Джон', country: 'Великобритания', birthYear: 1892),
  Author(id: 11, lastName: 'Чехов', firstName: 'Антон', country: 'Россия', birthYear: 1860),
];

Book _b(int id, String title, int author, int year, int pages, List<int> genres,
        int publisher, int total, int available) =>
    Book(
      id: id,
      title: title,
      isbn: '978-5-${17 + publisher}-${(10432 + id * 731) % 100000}-$id',
      year: year,
      pages: pages,
      publisherId: publisher,
      authorIds: [author],
      genreIds: genres,
      copiesTotal: total,
      copiesAvailable: available,
    );

final seedBooks = [
  _b(1, 'Война и мир', 1, 1869, 1300, [1, 2, 7], 1, 8, 5),
  _b(2, 'Анна Каренина', 1, 1877, 864, [1, 2], 2, 6, 2),
  _b(3, 'Воскресение', 1, 1899, 576, [1, 2], 3, 3, 3),
  _b(4, 'Преступление и наказание', 2, 1866, 672, [1, 2], 1, 10, 4),
  _b(5, 'Идиот', 2, 1869, 640, [1, 2], 2, 5, 5),
  _b(6, 'Братья Карамазовы', 2, 1880, 992, [1, 2], 3, 4, 1),
  _b(7, 'Евгений Онегин', 3, 1833, 320, [2, 6], 4, 7, 7),
  _b(8, 'Капитанская дочка', 3, 1836, 256, [1, 2], 4, 9, 6),
  _b(9, 'Мастер и Маргарита', 4, 1967, 480, [1, 2, 3], 1, 12, 3),
  _b(10, 'Собачье сердце', 4, 1925, 192, [2, 3], 2, 6, 4),
  _b(11, 'Белая гвардия', 4, 1925, 416, [1, 7], 3, 3, 2),
  _b(12, '1984', 5, 1949, 320, [3, 4], 1, 10, 0),
  _b(13, 'Скотный двор', 5, 1945, 160, [4], 2, 4, 4),
  _b(14, 'Старик и море', 6, 1952, 128, [1], 5, 5, 3),
  _b(15, 'Прощай, оружие!', 6, 1929, 352, [1, 7], 1, 3, 1),
  _b(16, 'По ком звонит колокол', 6, 1940, 608, [1, 7], 2, 2, 2),
  _b(17, 'На западном фронте без перемен', 7, 1929, 288, [1, 7], 3, 6, 5),
  _b(18, 'Три товарища', 7, 1936, 480, [1], 3, 7, 2),
  _b(19, '451 градус по Фаренгейту', 8, 1953, 256, [3, 4], 2, 8, 6),
  _b(20, 'Марсианские хроники', 8, 1950, 320, [3], 5, 4, 4),
  _b(21, 'Отверженные', 9, 1862, 1500, [1, 2], 1, 3, 1),
  _b(22, 'Собор Парижской Богоматери', 9, 1831, 640, [1, 2], 4, 5, 3),
  _b(23, 'Властелин колец', 10, 1954, 1200, [5], 1, 9, 2),
  _b(24, 'Хоббит', 10, 1937, 320, [5], 4, 6, 6),
  _b(25, 'Вишнёвый сад', 11, 1904, 96, [2], 3, 4, 4),
];
