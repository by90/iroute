class Book {
  final String title;
  final String author;

  Book(this.title, this.author);

  static int? getIdFromUrl(String? path) {
    final uri = Uri.parse(path!);
    return int.tryParse(uri.pathSegments[1]);
  }

  static int getIdByBook(Book post, List<Book> books) {
    if (!books.contains(post)) return 0;
    return books.indexOf(post);
  }
}

List<Book> books = [
  Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
  Book('Foundation', 'Isaac Asimov'),
  Book('Fahrenheit 451', 'Ray Bradbury'),
];
