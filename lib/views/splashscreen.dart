import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neat/config.dart';
import 'package:neat/main.dart';
import 'package:neat/services/localStorageService.dart';

import 'home.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  _SplashScreenViewState createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if(user == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
      } else {
        setWorkStartTime();
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomeWidget()));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
      height: ScreenUtil().screenHeight,
      width: ScreenUtil().screenWidth,
      child: Center(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
                color: Color(0xff263238), fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: "Neat", style: TextStyle(fontSize: 96.sp)),
              TextSpan(text: "app", style: TextStyle(fontSize: 34.sp)),
            ],
          ),
        ),
      ),
    ));
  }
}
