//lib/home.dart
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bdj_application/token_manage.dart';
import 'package:bdj_application/home.dart';
import 'package:bdj_application/menubar.dart';
import 'package:bdj_application/detail_summary.dart';


class Summary {
  final int summaryLen;
  final List<SummaryItem> summaries;

  Summary({
    required this.summaryLen,
    required this.summaries,
  });
}

class SummaryItem {
  final String thumbnail;
  final String video_id;
  final String title;
  final String channel_name;
  final String summary;
  final String createdAt;

  SummaryItem({
    required this.thumbnail,
    required this.video_id,
    required this.title,
    required this.channel_name,
    required this.summary,
    required this.createdAt,
  });
}

class MySummaries extends StatefulWidget {
  final bool isLoggedIn;
  MySummaries({required this.isLoggedIn});
  @override
  _MySummariesState createState() => _MySummariesState();
}
class _MySummariesState extends State<MySummaries> {
  static final storage = FlutterSecureStorage();
  String authHeader = "Bearer ";
  Summary? summary; // 객체를 선언하고 초기값을 null로
  @override
  void initState()   {
    super.initState();
    _my_summaries();
  }



  void go_to_detail(String video_id, String title, String summary, String channelName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailSummary(
          video_id: video_id,
          title: title,
          summary: summary,
          channel_name: channelName,
        ),
      ),
    );
  }


  Future<void> _my_summaries() async {
    var url = Uri.http(dotenv.get('API_IP'), '/api/user/summaries/');
    dynamic user_email = await storage.read(key: "email");
    await TokenManager().refreshAccessToken();
    dynamic access_token = await storage.read(key: "access_token");
    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Authorization': authHeader + access_token,
        },
        body: {
        "email":user_email,
        },
      );
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        var newSummary = Summary(
          summaryLen: jsonResponse['summary_len'],
          summaries: List<SummaryItem>.from(jsonResponse['summaries'].map(
                (summaryData) => SummaryItem(
              thumbnail: summaryData['thumbnail'],
              video_id: summaryData['video_id'],
              channel_name: summaryData['channel_name'],
              title: summaryData['title'],
              summary: summaryData['summary'],
              createdAt: summaryData['created_at'],
            ),
          )),
        );
        setState(() {
          summary = newSummary;
        });
      }
      else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Home(isLoggedIn: false), // Start page
          ),
        );
        print("HTTP 요청 오류 - 상태 코드: ${response.statusCode}");
        print("오류 응답 본문: ${response.body}");
      }
    } catch (error) {
      // HTTP 요청 자체가 실패한 경우에 대한 예외 처리
      print("HTTP 요청 실패: $error");

    }
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
        title: Text('My Summarized Videos', style: TextStyle(fontSize: 18, color: Colors.grey[500])),
        iconTheme: IconThemeData(color:Colors.grey[500]),
      ),
      // drawerEnableOpenDragGesture: true,
      drawer: MenuDrawer(pageName: 'mySummaries',isLoggedIn: widget.isLoggedIn,),
      backgroundColor: Colors.grey[900],
      body:SafeArea(
        child: Align(
          alignment: Alignment.center,
          child:
          Container(
            width: widgetWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Expanded(
                  child:RefreshIndicator(
                    onRefresh: _my_summaries,
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
                                  summary!.summaries[i].video_id,
                                  summary!.summaries[i].title,
                                  summary!.summaries[i].summary,
                                  summary!.summaries[i].channel_name,
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${summary!.summaries[i].channel_name}', // 요약 정보의 제목 출력
                                    style: TextStyle(fontSize: 13, color: Colors.grey[500], fontStyle: FontStyle.italic),
                                  ),
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
                                    width: double.infinity,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}