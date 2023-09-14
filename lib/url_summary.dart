// lib/url_summary.dart

import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:bdj_application/main.dart';
import 'package:bdj_application/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class UrlToSummary extends StatefulWidget {
  final String Token;
  final String? user_email;

  UrlToSummary({required this.Token, this.user_email});

  @override
  _UrlToSummaryState createState() => _UrlToSummaryState();
}

class _UrlToSummaryState extends State<UrlToSummary> {
  String authHeader = "Bearer ";
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

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900], // 배경색 설정
          title: Text(
            '로그아웃 확인',
            style: TextStyle(color: Colors.white60), // 글자 색상 설정
          ),
          content: Text(
            '로그아웃하시겠습니까?',
            style: TextStyle(color: Colors.white60), // 글자 색상 설정
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.white60), // 글자 색상 설정
              ),
              onPressed: () {

                _logOut();
              },
            ),
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: Colors.white60), // 글자 색상 설정
              ),
              onPressed: () {
                // 로그아웃 작업 수행

                Navigator.of(context).pop(); // 팝업 닫기
              },
            ),
          ],
        );

      },
    );
  }

  void _logOut() {
    Navigator.of(context).pop(); // 팝업 닫기
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyApp(), // start page로
      ),
    );
  }



  void _requestSummary() async {
    var url = Uri.http(dotenv.get('API_IP'), '/youtube_summary/');
    String youtubeurl = urlInputController.text;
    summary_title = "요약중입니다...";
    summary_result = "";
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
        var title = jsonResponse["title"];
        var summary = jsonResponse["summary"];

        setState(() {
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
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Align(
        alignment: Alignment.center,
        child:
        Column(
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
                  onPressed: _showLogoutConfirmationDialog,
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
    );
  }
}

