//menubar.dart
import 'package:flutter/material.dart';
import 'package:bdj_application/login.dart';
import 'package:bdj_application/logout.dart';
import 'package:bdj_application/my_summaries.dart';
import 'package:bdj_application/home.dart';
import 'package:bdj_application/url_summary.dart';
import 'package:bdj_application/check_audio.dart' as audioPage;


class MenuDrawer extends StatelessWidget {
  final logOut = Logout();
  final String pageName;
  final bool isLoggedIn;
  MenuDrawer ({Key? key, required this.pageName, required this.isLoggedIn}) : super(key: key);




  @override
  Widget build(BuildContext context){
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: ListView(
        padding: EdgeInsets.zero,
        children:[
          DrawerHeader(

            child:Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('글 간 추', style:TextStyle(color: Colors.grey)),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (isLoggedIn)
                          TextButton(onPressed: () {
                            if (pageName!= "mySummaries"){
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => MySummaries(isLoggedIn: true),
                                  ));
                              }
                            }, child: Text('My Summaries', style:TextStyle(color: pageName == "mySummaries" ? Colors.grey : Colors.white24)),
                          ),
                      if (isLoggedIn)
                        TextButton(
                          onPressed:() {
                            logOut.showLogoutDialog(context);
                          },
                          child: Text('LogOut', style: TextStyle(color: Colors.grey)),
                        ),
                      if (!isLoggedIn)
                        TextButton(
                          onPressed:() {
                            goToLogin(context);
                          },
                          child: Text('Login', style: TextStyle(color: Colors.grey)),
                        ),
                    ],
                  ),
                ),

              ],
            ),
            decoration: BoxDecoration(
              color: Colors.white10,
            ),
          ),
          ListTile(
            title : Text('Latest Summary', style: TextStyle(color: pageName == "home" ? Colors.grey : Colors.white24),),
            onTap: () {
              if(pageName != 'home'){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(isLoggedIn:isLoggedIn),
                  ),
                );
              }
            },
          ),
          ListTile(
            title : Text('Yotube Summary', style: TextStyle(color: pageName == "youtube" ? Colors.grey : Colors.white24),),
            onTap: (){
              if(pageName != "youtube"){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UrlToSummary(isLoggedIn:isLoggedIn),
                  ),
                );
              }
            },
          ),
          ListTile(
            title : Text('Audio Summary', style: TextStyle(color: pageName == "audio" ? Colors.grey : Colors.white24),),
            onTap: (){
              if (pageName != "audio"){
                audioPage.goToAudioSummary(context, isLoggedIn);
              }
            },
          ),
        ],
      ),
    );
  }
}