import 'package:flutter/material.dart';
import 'route.dart';

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  final MainRouterDelegate mainRouterDelegate = MainRouterDelegate();
  final MainRouteInformationParser mainRouteInformationParser =
      MainRouteInformationParser();
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: mainRouterDelegate,
      routeInformationParser: mainRouteInformationParser,
      debugShowCheckedModeBanner: false,
    );
  }
}
