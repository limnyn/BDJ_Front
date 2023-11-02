import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bdj_application/main.dart';

class Logout {
  static final storage = FlutterSecureStorage();

  void logOut(BuildContext context) async {
    await storage.deleteAll();
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyApp(), // Start page
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
            'Logout Confirmation',
            style: TextStyle(color: Colors.white60),
          ),
          content: Text(
            'Are you sure you want to log out?',
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
}