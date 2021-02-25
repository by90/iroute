import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

typedef RouteBuilder = Widget Function(
    BuildContext context, Map<String, dynamic> params);

class Iroute extends Route with ChangeNotifier {
  late Map<String, RouteBuilder> routes; //default is null,so should use late;
  late String url; //current url;
  String defaultUrl = '/'; //默认的主页为/
  String unknowUrl = '/404'; //默认的未找到页面url为404
  //current use ChangeNotifier,we should support other state solution later;
  Iroute(this.routes, this.defaultUrl, this.unknowUrl); //指定初始的url？

  //试试看，我们用路由模版：其中:id写作:iid,表示是整数
  //传递路由的时候，to函数可以用user/{1}或简单的user/:iid=1/,大括号表示为参数，这样可快速匹配模版，并能确定类型
  //后一种方法可由url直接得到模版本身
  //例外的是第一级不可为参数

  //参数不一定要在parser中处理，但显然，parser处理的话，路由表就简化一些了。

  //extends from route,so it could work with material app
  //and we don't need add a provider function

}

/// The RouteDelegate defines application specific behaviors of how the router
/// learns about changes in the application state and how it responds to them.
/// It listens to the RouteInformation Parser and the app state and builds the Navigator with
/// the current list of pages (immutable object used to set navigator's history stack).
class IRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  //This is the state of the navigator widget (in build method).
  //GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get navigatorKey =>
      GlobalObjectKey<NavigatorState>(this);

  static IRouterDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is IRouterDelegate, 'Delegate type must match');
    return delegate as IRouterDelegate;
  }

  late Map<String, RouteBuilder> routes;
  //just set the url
  //we know who is the url in routes
  final String defaultUrl; //默认的主页为/
  final String unknowUrl; //默认的未找到页面url为404
  IRouterDelegate(
      {required this.routes,
      this.defaultUrl = '/',
      this.unknowUrl = '/404'}); //指定初始的url？

  /// Internal backstack and pages representation.
  List<String> _routeStack = [];
  List<String> get routeStack => _routeStack;

  bool _canPop = true;
  bool get canPop {
    if (_canPop == false) return false;

    return _routeStack.isNotEmpty;
  }

  set canPop(bool canPop) => _canPop = canPop;

  /// CurrentConfiguration detects changes in the route information
  /// It helps complete the browser history and enables browser back and forward buttons.
  String? get currentConfiguration =>
      routeStack.isNotEmpty ? routeStack.last : null;

  //by url,get the WidgetBuilder and arguments
  WidgetBuilder? _getWidget(url) {
    String pattern =
        url.replaceAllMapped(RegExp('(/:[sid][^=]+)(=[^/]+)'), (match) {
      print(
          'matched:${match.groupCount},group0:${match.group(0)},group1:${match.group(1)},group2:${match.group(2)}');
      return '${match.group(1)}';
    });
    var params = getParam(url);

    //Bug：这句返回出错！
    print('pattern=$pattern,params length=${params.length}');
    return (context) => this.routes[pattern]!(context, params);
  }

  Map<String, dynamic> getParam(url) {
    //var url = '/book/:iid=1/:iid1=3';
    //url本身不改变，而是返回新串
    var regExp = RegExp('(/:[sid][^=]+)(=[^/]+)');
    var result = regExp.allMatches(url);
    Map<String, dynamic> args = Map<String, dynamic>();
    for (RegExpMatch match in result) {
      var argName = match.group(1)!.substring(3);
      var argType = match.group(1)![2];
      var argValue = match.group(2)!.substring(1); //去掉等号
      dynamic value;

      if (argType == 'i') value = int.tryParse(argValue);
      if (argType == 'd') value = double.tryParse(argValue);
      if (argType == 's') value = argValue;
      args[argName] = value;
      print('args[$argName]=${args[argName]}');
    }
    return args;
  }

  //根据完整url构建页面
  Page buildPage(context, url) {
    if (url == this.defaultUrl)
      return MaterialPage(
          key: ValueKey(url),
          name: '/',
          child: this._getWidget(this.defaultUrl)!(
              context) //add argument like(id:1) here
          );
    if (url == this.unknowUrl)
      return MaterialPage(
          key: ValueKey(url), name: url, child: this._getWidget(url)!(context));
    return MaterialPage(
        key: ValueKey(url), name: url, child: _getWidget(url)!(context));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: navigatorKey,
        pages: [
          if (routeStack.isEmpty) buildPage(context, '/'),
          for (String path in routeStack) buildPage(context, path),
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
    _routeStack = _setNewRouteHistory(_routeStack, path);
    print('Main Routes: $routeStack');
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
    _routeStack.add(path);
    notifyListeners();
  }

  void pop() {
    _routeStack.removeLast();
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
