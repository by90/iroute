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
              child:
                  BookDetailsScreen(book: books[Book.getIdFromUrl(url)! - 1]))
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
