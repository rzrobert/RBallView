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
      {"tag": "💜ℱℛ❧吃货默染🈂🈷💜", "id": "5fe618941ff65076de93c264"},
      {"tag": "席辰", "id": "5d86e5ede5dd2942ab0a1917"},
      {"tag": "🪐M&M🇭🇰", "id": "6097ed9c1ff65076def09983"},
      {"tag": "ㅤ", "id": "5d7cc493e5dd2942abb239b8"},
      {"tag": "奶茶", "id": "598873b97b6dc40027da4bfd"},
      {"tag": "7₉৲小柔蕾迪♣︎⁹³", "id": "5d8c8bbae5dd2942ab31d19a"},
      {"tag": "₦E☤", "id": "5d2845e1e5dd2942abd917f5"},
      {"tag": "宝贝", "id": "5ebf77273ee3b2b263173fd2"},
      {"tag": "४ᴹ鹿鹿☪︎", "id": "59793f34045962001bf00ec2"},
      {"tag": "Le Sin Yong", "id": "617b53e5d768e953a1fe7ffb"},
      {"tag": "☕", "id": "603cc6011ff65076dee97ef6"},
      {"tag": "芷妡.", "id": "5fb312ed1ff65076deec5ab4"},
      {"tag": "🅩🅞🅞🌿🕊", "id": "5f0c1bd13ee3b2b263ac71b7"},
      {"tag": "🐠芯🌙ིྀ", "id": "5c13c9f6242a2407cb0cd5a3"},
      {"tag": "宅宅💫ིྀ", "id": "61309edad768e953a15abe1f"},
      {"tag": "Victoria", "id": "617b582cd768e953a1fe8461"},
      {"tag": "藍瓶", "id": "598865db39f29d001b396695"},
      {"tag": "感觉我的生活再也不精彩.", "id": "5e1ed9da6ddd97d074fa48b5"},
      {"tag": "账号有人代上", "id": "5b9e0d90242a2407cb844e09"},
      {"tag": "麻薯籽🦦", "id": "5e940f831f468ea3656a4447"},
      {"tag": "ᴴᴮ儲💎Tiffany🧸", "id": "594d1df06d668500110051bf"},
      {"tag": "倩倩", "id": "60219dd71ff65076de83eb67"},
      {"tag": "Timok Ersbin", "id": "615ed0c7d768e953a1c564c4"},
      {"tag": "安公主💐ིྀʙᴇʟʟᴀ♥️ིྀ", "id": "597efa067710ad00274620d4"},
      {"tag": "嫣.🧚‍♀️", "id": "599d82eee15b1e00110ef4a7"},
      {"tag": "💮小敏", "id": "5a852f80242a2407cbfc8b9a"},
      {"tag": "ܤ bun", "id": "59c647007ab9f9fb0e33413e"},
      {"tag": "₠🌠六拾六拾六🏐️❣", "id": "59893f98a8da48001b975e4e"},
      {"tag": "魚三歲🐷", "id": "5e881ac970a902a5db95ebcf"},
      {"tag": "𝑾𝒐𝒔𝒉𝒊 𝒍𝒊𝒏𝒏", "id": "59b4ca387ab9f9fb0e29ef57"}
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
                              print('点击回调：${data.tag}');
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
