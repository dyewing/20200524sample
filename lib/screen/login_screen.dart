import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sample1app/screen/home_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:sample1app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  final _auth = FirebaseAuth.instance;
  bool showSpinner = true;
  String email;
  String password;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);
    controller.forward();
    controller.addListener(() {
      setState(() {});
      print(animation.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: Scaffold(
        backgroundColor: Colors.greenAccent,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: 150.0,
                child: Image.asset('images/icon.png'),
              ),
              Center(
                child: TypewriterAnimatedTextKit(
                  text: ['Sample-1'],
                  textStyle: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your email')),
              SizedBox(
                height: 10.0,
              ),
              TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your password')),
              SizedBox(
                height: 25.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Material(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                  elevation: 5.0,
                  child: MaterialButton(
                    onPressed: () async {
                      showSpinner = true;
                      try {
//                        final newUser = await _auth.signInWithEmailAndPassword(
                          final newUser = await _auth.createUserWithEmailAndPassword(
                            email: email, password: password);
                        if (newUser != null) {
                          Navigator.pushNamed(context, HomeScreen.id);
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                    minWidth: 200.0,
                    height: 50.0,
                    child: Text('Log In'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      inAsyncCall: false,
    );
  }
}
