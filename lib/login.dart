import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bdj_application/home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bdj_application/user_register.dart';


void goToLogin(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text('Login 확인'),
        content: Text('Login으로 이동합니다.'),
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
}



class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static final storage = FlutterSecureStorage();

  String auth_token = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoggedIn = false;


  void _sendRequest() async {
    var url = Uri.http(dotenv.get('API_IP'), '/login/');

    String email = emailController.text;
    String password = passwordController.text;

    try {
      var response = await http.post(url, body: {
        "email": email,
        "password": password,
      });
      if (response.statusCode == 200) {
        print('login success');
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        var refreshToken = jsonResponse["refresh_token"];


        await storage.write(key: "email", value: email);
        await storage.write(key: "refresh_token", value: refreshToken);

        print("push to home");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Home(isLoggedIn: true)
          ),
        );

      } else {
        final jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        final emailError = jsonResponse["email"];
        final passwordError = jsonResponse["password"];
        final non_field_errors = jsonResponse["non_field_errors"];

        final snackBar = SnackBar(
          content: Text(emailError != null ? emailError[0] : passwordError != null ? passwordError[0] : non_field_errors[0]),

        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar); // 수정된 부분
        print("HTTP 요청 오류 - 상태 코드: ${response.statusCode}");
        print("오류 응답 본문: ${response.body}");
      }
    } catch (error) {
      // HTTP 요청 자체가 실패한 경우에 대한 예외 처리
      print("HTTP 요청 실패: $error");
    }
  }

  void goToSignUp (){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UserRegister(),
      ),
    );
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
    double containerWidth = (windowWidth > maxWidth ? maxWidth: windowWidth);
    return Scaffold(
      backgroundColor: Colors.grey[900],

      // appBar: AppBar(title: Text('요약 앱')),
      body: Align(


        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login',
                style: TextStyle(fontSize: 20,color: Colors.grey[500])),


            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              width: containerWidth,
              height: 80,
              color: Colors.grey[830],
              child: TextField(
                controller: emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: "Email", labelStyle: TextStyle(color:  Colors.grey[500]),),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            // SizedBox(height: 20), // 간격 조절
            Container(
              padding:  EdgeInsets.fromLTRB(20, 0, 20, 0),
              width: containerWidth,
              height: 80,
              color: Colors.grey[830],
              child: TextField(
                obscureText: true, //비밀번호 가리기
                controller: passwordController,
                onSubmitted: (_){
                  _sendRequest();
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: "Password", labelStyle: TextStyle(color:  Colors.grey[500])),
              ),
            ),
            ElevatedButton(
                onPressed: _sendRequest,
                child: Text('login', style: TextStyle(color: Colors.grey),),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade800))

            ),
            SizedBox(
              height: 50,
              child: Container(),
            ),
            ElevatedButton(
                onPressed: goToSignUp,
                child: Text('sign in', style: TextStyle(color: Colors.grey),),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade800))

            ),
            // Display the authentication token if available

          ],
        ),

      ),
    );
  }

}
