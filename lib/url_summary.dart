// lib/url_summary.dart

import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:bdj_application/main.dart';
import 'package:bdj_application/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bdj_application/logout.dart';
class UrlToSummary extends StatefulWidget {
  final String Token;
  final String? user_email;

  UrlToSummary({required this.Token, this.user_email});

  @override
  _UrlToSummaryState createState() => _UrlToSummaryState();
}

class _UrlToSummaryState extends State<UrlToSummary> {
  String authHeader = "Bearer ";

  String video_id = "";
  String summary_title = "";
  String summary_result = "";
  TextEditingController urlInputController = TextEditingController();
  bool isstart = true; // isstart 변수 추가

  void _goToHome (){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(Token: widget.Token, user_email: widget.user_email,),
      ),
    );
  }


  void _requestSummary() async {
    var url = Uri.http(dotenv.get('API_IP'), '/youtube_summary/');
    String youtubeurl = urlInputController.text;
    summary_title = "요약중입니다...";
    summary_result = "";
    video_id = "";
    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Authorization': authHeader,
        },
        body: {
          "email": widget.user_email,
          "url": youtubeurl,
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
        var videoid = jsonResponse["video_id"];
        var title = jsonResponse["title"];
        var summary = jsonResponse["summary"];

        setState(() {
          video_id = videoid;
          summary_title = title;
          summary_result = summary;
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
  void initState(){
    super.initState();
    authHeader += widget.Token;
  }

  @override
  Widget build(BuildContext context) {
    String? maxWidthString = dotenv.get('MAX_WIDTH');
    double maxWidth = 700; // 기본값 설정
    if (maxWidthString != null) {
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
                        onPressed: () {showLogoutDialog(context);},
                        child: Text('X', style: TextStyle(color: Colors.grey)),

                      ),],
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
                        setState(() {
                          isstart = false; // 입력 후 isstart를 false로 설정
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    width: double.infinity,
                    height: 80,
                    color: Colors.grey[830],
                    child: Text(
                      summary_title,
                      style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[830],
                        child: Text(
                          summary_result,
                          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                        ),
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

