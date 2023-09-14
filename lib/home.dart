import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:bdj_application/detail_summary.dart';
import 'package:bdj_application/url_summary.dart';
import 'package:bdj_application/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class Summary {
  final int summaryLen;
  final List<SummaryItem> summaries;

  Summary({
    required this.summaryLen,
    required this.summaries,
  });
}

class SummaryItem {
  final String urlLink;
  final String title;
  final String summary;
  final String createdAt;

  SummaryItem({
    required this.urlLink,
    required this.title,
    required this.summary,
    required this.createdAt,
  });
}

class Home extends StatefulWidget {
  final String Token;
  final String? user_email;

  Home({required this.Token, this.user_email});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String authHeader = "Bearer ";

  Summary? summary; // 객체를 선언하고 초기값을 null로

  void _goToUrlSummary() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UrlToSummary(Token: widget.Token, user_email: widget.user_email,),
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
  void go_to_detail(String urllink, String title, String summary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailSummary(
          urllink: urllink,
          title: title,
          summary: summary,
        ),
      ),
    );
  }


  void _recent_summary() async {
    // var url = Uri.http('10.0.2.2:8000', '/recent_summary/');
    var url = Uri.http(dotenv.get('API_IP'), '/recent_summary/');
    try {
      var response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': authHeader,
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        var newSummary = Summary(
          summaryLen: jsonResponse['summary_len'],
          summaries: List<SummaryItem>.from(jsonResponse['summaries'].map(
                (summaryData) => SummaryItem(
              urlLink: summaryData['url_link'],
              title: summaryData['title'],
              summary: summaryData['summary'],
              createdAt: summaryData['created_at'],
            ),
          )),
        );

        // setState를 호출하여 summary 객체를 업데이트하고 화면을 다시 그림
        setState(() {
          summary = newSummary;
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
    authHeader += widget.Token;

    _recent_summary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [ Container(
                child: OutlinedButton(
                  onPressed: _goToUrlSummary,
                  child: Text('Yotube', style: TextStyle(color: Colors.grey),),

                ),
              ),

                OutlinedButton(
                  onPressed: _showLogoutConfirmationDialog,
                  child: Text('X', style: TextStyle(color: Colors.grey)),

                ),],
            ),
            Text('Recent Summary', style: TextStyle(fontSize: 20, color: Colors.grey[500])),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: summary == null // summary가 null인 경우 로딩 중 화면을 보여줄 수 있음
                    ? CircularProgressIndicator() // 로딩 중 표시
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < summary!.summaries.length; i++)
                      GestureDetector(
                        onTap: () {
                          // Column을 터치할 때 실행할 함수 호출
                          go_to_detail(
                            summary!.summaries[i].urlLink,
                            summary!.summaries[i].title,
                            summary!.summaries[i].summary,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${summary!.summaries[i].title}', // 요약 정보의 제목 출력
                              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                            ),
                            Text(
                              '${summary!.summaries[i].summary}', // 요약 정보의 내용 출력
                              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            ),
                            Container(
                              height: 1.0,
                              width: 500.0,
                              color: Colors.grey[500],
                            ),
                            SizedBox(height: 10), // 아이템 간격 조절을 위한 간격 추가
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),



          ],
        ),
      ),
    );
  }
}
