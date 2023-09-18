import 'package:flutter/material.dart';
import 'package:bdj_application/main.dart';
import 'package:flutter/material.dart';
import 'package:bdj_application/main.dart';


void logOut(BuildContext context){
  Navigator.of(context).pop();
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => MyApp(), //start page로
    ),
  );
}


Future<void> showLogoutDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          '로그아웃 확인',
          style: TextStyle(color: Colors.white60),
        ),
        content: Text(
          '로그아웃하시겠습니까?',
          style: TextStyle(color: Colors.white60),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Yes',
              style: TextStyle(color: Colors.white60),
            ),
            onPressed: () {
              logOut(context); // Call the logOut function
            },
          ),
          TextButton(
            child: Text(
              'No',
              style: TextStyle(color: Colors.white60),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without logging out
            },
          ),
          // Add other buttons as needed
        ],
      );
    },
  );
}
