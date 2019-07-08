import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:newnewnews/MyInAppBrowser.dart';

import 'package:share/share.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import './globalStore.dart' as globalStore;
//import './SearchScreen.dart' as SearchScreen;
import 'package:newnewnews/model.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
//import './MyInAppBrowser.dart' as MyInAppBrowser;



class HomeFeedScreen extends StatefulWidget {
  HomeFeedScreen({Key key}) : super(key: key);

  @override
  _HomeFeedScreenState createState() => _HomeFeedScreenState();
}
 
class _HomeFeedScreenState extends State<HomeFeedScreen> {
  var data;
  var sSelection = "techcrunch";
  DataSnapshot snapshot;
  var snapSources;
  //TimeAgo ta =  TimeAgo();
  //final FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  final TextEditingController _controller = TextEditingController();
  final MyInAppBrowser inAppBrowser =  MyInAppBrowser();
  
  Future getData() async {
    await globalStore.logIn;
    if (await globalStore.userDatabaseReference == null) {
      await globalStore.logIn;
    }
    snapSources = await globalStore.articleSourcesDatabaseReference.once();
    var snap = await globalStore.articleDatabaseReference.once();
    if (snapSources.value != null) {
      sSelection = '';
      snapSources.value.forEach((key, source) {
        sSelection = sSelection + source['id'] + ',';
      });
    }
    final itemsData = await fetchMovieList();
    if (mounted) {this.setState(() {
      data = itemsData;
      snapshot = snap;
    });
    }

    return "Success!";
  }
  @override
  void dispose() {
    super.dispose();

  }

 Future<ItemModel> fetchMovieList() async {
   /*   var dio = new Dio();
    
   var response = await dio.get(
    'https://sapi.org/v2/top-headlines?sources=' + sSelection,
    // Transform response data to Json Map
    options: new Options(responseType: ResponseType.json,
    headers: {
          "Accept": "application/json",
          "X-Api-Key": "ab31ce4a49814a27bbb16dd5c5c06608"
        }),
  ); */
     var response = await http.get(
        Uri.encodeFull(
            'https://newsapi.org/v2/top-headlines?sources=' + sSelection),
        headers: {
          "Accept": "application/json",
          "X-Api-Key": "e33ca3b5e41c44718d139af128f10104"
        }); 
    var localData = json.decode(response.body);

    Map<String, dynamic> values = Map<String, dynamic>.from(localData);

    final mapJsonArticle = Map<String, dynamic>.from(values);

    print(mapJsonArticle);
    final data = ItemModel.fromJson(mapJsonArticle);
    return data;
  }

  _hasArticle(article) {
    if (snapshot.value != null) {
      var value = snapshot.value;
      int flag = 0;
      if (value != null) {
        value.forEach((k, v) {
          if (v['url'].compareTo(article.url) == 0) {
            flag = 1;
            return;
          }
        });
        if (flag == 1) return true;
      }
    }
    return false;
  }

  pushArticle(article) {
    globalStore.articleDatabaseReference.push().set({
      'source': article.source.name,
      'description': article.description,
      'publishedAt': article.publishedAt,
      'title': article.title,
      'url': article.url,
      'urlToImage': article.urlToImage,
    });
  }

