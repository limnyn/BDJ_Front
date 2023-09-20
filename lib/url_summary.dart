// lib/url_summary.dart

import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';


import 'package:bdj_application/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bdj_application/logout.dart';


String? extractYouTubeVideoId(String url) {
  RegExp regExp = RegExp(
    r"(?:https:\/\/)?(?:www\.)?youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)",
    caseSensitive: false,
    multiLine: false,
  );

  Match? match = regExp.firstMatch(url);
  if (match != null && match.groupCount >= 1) {
    return match.group(1);
  }

  return null;
}


class UrlToSummary extends StatefulWidget {
  final String token;
  final String userEmail;

  UrlToSummary({required this.token, required this.userEmail});

  @override
  _UrlToSummaryState createState() => _UrlToSummaryState();
}

class _UrlToSummaryState extends State<UrlToSummary> {
  final logOut = Logout();


  String authHeader = "";
  String video_id = "";
  String summary_title = "";
  String summary_result = "";
  String channel_name = "";
  TextEditingController urlInputController = TextEditingController();


  bool isstart = true; // isstart 변수 추가

  // void _goToLogin(BuildContext context){
  //   Navigator.of(context).pushReplacement(
  //     MaterialPageRoute(builder: (context) => MyApp(), //start page로
  //     ),
  //   );
  // }

  void _goToHome (){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(token: widget.token, userEmail: widget.userEmail),
      ),
    );
  }


  void _requestSummary() async {
    var url = Uri.http(dotenv.get('API_IP'), '/youtube_summary/');
    String youtubeurl = urlInputController.text;
    setState(() {
      video_id = extractYouTubeVideoId(youtubeurl) ?? "";
      authHeader = "Bearer " + widget.token;
    });

    isstart = false;
    summary_title = "요약중입니다...";

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Authorization': authHeader,
        },
        body: {
          "email": widget.userEmail,
          "url": youtubeurl,
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        var videoId = jsonResponse["video_id"];
        var title = jsonResponse["title"];
        var channelName = jsonResponse["channel_name"];
        var summary = jsonResponse["summary"];

        setState(() {
          video_id = videoId;
          summary_title = title;
          summary_result = summary;
          channel_name = "채널 : " + channelName;
        });

      } else {
        print("HTTP 요청 오류 - 상태 코드: ${response.statusCode}");
        print("오류 응답 본문: ${response.body}");
      }
    } catch (error) {
      // HTTP 요청 자체가 실패한 경우에 대한 예외 처리
      print("HTTP 요청 실패: $error");
    }
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var _controller = YoutubePlayerController.fromVideoId(
      videoId: video_id,
      autoPlay: false,
      params: const YoutubePlayerParams(
          mute: false,
          showControls: true,
          showFullscreenButton: true
      ),
    );
    String maxWidthString = dotenv.get('MAX_WIDTH');
    double maxWidth = 700; // 기본값 설정
    if (maxWidthString.isNotEmpty) {
      double? parsedMaxWidth = double.tryParse(maxWidthString);
      if (parsedMaxWidth != null) {
        maxWidth = parsedMaxWidth; // 유효한 값인 경우에만 할당
      }
    }
    double windowWidth = MediaQuery.of(context).size.width;
    double widgetWidth = (windowWidth > maxWidth ? maxWidth: windowWidth);
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Align(
        alignment: Alignment.center,
        child: Container(
          width: widgetWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [ Container(
                      child: OutlinedButton(
                        onPressed: _goToHome,
                        child: Text('Recent', style: TextStyle(color: Colors.grey),),

                      ),
                    ),

                      OutlinedButton(
                        onPressed: () {logOut.showLogoutDialog(context);},
                        child: Text('X', style: TextStyle(color: Colors.grey)),

                      ),
                    ],
                  ),


                  Text('Youtube Summary', style: TextStyle(fontSize: 20, color: Colors.grey[500])),

                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    width: double.infinity,
                    height: 80,
                    color: Colors.grey[830],
                    child: TextField(
                      controller: urlInputController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Youtube url을 입력해주세요.",
                        labelStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      onSubmitted: (_) {
                        _requestSummary();

                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20,0, 20, 0),
                    width: double.infinity,
                    color: Colors.grey[830],
                    child: Visibility(
                      visible:video_id.isNotEmpty, // isstart가 false일 때만 보이도록 설정
                      child: YoutubePlayer(
                        controller: _controller,
                      ),
                    ),
                  ),


                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child:Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                            width: double.infinity,
                            color: Colors.grey[830],
                            child: Text(
                              channel_name,
                              style: TextStyle(fontSize: 15, color: Colors.grey[500], fontStyle: FontStyle.italic),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            width: double.infinity,
                            color: Colors.grey[830],
                            child: Text(
                              summary_title,
                              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            color: Colors.grey[830],
                            child: Text(
                              summary_result,
                              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                            ),
                          ),
                        ],
                      )
                    ),
                  ),
                ],
              ),
            ),
        ),
      ),
    );
  }
}

