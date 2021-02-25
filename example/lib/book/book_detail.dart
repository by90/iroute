import 'package:flutter/material.dart';
import 'book.dart';

class BookDetailsScreen extends StatelessWidget {
  late final Book book;
  final int id;

  BookDetailsScreen({
    required this.id,
  }) : this.book = books[id];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...[
              Text(book.title, style: Theme.of(context).textTheme.headline6),
              Text(book.author, style: Theme.of(context).textTheme.subtitle1),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Back'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
