import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
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
    final _controller = YoutubePlayerController.fromVideoId(
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
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('<', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child:YoutubePlayer(
                    controller: _controller,
                  )

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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
