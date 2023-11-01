//lib/main.dart
import 'package:flutter/material.dart';
import 'package:bdj_application/home.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    userRefreshToken = await storage.read(key: 'refresh_token');
    print('자동 로그인 시도');
    bool isRefreshed;
    if (userRefreshToken != null) {
      isRefreshed = await TokenManager().refreshAccessToken();
    } else {
      isRefreshed = false;
    }

    // 바로 다음 앱으로 넘어갑니다.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(isLoggedIn: isRefreshed),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}

