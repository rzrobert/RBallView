import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_3d_ball/flutter_3d_ball.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<RBallTagData>> _recommendUserfuture;
  bool isAnimate = true;
  @override
  void initState() {
    _recommendUserfuture = _getRecommendUserList();
    super.initState();
  }

  Future<List<RBallTagData>> _getRecommendUserList() async {
    await Future.delayed(Duration(milliseconds: 3000));
    List datas = [
      {"tag": "ðâ±ââ§åè´§é»æðð·ð", "id": "5fe618941ff65076de93c264"},
      {"tag": "å¸­è¾°", "id": "5d86e5ede5dd2942ab0a1917"},
      {"tag": "ðªM&Mð­ð°", "id": "6097ed9c1ff65076def09983"},
      {"tag": "ã¤", "id": "5d7cc493e5dd2942abb239b8"},
      {"tag": "å¥¶è¶", "id": "598873b97b6dc40027da4bfd"},
      {"tag": "7âà§²å°æè¾è¿ªâ£ï¸â¹Â³", "id": "5d8c8bbae5dd2942ab31d19a"},
      {"tag": "â¦Eâ¤", "id": "5d2845e1e5dd2942abd917f5"},
      {"tag": "å®è´", "id": "5ebf77273ee3b2b263173fd2"},
      {"tag": "à¥ªá´¹é¹¿é¹¿âªï¸", "id": "59793f34045962001bf00ec2"},
      {"tag": "Le Sin Yong", "id": "617b53e5d768e953a1fe7ffb"},
      {"tag": "â", "id": "603cc6011ff65076dee97ef6"},
      {"tag": "è·å¦¡.", "id": "5fb312ed1ff65076deec5ab4"},
      {"tag": "ð©ððð¿ð", "id": "5f0c1bd13ee3b2b263ac71b7"},
      {"tag": "ð è¯ðà½²à¾", "id": "5c13c9f6242a2407cb0cd5a3"},
      {"tag": "å®å®ð«à½²à¾", "id": "61309edad768e953a15abe1f"},
      {"tag": "Victoria", "id": "617b582cd768e953a1fe8461"},
      {"tag": "èç¶", "id": "598865db39f29d001b396695"},
      {"tag": "æè§æççæ´»åä¹ä¸ç²¾å½©.", "id": "5e1ed9da6ddd97d074fa48b5"},
      {"tag": "è´¦å·æäººä»£ä¸", "id": "5b9e0d90242a2407cb844e09"},
      {"tag": "éº»è¯ç±½ð¦¦", "id": "5e940f831f468ea3656a4447"},
      {"tag": "á´´á´®å²ðTiffanyð§¸", "id": "594d1df06d668500110051bf"},
      {"tag": "å©å©", "id": "60219dd71ff65076de83eb67"},
      {"tag": "Timok Ersbin", "id": "615ed0c7d768e953a1c564c4"},
      {"tag": "å®å¬ä¸»ðà½²à¾Êá´ÊÊá´â¥ï¸à½²à¾", "id": "597efa067710ad00274620d4"},
      {"tag": "å«£.ð§ââï¸", "id": "599d82eee15b1e00110ef4a7"},
      {"tag": "ð®å°æ", "id": "5a852f80242a2407cbfc8b9a"},
      {"tag": "Ü¤ bun", "id": "59c647007ab9f9fb0e33413e"},
      {"tag": "â ð å­æ¾å­æ¾å­ðï¸â£", "id": "59893f98a8da48001b975e4e"},
      {"tag": "é­ä¸æ­²ð·", "id": "5e881ac970a902a5db95ebcf"},
      {"tag": "ð¾ðððð ðððð", "id": "59b4ca387ab9f9fb0e29ef57"}
    ];
    List<RBallTagData> list = [];
    if (datas.length > 0) {
      datas.forEach((element) {
        RBallTagData tag = RBallTagData.fromJson(element);
        list.add(tag);
      });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: const Text(
            'Plugin example app',
            style: TextStyle(color: Color(0xFF333333)),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        body: Container(
          width: double.infinity,
          child: FutureBuilder<List<RBallTagData>>(
            future: _recommendUserfuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              double _wh =
                  ((MediaQuery.of(context).size.width - 2 * 10) * 32 / 35);
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: snapshot.connectionState == ConnectionState.done
                    ? snapshot.hasError
                        ? Text("Error: ${snapshot.error}")
                        : RBallView(
                            isAnimate: isAnimate,
                            isShowDecoration: true,
                            mediaQueryData: MediaQuery.of(context),
                            keywords: snapshot.data,
                            highlight: [snapshot.data[0]],
                            onTapRBallTagCallback: (RBallTagData data) {
                              print('ç¹å»åè°ï¼${data.tag}');
                            },
                            textColor: Colors.white,
                            highLightTextColor: Colors.red,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius:
                                  BorderRadius.circular((_wh / 2).toDouble()),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xffffffff),
                                  blurRadius: 5.0,
                                )
                              ],
                            ),
                          )
                    : Text('Searching for friends...'),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Center(
            child: Icon(isAnimate ? Icons.pause : Icons.play_arrow),
          ),
          onPressed: () {
            setState(() {
              isAnimate = !isAnimate;
            });
          },
        ),
      ),
    );
  }
}
