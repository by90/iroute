//import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'myRouteObserver.dart';
import 'book.dart';
import 'book_list.dart';
import 'book_detail.dart';
import 'unknow.dart';

class BookRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture(routeInformation.location!);
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(location: configuration);
  }
}

class BookRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  final GlobalKey<NavigatorState> navigatorKey;

  String url = '/';
  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();
  String get currentConfiguration {
    return url;
  }

  void whenPop(Route route, Route? previousRoute) {
    url = previousRoute!.settings.name!;
    //update:don't notify here,error:setstate when build
    //notify in onpoppage
    //should notify here,so adress of browser will upfate
    //notifyListeners();
    print('url=$url');
  }

  @override
  Widget build(BuildContext context) {
    MyRouteObserver<PageRoute> myRouteObserver =
        MyRouteObserver<PageRoute>(whenPop);
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          name: '/',
          key: ValueKey('/'),
          child: BooksListScreen(
            books: books,
            onTapped: _handleBookTapped,
          ),
        ),
        if (url == '/404')
          MaterialPage(
              key: ValueKey('/404'), name: '/404', child: UnknownScreen())
        else if (url != '/')
          MaterialPage(
              key: ValueKey(url),
              name: url,
              child: BookDetailsScreen(book: books[Book.getIdFromUrl(url)!]))
      ],
      //observer the route changed
      observers: [myRouteObserver],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        print('onpop:${route.settings.name}');

        //notify here,if not,the adress in browser will not update
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(String path) async {
    //browser adress will change
    url = path;
    //don't notify here
  }

  void _handleBookTapped(Book book) {
    url = '/book/${Book.getIdByBook(book, books)}';
    notifyListeners();
  }
}

class MyRouteDelegate extends RouterDelegate<String>
    with PopNavigatorRouterDelegateMixin<String>, ChangeNotifier {
  final _stack = <String>[];
  final Map<String, WidgetBuilder> routes = {
    '/': (context) => BooksListScreen(
        books: books,
        onTapped: (Book book) {
          MyRouteDelegate.of(context)
              .push('/book/${Book.getIdByBook(book, books)}');
          MyRouteDelegate.of(context).notifyListeners();
        }),
    '/book/:id': (context) => BookDetailsScreen(
        book: books[Book.getIdFromUrl(
            MyRouteDelegate.of(context).currentConfiguration)!]),
  };

  static MyRouteDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is MyRouteDelegate, 'Delegate type must match');
    return delegate as MyRouteDelegate;
  }

  MyRouteDelegate({
    required this.onGenerateRoute,
  });

  final RouteFactory onGenerateRoute;

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  String? get currentConfiguration => _stack.isNotEmpty ? _stack.last : null;

  List<String> get stack => List.unmodifiable(_stack);

  void push(String newRoute) {
    _stack.add(newRoute);
    notifyListeners();
  }

  void remove(String routeName) {
    _stack.remove(routeName);
    notifyListeners();
  }

  @override
  Future<void> setInitialRoutePath(String configuration) {
    return setNewRoutePath(configuration);
  }

  @override
  Future<void> setNewRoutePath(String configuration) {
    _stack
      ..clear()
      ..add(configuration);
    return SynchronousFuture<void>(null);
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (_stack.isNotEmpty) {
      if (_stack.last == route.settings.name) {
        _stack.remove(route.settings.name);
        notifyListeners();
      }
    }
    return route.didPop(result);
  }

  @override
  Widget build(BuildContext context) {
    print('${describeIdentity(this)}.stack: $_stack');
    return Navigator(
      key: navigatorKey,
      onPopPage: _onPopPage,

      //注意，这里的name，是url模版，不是url本身
      //我们应从url中得到模版，因此可考虑/:id:1这种方式，但其实没必要
      //只要匹配了，我们是能得到模版的，这种写法复杂多了且涉及更多代码，我们不能将复杂蔓延
      //由于传入的是book/0，我们不能简单的获取，所以先需要得到url模版
      pages: [
        for (final name in _stack)
          MyPage(
            key: ValueKey(name),
            name: name,
            builder:
                name.startsWith('/book/') ? routes['/book/:id'] : routes[name],
          ),
      ],
    );
  }
}

class MyPage extends Page {
  const MyPage({LocalKey? key, String? name, required this.builder})
      : super(
          key: key,
          name: name,
        );
  final WidgetBuilder? builder;
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: builder!,
    );
  }
}
