// lib/url_summary.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bdj_application/menubar.dart';
import 'package:bdj_application/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bdj_application/logout.dart';




String? extractYouTubeVideoId(String url) {
  final pattern = RegExp(
      r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/watch\?.*?v=|youtube\.com/watch\?.*?&v=)([a-zA-Z0-9_-]+)');

  final match = pattern.firstMatch(url);
  if (match != null) {
    final videoId = match.group(1);
    print(videoId);
    return videoId;
  } else {
    print('$url의 Video ID를 찾을 수 없습니다.');
    return null;
  }
}



class UrlToSummary extends StatefulWidget {
  final bool isLoggedIn;
  UrlToSummary({required this.isLoggedIn});
  @override
  _UrlToSummaryState createState() => _UrlToSummaryState();
}

class _UrlToSummaryState extends State<UrlToSummary> {
  static final storage = FlutterSecureStorage();
  final logOut = Logout();
  final YoutubePlayerController _controller = YoutubePlayerController.fromVideoId(videoId: "", autoPlay:  true,
    params: const YoutubePlayerParams(
        mute: false,
        showControls: true,
        showFullscreenButton: true
    ),);
  String authHeader = "";
  String video_id = "";
  String summary_title = "";
  String summary_result = "";
  String channel_name = "";
  TextEditingController urlInputController = TextEditingController();
  bool isstart = false; // isstart 변수 추가


  void _goToHome (){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(isLoggedIn: widget.isLoggedIn),
      ),
    );
  }



  void _requestSummary() async {
    var url = Uri.http(dotenv.get('API_IP'), '/youtube_summary/');
    String youtubeurl = urlInputController.text;
    video_id = extractYouTubeVideoId(youtubeurl) ?? "";
    setState(() {
      summary_title = "요약중입니다...";
      channel_name = "";
      summary_result = "";
      _controller.loadVideoById(videoId: video_id);
      _controller.playVideo();
      isstart = true;
    });
    dynamic user_email = await storage.read(key: "email");
    user_email ??="";
    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Authorization': authHeader,
        },
        body: {
          "email":user_email,
          "url": youtubeurl,
        },
      );
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        var videoId = jsonResponse["video_id"];
        var title = jsonResponse["title"];
        var channelName = jsonResponse["channel_name"];
        var summary = jsonResponse["summary"];
        if (summary.length == 0){
          setState(() {
            summary_title = "이 영상은 요약이 불가능합니다.\n다른 Url을 입력해주세요";
          });
        }
        else{
          setState(() {
            video_id = videoId;
            summary_title = title;
            summary_result = summary;
            channel_name = "채널 : " + channelName;
          });
        }
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
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text('Youtube Summary', style: TextStyle(fontSize: 18, color: Colors.grey[500])),
        iconTheme: IconThemeData(color: Colors.grey[500]),
      ),
      drawer: MenuDrawer(pageName: 'youtube', isLoggedIn: widget.isLoggedIn,),
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: widgetWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  width: double.infinity,
                  height: 80,
                  color: Colors.grey[830],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
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
                      IconButton(onPressed: () {
                        Clipboard.setData(ClipboardData(text: "$summary_title\n$channel_name\n$summary_result"));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("복사되었습니다."),
                          ),
                        );
                      }, icon: Icon(Icons.copy_outlined)
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  width: double.infinity,
                  color: Colors.grey[830],
                  child: Visibility(
                    visible: isstart,
                    child: YoutubePlayer(
                      controller: _controller,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Column(
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
                    ),
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

