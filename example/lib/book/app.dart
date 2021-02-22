import 'package:flutter/material.dart';
import 'route.dart';

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  //BookRouterDelegate _routerDelegate = BookRouterDelegate();
  BookRouteInformationParser _routeInformationParser =
      BookRouteInformationParser();
  @override
  Widget build(BuildContext context) {
    var delegate = MyRouteDelegate(
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: MyRouteDelegate.of(context).routes[settings.name]!,
        );
      },
    );
    return MaterialApp.router(
      title: 'Books App',
      //routerDelegate: _routerDelegate,
      routerDelegate: delegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}
