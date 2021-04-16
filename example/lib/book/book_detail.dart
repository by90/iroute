import 'package:flutter/material.dart';
import 'package:iroute/iroute.dart';
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
              TextButton(
                  onPressed: () {
                    int nextId = id + 1;
                    if (nextId > 2) nextId = 0;
                    IRouterDelegate.of(context).push('/book/:iid=$nextId');

                    //当nav到2，下一个为0，pages中的key重复，导致assert异常 final LocalKey? key = page.key;
                    //因此buildPages需要使用UniqueKey()
                  },
                  child: Text('Next'))
            ],
          ],
        ),
      ),
    );
  }
}
