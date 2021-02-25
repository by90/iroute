import 'package:flutter/material.dart';
import 'book.dart';
import 'package:iroute/iroute.dart';

class BooksListScreen extends StatelessWidget {
  //final List<Book> books;
  //final ValueChanged<Book> onTapped;

  BooksListScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () {
                IRouterDelegate.of(context)
                    .push('/book/:iid=${Book.getIdByBook(book, books)}');
              },
            )
        ],
      ),
    );
  }
}
