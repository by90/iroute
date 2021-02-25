import 'package:flutter/material.dart';
import 'package:iroute/iroute.dart';
import 'book_list.dart';
import 'book_detail.dart';
import 'unknow.dart';

final Map<String, RouteBuilder> routes = {
  '/': (BuildContext context, Map<String, dynamic> params) => BooksListScreen(),
  '/404': (context, params) => UnknownScreen(),
  '/book/:iid': (context, params) => BookDetailsScreen(id: params['id'])
};
