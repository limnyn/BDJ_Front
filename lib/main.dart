//lib/main.dart
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:bdj_application/home.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bdj_application/user_register.dart';
import 'package:bdj_application/token_manage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  runApp((const MyApp()));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Summary Site',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '요약프로그램'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //내부 저장할 파일들 (주로 인증 토큰)
  static final storage = FlutterSecureStorage();
  dynamic userRefreshToken = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }
  _asyncMethod() async {
    //read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    //데이터가 없을때는 null을 반환
    userRefreshToken = await storage.read(key:'refresh_token');
    print('자동 로그인 시도');
    if (userRefreshToken != null) {
      //refresh하기
      var isRefreshed = await TokenManager().refreshAccessToken();
      if (isRefreshed){
        var accessToken = await storage.read(key:'access_token') ?? "";
        var userEmail = await storage.read(key:'userEmail') ?? "";
        print("accessToken refreshed in main.dart, 자동 로그인 완료");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // builder: (context) => UrlToSummary(Token: auth_token, user_email: email,),
            builder: (context) => Home( token: accessToken, userEmail: userEmail),
          ),
        );
      } else {
        print("refreshAessToken failed in main.dart init, login need!");
      }

    } else {
      //refresh토큰으로 refresh하기
      print("자동로그인 불가, 로그인이 필요합니다.");
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
        var user = jsonResponse["user"];
        var user_email = user["email"];
        var accessToken = jsonResponse["access_token"];
        var refreshToken = jsonResponse["refresh_token"];
        print("email: $user_email");
        print("accessToken: $accessToken");
        print("refreshToken: $refreshToken");

        print("on writting");
        //storage에 저장부분
        try{
          await storage.write(key: "access_token", value: accessToken);

        } catch (e) {
          print("storage.write error : $e");
        }

        await storage.write(key: "refresh_token", value: refreshToken);
        await storage.write(key: "user_email", value: user_email);
        print("is written");
        isLoggedIn = true;
        print("isloggedin  = true");

        if (isLoggedIn) {
          print("push to home");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              // builder: (context) => UrlToSummary(Token: auth_token, user_email: email,),
              builder: (context) => Home(token: accessToken,userEmail: user_email,),
            ),
          );
        }
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