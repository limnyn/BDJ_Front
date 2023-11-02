import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class DetailSummary extends StatelessWidget {
  final String video_id;
  final String title;
  final String channel_name;
  final String summary;

  DetailSummary({
    required this.video_id,
    required this.channel_name,
    required this.title,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final _controller = YoutubePlayerController.fromVideoId(
      videoId: video_id,
      autoPlay: true,
      params: const YoutubePlayerParams(
        mute: false,
        showControls: true,
        showFullscreenButton: true,

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
    double widgetWidth = (windowWidth > maxWidth ? maxWidth : windowWidth);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: widgetWidth,
            child: Column(
              children: [


                Container(
                    alignment: Alignment.center,
                    child:YoutubePlayer(
                      controller: _controller,
                    )
                ),
                Expanded(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 0, 10, 20),
                      child:Column(
                        children: [

                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            width: double.infinity,
                            color: Colors.grey[830],
                            child: Text(
                              "채널 명 : $channel_name",
                              style: TextStyle(fontSize: 14, color: Colors.grey[500], fontStyle: FontStyle.italic),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                              ),
                              IconButton(onPressed: () {
                                Clipboard.setData(ClipboardData(text: "$title\n$channel_name\n$summary"));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("복사되었습니다."),
                                  ),
                                );
                              }, icon: Icon(Icons.copy_all)
                              ),
                            ],
                          ),
                          // Container(
                          //   padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                          //   width: double.infinity,
                          //
                          //   color: Colors.grey[830],
                          //   child:
                          // ),
                          Container(
                            width: double.infinity,
                            color: Colors.grey[830],
                            child: Text(
                              summary,
                              style: TextStyle(fontSize: 15, color: Colors.grey[500]),
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