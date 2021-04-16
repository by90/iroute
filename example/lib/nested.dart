// class BookRoutePath {
// String url;
// BookRoutePath(this.url);
// }

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(NestedRouterDemo());
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class NestedRouterDemo extends StatefulWidget {
  @override
  _NestedRouterDemoState createState() => _NestedRouterDemoState();
}

class _NestedRouterDemoState extends State {
  BookRouterDelegate _routerDelegate = BookRouterDelegate();
  BookRouteInformationParser _routeInformationParser =
      BookRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: 'Books App',
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser);
  }
}

class BooksAppState extends ChangeNotifier {
  String _appUrl;

  final List books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  BooksAppState() : _appUrl = '/';

  String get appUrl => _appUrl;

  set appUrl(String idx) {
    _appUrl = idx;
    notifyListeners();
  }

  Book? getBookById(int id) {
    if (id < 0 || id > books.length - 1) {
      return null;
    }
    return books[id];
  }

  int getIdByBook(Book book) {
    if (!books.contains(book)) return 0;
    return books.indexOf(book);
  }

  int? getIdFromUrl(String path) {
    final uri = Uri.parse(path);
    return int.tryParse(uri.pathSegments[1]);
  }
}

class BookRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(
      RouteInformation routeInformation) async {
//final uri = Uri.parse(routeInformation.location);
    return SynchronousFuture(routeInformation.location!);
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
//if (configuration.url == null) return null;
    return RouteInformation(location: configuration);
  }
}

class BookRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState>? navigatorKey;

  BooksAppState appState = BooksAppState();

  BookRouterDelegate() : navigatorKey = GlobalKey() {
    appState.addListener(notifyListeners);
  }

  String get currentConfiguration {
    return appState.appUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          child: AppShell(appState: appState),
        ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        //这里通过设定selectredBook，从而显示列表？
        // if (appState.selectedBook != null) {
        //   appState.selectedBook = null;
        // }
        print('onPopPage,route.settings.name=${route.settings.name}');

        //问题在这里??，route.settings.name是当前的url，所以无法返回
        appState.appUrl = route.settings.name!;
        //因此需要控制page,
        //Navigator.of(context).pop();

        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future setNewRoutePath(String path) async {
    print('setNewRoutePath:path=$path');
    appState.appUrl = path; //这里来设定状态，但是我们已经notify了；
  }
}

// Widget that contains the AdaptiveNavigationScaffold
class AppShell extends StatefulWidget {
  final BooksAppState appState;

  AppShell({
    required this.appState,
  });

  @override
  AppShellState createState() => AppShellState();
}

class AppShellState extends State {
  InnerRouterDelegate? _routerDelegate;
  ChildBackButtonDispatcher? _backButtonDispatcher;

  void initState() {
    super.initState();
    _routerDelegate = InnerRouterDelegate((widget as AppShell).appState);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _routerDelegate!.appState = (widget as AppShell).appState;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
// Defer back button dispatching to the child router
    _backButtonDispatcher = Router.of(context)
        .backButtonDispatcher!
        .createChildBackButtonDispatcher();
  }

  @override
  Widget build(BuildContext context) {
    var appState = (widget as AppShell).appState;

// Claim priority, If there are parallel sub router, you will need
// to pick which one should take priority;
//_backButtonDispatcher.takePriority();

    return Scaffold(
      appBar: AppBar(),
      body: Router(
        routerDelegate: _routerDelegate!,
        backButtonDispatcher: _backButtonDispatcher,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: 0, //appState.selectedIndex,
        onTap: (newIndex) {
          appState.appUrl = newIndex == 0 ? '/' : '/settings';
          //appState.selectedIndex = newIndex;
        },
      ),
    );
  }
}

class InnerRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState>? navigatorKey = GlobalKey();
  BooksAppState get appState => _appState;
  BooksAppState _appState;
  set appState(BooksAppState value) {
    if (value == _appState) {
      return;
    }
    _appState = value;
    notifyListeners();
  }

  InnerRouterDelegate(this._appState);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        if (appState.appUrl == '/')
          MaterialPage(
              child: BooksListScreen(
                books: appState.books,
                onTapped: _handleBookTapped,
              ),
              key: ValueKey(appState.appUrl),
              name: appState.appUrl),
        if (appState.appUrl.startsWith('/post'))
          MaterialPage(
            name: appState.appUrl,
            key: ValueKey(appState.appUrl),
            child: BookDetailsScreen(
                book: appState
                    .getBookById(appState.getIdFromUrl(appState.appUrl)!)!),
          ),
        if (appState.appUrl == '/settings')
          MaterialPage(
            name: appState.appUrl,
            child: SettingsScreen(),
            key: ValueKey(appState.appUrl),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
//appState.selectedBook = null;
        print('Inner! onPopPage,route.settings.name=${route.settings.name}');

        //问题在这里，route.settings.name是当前的url，所以无法返回
        //appState.appUrl = route.settings.name!;
        //因此需要控制page,
        //Navigator.of(context).pop();

        appState.appUrl = route.settings.name!;

        //bug，不能返回，在这里通知？？？
        //notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(String path) async {
// This is not required for inner router delegate because it does not
// parse route
    assert(false);
  }

  void _handleBookTapped(book) {
    appState.appUrl = '/post/${appState.getIdByBook(book as Book)}';
    notifyListeners();
  }
}

class FadeAnimationPage extends Page {
  final Widget? child;

  FadeAnimationPage({Key? key, this.child}) : super(key: key as LocalKey);

  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, animation2) {
        var curveTween = CurveTween(curve: Curves.easeIn);
        return FadeTransition(
          opacity: animation.drive(curveTween),
          child: child,
        );
      },
    );
  }
}

// Screens
class BooksListScreen extends StatelessWidget {
  final List books;
  final ValueChanged onTapped;

  BooksListScreen({
    required this.books,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () => onTapped(book),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Back'),
            ),
            //if (book != null)

            ...[
              Text(book.title, style: Theme.of(context).textTheme.headline6),
              Text(book.author, style: Theme.of(context).textTheme.subtitle1),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Settings screen'),
      ),
    );
  }
}
