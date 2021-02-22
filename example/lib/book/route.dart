import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'book.dart';
import 'book_list.dart';
import 'book_detail.dart';
import 'unknow.dart';

/// The RouteDelegate defines application specific behaviors of how the router
/// learns about changes in the application state and how it responds to them.
/// It listens to the RouteInformation Parser and the app state and builds the Navigator with
/// the current list of pages (immutable object used to set navigator's history stack).
class MainRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  //This is the state of the navigator widget (in build method).
  //GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get navigatorKey =>
      GlobalObjectKey<NavigatorState>(this);

  static MainRouterDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is MainRouterDelegate, 'Delegate type must match');
    return delegate as MainRouterDelegate;
  }

  /// Internal backstack and pages representation.
  List<String> _mainRoutes = [];
  List<String> get mainRoutes => _mainRoutes;

  bool _canPop = true;
  bool get canPop {
    if (_canPop == false) return false;

    return _mainRoutes.isNotEmpty;
  }

  set canPop(bool canPop) => _canPop = canPop;

  /// CurrentConfiguration detects changes in the route information
  /// It helps complete the browser history and enables browser back and forward buttons.
  String? get currentConfiguration =>
      mainRoutes.isNotEmpty ? mainRoutes.last : null;

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: navigatorKey,
        pages: [
          if (mainRoutes.isEmpty) MainPageBuilder(context, '/').page,
          for (String path in mainRoutes) MainPageBuilder(context, path).page,
        ],
        onPopPage: (route, result) {
          print('Pop Page');
          if (!route.didPop(result)) {
            return false;
          }
          if (canPop) {
            pop();
          }
          return true;
        });
  }

  @override
  Future<void> setNewRoutePath(String path) async {
    print('Set New Route Path: $path');
    if (_canPop == false) return SynchronousFuture(null);
    if (path == currentConfiguration) return SynchronousFuture(null);
    _mainRoutes = _setNewRouteHistory(_mainRoutes, path);
    print('Main Routes: $mainRoutes');
    notifyListeners();
    return SynchronousFuture(null);
  }

  @override
  Future<bool> popRoute() {
    print('Pop Route');
    return super.popRoute();
  }

  /// Updates route path history.
  ///
  /// In a browser, forward and backward navigation
  /// is indeterminate and a custom path history stack
  /// implementation is needed.
  /// When a [newRoute] is added, check the existing [routes]
  /// to see if the path already exists. If the path exists,
  /// remove all path entries on top of the path.
  /// Otherwise, add the new path to the path list.
  List<String> _setNewRouteHistory(List<String> routes, String newRoute) {
    List<String> pathsHolder = [];
    pathsHolder.addAll(routes);
    // Check if new path exists in history.
    for (String path in routes) {
      // If path exists, remove all paths on top.
      if (path == newRoute) {
        int index = routes.indexOf(path);
        int count = routes.length;
        for (var i = index; i < count - 1; i++) {
          pathsHolder.removeLast();
        }
        return pathsHolder;
      }
    }

    // Add new path to history.
    pathsHolder.add(newRoute);

    return pathsHolder;
  }

  void push(String path) {
    //assert(path != null);
    _mainRoutes.add(path);
    notifyListeners();
  }

  void pop() {
    _mainRoutes.removeLast();
    notifyListeners();
  }
}

/// The RouteInformationParser takes the RouteInformation
/// from a RouteInformationProvider and parses it into a user-defined data type.
class MainRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture(routeInformation.location!);
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(location: configuration);
  }
}

//这里根据url构建页面
//不过无法用到push这类
class MainPageBuilder {
  final BuildContext context;
  final String homeRoutePath;

  MainPageBuilder(this.context, this.homeRoutePath);

  dynamic get page {
    switch (homeRoutePath) {
      case '/':
        return MaterialPage(
            key: ValueKey('home'),
            name: '/',
            child: BooksListScreen(
                books: books,
                onTapped: (book) {
                  MainRouterDelegate.of(context)
                      .push('/book/${Book.getIdByBook(book, books)}');
                }));
      case '/404':
        return MaterialPage(
            key: ValueKey('/404'), name: '/404', child: UnknownScreen());
      default:
        return MaterialPage(
            key: ValueKey('unknown'),
            name: homeRoutePath,
            child: BookDetailsScreen(
                book: books[Book.getIdFromUrl(homeRoutePath)!]));
    }
  }
}
