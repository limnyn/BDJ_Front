import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bdj_application/home.dart';

class UserRegister extends StatefulWidget {
  @override
  _UserRegisterState createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String auth_token = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController1 = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();
  bool isLoggedIn = false;

  void _sendRequest() async {
    var url = Uri.http(dotenv.get('API_IP'), '/registration/');

    String email = emailController.text;
    String password1 = passwordController1.text;
    String password2 = passwordController2.text;

    try {
      var response = await http.post(url, body: {
        "email": email,
        "password1": password1,
        "password2": password2,
      });

      if (response.statusCode == 201) {
        var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        var accessToken = jsonResponse["access_token"];

        setState(() {
          auth_token = accessToken;
          isLoggedIn = true;
        });
        if (isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(Token: auth_token, user_email: email,),
            ),
          );
        }
      } else {
        final jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
        final emailError = jsonResponse["email"];
        final passwordError = jsonResponse["password1"];
        final non_field_errors = jsonResponse["non_field_errors"];

        final snackBar = SnackBar(
          content: Text(emailError != null ? emailError[0] : passwordError != null ? passwordError[0] : non_field_errors[0]),

        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar); // 수정된 부분
      }
    } catch (error) {
      final snackBar = SnackBar(
        content: Text("$url HTTP 요청 실패: $error"),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar); // 수정된 부분
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[900],
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign In',
              style: TextStyle(fontSize: 20, color: Colors.grey[500]),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              width: double.infinity,
              height: 80,
              color: Colors.grey[830],
              child: TextField(
                controller: emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              width: double.infinity,
              height: 80,
              color: Colors.grey[830],
              child: TextField(
                obscureText: true,
                controller: passwordController1,
                onSubmitted: (_) {
                  _sendRequest();
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Password1",
                  labelStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              width: double.infinity,
              height: 80,
              color: Colors.grey[830],
              child: TextField(
                obscureText: true,
                controller: passwordController2,
                onSubmitted: (_) {
                  _sendRequest();
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Password2",
                  labelStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _sendRequest,
              child: Text('sign up', style: TextStyle(color: Colors.grey)),
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.grey.shade800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
