// check_audio.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:bdj_application/login.dart';
import 'package:bdj_application/audio_summary.dart';

bool isAudioSummaryAllowed(isLoggedIn) {
  // 로그인되어 있을 때만 오디오 요약을 사용할 수 있도록 설정합니다.
  return isLoggedIn;
}

void goToAudioSummary(BuildContext context, bool isLoggedIn) {
  // 로그인되어 있지 않으면 오디오 요약 페이지로 이동하지 못하도록 합니다.
  if (!isAudioSummaryAllowed(isLoggedIn)) {
    // 로그인 여부를 확인하는 팝업 창을 표시합니다.
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('로그인 필요'),
          content: Text('로그인해야 오디오 요약을 볼 수 있습니다. 로그인하시겠습니까?'),
          actions: [
            CupertinoDialogAction(
              child: Text('아니요'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('예'),
              onPressed: () {
                // 로그인 페이지로 이동합니다.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
    return;
  }

  // 오디오 요약 페이지로 이동합니다.
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => AudioToSummary(),
    ),
  );
}