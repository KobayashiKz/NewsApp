import 'dart:async';
import 'package:http/http.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';
import 'package:feedparser/feedparser.dart';
import 'package:flutter/material.dart';


void main() => runApp(MyApp());

// アプリケーション本体
// 起動時に次のRssListPageインスタンスを生成して表示
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

// 第一階層のRSSジャンル一覧画面
// 内容が固定であるためStatelessWidget
class RssListPage extends StatelessWidget {
  // カテゴリリスト
  final List<String> names = ["主要ニュース", "国際情勢", "国内の出来事", "IT関係"];

  // URL
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

  // Listに表示するListTileのリストを作成
  // 内容が固定のためsetState()のようなことはせずに直接指定
  List<Widget> items(BuildContext context) {
    List<Widget> items = [];

    for (var i = 0; i < names.length; i++) {
      items.add(
        ListTile(
          contentPadding: EdgeInsets.all(10.0),
          title: Text(names[i],
            style: TextStyle(fontSize: 24.0),),
          onTap: () {
            // TileをタップされたらRSSページに遷移
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

// 選択したジャンルの最新記事の一覧リストを表示
class MyRssPage extends StatefulWidget {

  final String title;
  final String url;

  MyRssPage({@required this.title, @required this.url});

  @override
  _MyRssPageState createState() => new _MyRssPageState(title: title, url: url);
}

// MyRssPageウィジェットのStateクラス
class _MyRssPageState extends State<MyRssPage> {
  final String title;
  final String url;

  List<Widget> _items = <Widget>[];

  // コンストラクタ
  // タイトルとURLだけもらう
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
          // すでに作成済みのリストを表示
          children: _items,
        ),
      ),
    );
  }

  // YahooサイトからRSSを取得してListTitleのListを作成する
  void getItems() async {
    List<Widget> list = <Widget>[];

    // 指定したurlにアクセスしてデータを取得する
    // Responseのbodyプロパティに取得したhtmlまたはxmlが入っている
    Response res = await get(url);
    // 取得したxmlからFeedクラスに変換して扱いやすくしている
    Feed feed = parse(res.body);

    for (FeedItem item in feed.items) {
      list.add(ListTile(
        contentPadding: EdgeInsets.all(10.0),
        title: Text(
          item.title,
          style: TextStyle(fontSize: 24.0),
        ),
        subtitle: Text(
          item.pubDate
        ),
        onTap: () {
          // タップされたらItemDetailsPageへ遷移する
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ItemDetailsPage(
              item: item, title: title, url: url
            ),),
          );
        },
      ),);
    }

    // _itemsの更新
    setState(() {
      _items = list;
    });
  }
}

// 選択した項目の内容表示
class ItemDetailsPage extends StatefulWidget {
  final String title;
  final String url;
  final FeedItem item;

  ItemDetailsPage({
    @required this.item,
    @required this.title,
    @required this.url,
  });

  @override
  _ItemDetails createState() => new _ItemDetails(item:item);
}

// ItemDetailsPageのStateクラス
class _ItemDetails extends State<ItemDetailsPage> {
  FeedItem item;
  Widget _widget = Text("wait...");

  // コンストラクタ
  // タップしたFeedItemのみ取得する
  _ItemDetails({@required this.item});

  @override
  void initState() {
    super.initState();
    getItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: _widget,
    );
  }

  // FeedItemの情報からコンテンツを取得しCardを作成する
  void getItem() async {
    // 指定アドレスから情報取得
    Response res = await get(item.link);

    // 取得したhtmlをDocumentクラスとして作成.
    dom.Document doc = dom.Document.html(res.body);
    // class="hbody". hdoby.textとすればclass="hbody"のテキストが取り出せる
    dom.Element hbody = doc.querySelector(".hbody");
    // <a>タグのclass=".newsTitle"
    dom.Element htitle = doc.querySelector(".newsTitle a");
    // class=".newsLink"
    dom.Element newslink = doc.querySelector(".newsLink");

    print(newslink.attributes["href"]);

    setState(() {
      _widget = SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              // タイトル
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  htitle.text,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 本文
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  hbody.text,
                  style: TextStyle(
                    fontSize: 20.0
                  ),
                ),
              ),

              // Web遷移ボタン
              Padding(
                padding: EdgeInsets.all(10.0),
                child: RaisedButton(
                  child: Text("続きを読む...",
                    style: TextStyle(fontSize: 18.0),),
                  onPressed: () {
                    // url_launcherパッケージのlaunch()を使用
                    // 引数: <a>タグ, class="newsLink", href属性の値
                    launch(newslink.attributes["href"]);
                  },
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}