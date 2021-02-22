import 'package:flutter/material.dart';

class Iroute extends Route with ChangeNotifier {
  late Map<String, WidgetBuilder> routes; //default is null,so should use late;
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
