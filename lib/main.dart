import 'package:flutter/material.dart';
import 'package:sample1app/screen/login_screen.dart';
import 'package:sample1app/screen/home_screen.dart';
import 'package:sample1app/screen/tweet_screen.dart';

void main() => runApp(SampleApp());

class SampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: LoginScreen.id,
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        TweetScreen.id: (context) => TweetScreen(),
      }
    );
  }
}

