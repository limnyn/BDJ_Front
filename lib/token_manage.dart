//
//lib/token_manager.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TokenManager {
  // 이 클래스 레벨에서 storage를 static으로 선언
  static final storage = FlutterSecureStorage();

  // if 401 refresh Tokens
  Future<bool> refreshAccessToken() async {
    dynamic refreshToken = await storage.read(key: "refresh_token");

    if (refreshToken == null) {
      print("Refresh token is null.");
      await storage.deleteAll();
      return false;
    }
    try {
      var url = Uri.http(dotenv.get('API_IP'), '/token/refresh/');
      var response = await http.post(
        url,
        body: {
          "refresh": refreshToken
        },
      );
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        var newAccessToken = jsonResponse["access"];
        print("refreshed access Token : $newAccessToken");
        await storage.write(key: "access_token", value: newAccessToken);
        return true;
      } else {
        await storage.deleteAll();
        // refresh토큰 만료, login화면으로 이동
        print("HTTP 요청 오류 - 상태 코드: ${response.statusCode}");
        print("오류 응답 본문: ${response.body}");
        return false;
      }
    } catch (error) {
      print("HTTP 요청 실패 in token_manager: $error");
      return false;
    }
  }
}

