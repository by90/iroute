import 'package:flutter/material.dart';
import 'package:iroute/iroute.dart';

import 'routes.dart';

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  final IRouterDelegate mainRouterDelegate = IRouterDelegate(routes: routes);
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
