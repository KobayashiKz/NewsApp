import 'dart:async';
import 'package:http/http.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Generated App",
      theme: new ThemeData(
        primarySwatch: Colors.pink,
        primaryColor: const Color(0xFFe91e63),
        accentColor: const Color(0xFFe91e63),
        canvasColor: const Color(0xFFfafafa),
      ),
      home: new RssListPage(),
    );
  }
}

class RssListPage extends StatelessWidget {
  final List<String> names = ["主要ニュース", "国際情勢", "国内の出来事", "IT関係"];

  final List<String> links = [
    "https://news.yahoo.co.jp/pickup/rss.xml",
    "https://news.yahoo.co.jp/pickup/world/rss.xml",
    "https://news.yahoo.co.jp/pickup/domestic/rss.xml",
    "https://news.yahoo.co.jp/pickup/computer/rss.xml"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yahoo! Checker"),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: items(context),
        ),
      ),
    );
  }

  //Listに表示するListTileのリストを作成
  List<Widget> items(BuildContext context) {
    List<Widget> items = [];

    for (var i = 0; i < names.length; i++) {
      items.add(
        ListTile(
          contentPadding: EdgeInsets.all(10.0),
          title: Text(names[i],
            style: TextStyle(fontSize: 24.0),),
          onTap: () {
            Navigator.push(context,
            MaterialPageRoute(builder: (_) => MyRssPage(
              title: names[i],
              url: links[i],
            )));
          },
        )
      );
    }

    return items;
  }
}

class MyRssPage extends StatefulWidget {

  final String title;
  final String url;

  MyRssPage({@required this.title, @required this.url});

  @override
  _MyRssPageState createState() => new _MyRssPageState(title: title, url: url);
}


class _MyRssPageState extends State<MyRssPage> {
  final String title;
  final String url;

  List<Widget> _items = <Widget>[];

  _MyRssPageState({@required this.title, @required this.url}) {
    getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: _items,
        ),
      ),
    );
  }

  // YahooサイトからRSSを取得してListTitleのListを作成する
  void getItems() async {
    List<Widget> list = <Widget>[];

    Response res = await get(url);
  }
}