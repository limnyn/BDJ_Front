//lib/token_manager.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';



// Create storage
final storage = new FlutterSecureStorage();


//set Tokens
void setTokens(String user_email, String access_token, String refreshToken) async {
  await storage.write(key: "user_email", value: user_email);
  await storage.write(key: "access_token", value: access_token);
  await storage.write(key: "refreshToken", value: refreshToken);
}



//get Tokens tuple
Future<List<String?>> getTokens() async {
  return [await storage.read(key: "user_email"), await storage.read(key: "access_token"), await storage.read(key: "refreshToken")];
}


//if 401 refresh Tokens
Future<bool> refreshAccessToken() async {
  String? refreshToken = await storage.read(key: "refreshToken");
  if (refreshToken == null){
    print("Refresh token is null.");
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
      var jsonResponse =
      convert.jsonDecode(response.body) as Map<String, dynamic>;
      await storage.write(key: "access_token", value: jsonResponse["access"]);
      return true;
    } else {
      await storage.deleteAll();
      //refresh토큰 만료, login화면으로 이동
      print("HTTP 요청 오류 - 상태 코드: ${response.statusCode}");
      print("오류 응답 본문: ${response.body}");
      return false;
    }
  } catch (error) {
    print("HTTP 요청 실패: $error");
    return false;
  }
}
