import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class DetailSummary extends StatelessWidget {
  final String video_id;
  final String title;
  final String summary;

  DetailSummary({
    required this.video_id,
    required this.title,
    required this.summary,
  });

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
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(35.0),
      //   child: AppBar(title: Text('Detail',style: TextStyle(color: Colors.grey[500]),),centerTitle: true,elevation: 0.0,backgroundColor: Colors.grey[800],)
      // ),
      backgroundColor: Colors.grey[900],

      body:
          SafeArea(
            child: Align(
                alignment: Alignment.center,
                child:
                Container(
                  width: widgetWidth,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          child: Text('<', style: TextStyle(color: Colors.grey),),
                        ),
                      ),

                      Text(video_id, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        width: double.infinity,
                        height: 80,
                        color: Colors.grey[830],
                        child: Text(
                          title,
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
                              summary,
                              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                            ),
                          ),
                        ),
                      ),],
                  ),
                )
            ),
          ),
    );
  }
}
