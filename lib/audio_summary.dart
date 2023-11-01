// lib/url_summary.dart
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';




import 'package:bdj_application/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bdj_application/logout.dart';
import 'package:file_picker/file_picker.dart';


class AudioToSummary extends StatefulWidget {
  final String token;
  final String userEmail;
  AudioToSummary({required this.token, required this.userEmail});
  @override
  _AudioToSummaryState createState() => _AudioToSummaryState();
}

class _AudioToSummaryState extends State<AudioToSummary> {
  final logOut = Logout();
  String openai_key = dotenv.get('WHISPER_KEY');

  String authHeader = "";
  String whisper_result = "";
  String summary_result = "";

  String filePath = "";
  String isstart = "";

  void _pickFile() async {
    // 파일 선택
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    // 파일 선택 취소 시
    if (result != null) {
      setState(() {
        filePath = result.files.first.path ?? "";
        isstart = "음성파일 변환중...";
      });
      sendAudioFile(filePath);
      return;
    }
    // 사용자의 기기에서 mp4, mp3, acc, wmv 파일을 열 수 있는 앱이 없다는 메시지를 표시합니다.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("사용자의 기기에서 mp4, mp3, acc, wmv 파일이 선택되지 않았습니다."),
      ),
    );
  }

  void sendAudioFile(String filePath) async {
    var url = Uri.https("api.openai.com", "v1/audio/transcriptions");
    var start = DateTime.now();

    //응답보내기
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(({"Authorization": "Bearer "+openai_key}));
    request.fields["model"] = 'whisper-1';
    request.fields["language"] = "en";
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    var response = await request.send();
    var newResponse = await http.Response.fromStream(response);
    final responseData = convert.json.decode(newResponse.body);
    print(responseData["text"]);
    //만약 1200자 이하면 요약 하지 않는다.
    var sttEnd = DateTime.now();
    setState(() {
      whisper_result = responseData["text"];
      isstart = "STT 변환 까지 걸린 시간 : ${sttEnd.difference(start)}";
    });
    print("STT 완료 까지 걸린 시간 : ${sttEnd.difference(start)}");
    //응답받고 그 이후 추가해야함
    _requestSummary();
    var summEnd = DateTime.now();
    setState(() {
      isstart = "시작부터 요약 완료까지 걸린 시간 : ${summEnd.difference(start)}";
    });
    print("시작부터 요약 완료까지 걸린 시간 : ${summEnd.difference(start)}");
  }

  void _goToHome (){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(token: widget.token, userEmail: widget.userEmail),
      ),
    );
  }


  void _requestSummary() async {
    var url = Uri.http(dotenv.get('API_IP'), '/text_summary/');
    authHeader = "Bearer " + widget.token;
    setState(() {
      summary_result = "요약중입니다...";
    });

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Authorization': authHeader,
        },
        body: {
          "email": widget.userEmail,
          "source_text": whisper_result,
        },
      );
      if (response.statusCode == 200){
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        var summary = jsonResponse['summary'];
        if (summary.length == 0) {
          setState(() {
            summary_result =
            "이 파일은 인식이 불가능 하거나 내용이 짧아 요약이 불가능 합니다.\n다른 파일을 입력해 주세요";
          });
        }
        else{
          setState(() {
            summary_result = summary;
          });
        }
      }else {
        print("HTTP 요청 오류 - 상태 코드: ${response.statusCode}");
        print("오류 응답 본문: ${response.body}");
      }
    } catch (error){
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
                  children: [
                    Container(
                      child: OutlinedButton(
                        onPressed: _goToHome,
                        child: Text('Recent', style: TextStyle(color: Colors.grey),),
                    ),
                  ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: "$summary_result"));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("복사되었습니다."),
                              ),
                            );
                          },
                          child: Text('copy', style: TextStyle(color: Colors.grey)),
                        ),
                        OutlinedButton(
                          onPressed: () {logOut.showLogoutDialog(context);},
                          child: Text('X', style: TextStyle(color: Colors.grey)),
                        ),
                      ],
                    )
                  ],
                ),
                Text('Audio Summary', style: TextStyle(fontSize: 18, color: Colors.grey[500])),

                Column(
                  children:[
                    Text(
                      isstart,
                      style: const TextStyle(fontSize: 15, color:  Colors.grey),
                    ),
                    OutlinedButton(
                      onPressed :_pickFile,
                      child: Text('Select File',style: TextStyle(fontSize: 12, color: Colors.grey[500])),),
                  ]
                ),
                Expanded(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child:Column(
                        children: [
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