  _onBookmarkTap(article) {
    if (snapshot.value != null) {
      var value = snapshot.value;
      int flag = 0;
      value.forEach((k, v) {
        if (v['url'].compareTo(article.url) == 0) {
          flag = 1;
          globalStore.articleDatabaseReference.child(k).remove();
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Article removed'),
            backgroundColor: Colors.grey[600],
          ));
        }
      });
      if (flag != 1) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Article saved'),
          backgroundColor: Colors.grey[600],
        ));
        pushArticle(article);
      }
    } else {
      pushArticle(article);
    }
    this.getData();
  }

  _onRemoveSource(id, name) {
    if (snapSources != null) {
      snapSources.value.forEach((key, source) {
        if (source['id'].compareTo(id) == 0) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Are you sure you want to remove $name?'),
            backgroundColor: Colors.grey[600],
            duration: Duration(seconds: 3),
            action: SnackBarAction(
                label: 'Yes',
                onPressed: () {
                  globalStore.articleSourcesDatabaseReference
                      .child(key)
                      .remove();
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('$name removed'),
                      backgroundColor: Colors.grey[600]));
                }),
          ));
        }
      });
      this.getData();
    }
  }

  void handleTextInputSubmit(var input) {
   /*  if (input != '') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SearchScreen.SearchScreen(searchQuery: input)));
    } */
  }

  @override
  void initState() {
   // flutterWebviewPlugin.close();

    super.initState();
    this.getData();
  }

  launchUrl(String _url) async {

    await inAppBrowser.open(url: _url, options: {
              "useShouldOverrideUrlLoading": true,
              "useOnLoadResource": true
            });
    // return  Container (
    //       child:  InAppWebView(
    //                 initialUrl: _url,
    //                 initialHeaders: {

    //                 },
    //                 initialOptions: {

    //                 },
    //                 onWebViewCreated: (InAppWebViewController controller) {
    //                   webView = controller;
    //                 },
    //                 onLoadStart: (InAppWebViewController controller, String _url) {
    //                   print("started $_url");
    //                   setState(() {
    //                     this.url = url;
    //                   });
    //                 },
    //                 onProgressChanged: (InAppWebViewController controller, int progress) {
    //                   setState(() {
    //                     this.progress = progress/100;
    //                   });
    //                 }
    //                 )
    
    // );
  }
    

  Column buildButtonColumn(IconData icon) {
    Color color = Theme.of(context).primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(icon, color: color),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.grey[200],
        body: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(0.0),
            child: PhysicalModel(
              color: Colors.white,
              elevation: 3.0,
              child: TextField(
                controller: _controller,
                onSubmitted: handleTextInputSubmit,
                decoration: InputDecoration(
                    hintText: 'Finding s?', icon: Icon(Icons.search)),
              ),
            ),
          ),
          Expanded(
              child: data == null
                  ? Center(child: const CircularProgressIndicator())
                  : data.Articles.length != 0
                      ? ListView.builder(
                          itemCount: data == null ? 0 : data.Articles.length,
                          padding: EdgeInsets.all(8.0),
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 1.7,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(left: 4.0),
                                          child: Text(
                                            timeAgo.format
                                            (DateTime.parse(data.Articles[index].publishedAt)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                      
                                           data.Articles[index].source.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 4.0,
                                                      right: 8.0,
                                                      bottom: 8.0,
                                                      top: 8.0),
                                                  child: Text(
                                                    data.Articles[index].title,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 4.0,
                                                      right: 4.0,
                                                      bottom: 4.0),
                                                  child: Text(
                                                    data.Articles[index].description,
                                                    style: TextStyle(
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            onTap: () {
                                              String _url = data.Articles[index].url;
                                              launchUrl(_url);
                                              },
                                          ),
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 8.0),
                                              child: SizedBox(
                                                height: 100.0,
                                                width: 100.0,
                                                child: data.Articles[index].urlToImage != null?
                                                FadeInImage.memoryNetwork(
                                                  placeholder: kTransparentImage,
                                                  image:  data.Articles[index].urlToImage,
                                                          fit: BoxFit.cover,
                                                ):
                                                Image.asset(
                                                      'assets/placeholder.jpg',
                                                )
                                                ,
                                              ),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                GestureDetector(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10.0,
                                                              horizontal: 5.0),
                                                      child: buildButtonColumn(
                                                          Icons.share)),
                                                  onTap: () {
                                                    Share.share(
                                                      data.Articles[index] != null?
                                                        data.Articles[index].url:""
                                                    );
                                                  }
                                                ),
                                                GestureDetector(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(5.0),
                                                      child: _hasArticle(data
                                                              .Articles[index])
                                                          ? buildButtonColumn(
                                                              Icons.bookmark)
                                                          : buildButtonColumn(Icons
                                                              .bookmark_border)),
                                                  onTap: () {
                                                    _onBookmarkTap(
                                                        data.Articles[index] != null?
                                                          data.Articles[index] : ""
                                                    );                                                 
                                                  },
                                                ),
                                                GestureDetector(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(5.0),
                                                      child: buildButtonColumn(
                                                          Icons
                                                              .not_interested)),
                                                  onTap: () {
                                                    _onRemoveSource(
                                                      data.Articles[index].source.id,
                                                      data.Articles[index].source.name,
                                                       
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ), ////
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chrome_reader_mode,
                                  color: Colors.grey, size: 60.0),
                              Text(
                                "No articles saved",
                                style: TextStyle(
                                    fontSize: 24.0, color: Colors.grey),
                              ),
                            ],
                          ),
                        ))
        ]
        )
        );
  }
}
