import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transformer_page_view/transformer_page_view.dart';
import 'dart:async';
import 'dart:convert';
import 'check.dart';

import 'news.dart';

bool hasC = false;
conn obj = new conn();
class NewsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NewsPageState();
  }
}

class _NewsPageState extends State<NewsPage> {
  var index = 0;
  int length = 0;
  List websites = [];
  bool visi = true;
  List<News> _list = new List<News>();

  Future<List<News>> fetchNews() async {
    final response = await http.get('http://demo9206388.mockable.io/metalcutting');
    Map map = json.decode(response.body);
    final responseJson = json.decode(response.body);
    length = responseJson['totalResults'];
    for (int i = 0; i < length; i++) {
      websites.add(responseJson['articles'][i]["urlToImage"]);
    }
    for (int i = 0; i < map['articles'].length; i++) {
      if (map['articles'][i]['author'] != null) {
        _list.add(new News.fromJson(map['articles'][i]));
      }
    }
    return _list;
  }


  @override
  void initState() {
    super.initState();
    this.fetchNews();
    check_internet();
  }

  @override
  Widget build(BuildContext context) {
    var hei = MediaQuery
        .of(context)
        .size
        .height;
    var wid = MediaQuery
        .of(context)
        .size
        .width;
    return hasC
        ? new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: new Text(
            'Metal Cutting TV',
            style: TextStyle(fontSize: 15),
          ),
        ),

      ),
      body: new FutureBuilder(
          future: fetchNews(),
          builder:
              (BuildContext context, AsyncSnapshot<List<News>> snapshot) {
            if (snapshot.hasData) {
              return new TransformerPageView(itemCount: length,
                itemBuilder: (BuildContext context, int index) {
                  return PageView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: new Column(
                            children: <Widget>[
                              Container(
                                width: wid,
                                height: hei * 0.35,
                                child: CachedNetworkImage(
                                  imageUrl: websites[index],
                                  imageBuilder:
                                      (context, imageProvider) =>
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft:
                                              Radius.circular(20.0),
                                              topRight:
                                              Radius.circular(20.0)),
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.fill),
                                        ),
                                      ),
                                  placeholder: (context, url) =>
                                      Center(
                                          child:
                                          CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                              new Padding(
                                padding: new EdgeInsets.only(
                                    top: 16,
                                    left: 8,
                                    right: 8,
                                    bottom: 8),
                                child: Container(
                                  child: new Text(
                                    '${snapshot.data[index].title}',
                                    style: new TextStyle( color: Color(0xff11999E),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22.0),
                                  ),
                                  width: wid,
                                ),
                              ),
                              new Padding(
                                padding: new EdgeInsets.only(
                                    left: 8, right: 8),
                                child: Container(
                                  child: new Text(
                                    '${snapshot.data[index].description}',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                  width: wid,
                                ),
                              ),
                              new Padding(
                                padding: new EdgeInsets.only(
                                    left: 8, right: 8, top: 5),
                                child: Container(
                                  child: new Text(
                                    'Swipe left for more...',
                                    style: TextStyle(fontSize: 13.0),
                                  ),
                                  width: wid,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: InAppWebView(
                          initialUrl: '${snapshot.data[index].url}',
                          gestureRecognizers: gestureRecognizers,
                        ),
                      )
                    ],
                    scrollDirection: Axis.horizontal,
                  );
                }, scrollDirection: Axis.vertical,);
            } else
              return Center(child: new CircularProgressIndicator());
          }),
    )
        : Container(
      child: Center(child: CircularProgressIndicator()),
      color:
      Colors
          .
      white
      ,
    );
  }

  final Set<Factory> gestureRecognizers = [
    Factory<VerticalDragGestureRecognizer>(
          () =>
      VerticalDragGestureRecognizer()
        ..onUpdate = (_) {}
      ,
    ),
  ].toSet();

  Future<Null> check_internet() async {
    setState(() {
      hasC = false;
    });
    obj.checkConnection().then((bool hasConnection) {
      setState(() {
        if (hasConnection == true) {
          hasC = true;
          print("if hasconnection true");
          print(hasC);
        } else if (hasConnection == false) {
          hasC = false;
          print("if hasconnection false");
          print(hasC);
        }
      });
    });
    return null;
  }
}