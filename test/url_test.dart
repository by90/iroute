//import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

//if result is null
// String? getParttenFromUrl(String url) {}
// Map<String, dynamic> getParamFromUrl(String url) {
//   Uri.parse(url);
//   url.split('/:');
//   url.replaceAllMapped(from, (match) => null);

// }

//得到模版，得到所有参数并返回map<string,dynamic>,返回widgetBuilder

//保存路由表map<string,WidgetBuilder>
//指定404和默认主页
//根据url匹配路由表，并返回WidgetBuilder，根据url得到参数 map<string,dynamic>,并传递给WidgetBuilder
//不匹配者返回404，并将路由传递给它

class RouteMap {}

void main() {
  test('get partten from url with single argument', () {
    var url = '/book/:iid=1/:iid1=3';
    //url本身不改变，而是返回新串
    var result = url.replaceAllMapped(
      RegExp('(/:[sid][^=]+)(=[^/]+)'),
      (match) {
        print(
            'matched:${match.groupCount},group0:${match.group(0)},group1:${match.group(1)},group2:${match.group(2)}');

        //将匹配的值改为return的值
        return '${match.group(1)}'; //0是整个匹配串，1才是第一组，2才是第二组
      },
    );
    expect(result, '/book/:iid/:iid1');
  });

  test('get param from url', () {
    var url = '/book/:iid=1/:iid1=3';
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

    expect(2, args.length);
    expect(1, args['id']);
    expect(3, args['id1']);
  });
}
