import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neat/services/localStorageService.dart';
import 'package:neat/services/restApiServices.dart';
import 'package:neat/utils/uiUtils.dart';
import 'package:neat/views/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(512, 1024),
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const MyHomePage(),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: ScreenUtil().screenHeight,
      width: ScreenUtil().screenWidth,
      padding: EdgeInsets.symmetric(horizontal: 89.w),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      color: Color(0xff263238), fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: "Neat", style: TextStyle(fontSize: 96.sp)),
                    TextSpan(text: "app", style: TextStyle(fontSize: 34.sp)),
                  ],
                ),
              ),
              SizedBox(
                height: 77.h,
              ),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "e.g fadhilkeren22",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2.h, horizontal: 12.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    )),
              ),
              SizedBox(
                height: 44.h,
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Password",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2.h, horizontal: 12.w),
                    hintText: "Setidaknya ada 8 karakter",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    )),
              ),
              SizedBox(
                height: 46.h,
              ),
              Container(
                width: ScreenUtil().screenWidth,
                height: 63.h,
                child: OutlinedButton(
                  onPressed: () {
                    isLoading = true;
                    setState(() {});
                    RestApiServices.login(
                            username: usernameController.text,
                            password: passwordController.text)
                        .then((response) {
                      if (response.runtimeType == Response) {
                        response = response as Response;
                        if (response.statusCode == 200) {
                          LocalStorageService.save("username", usernameController.text);
                          LocalStorageService.save(
                                  "token", response.data["token"])
                              .then((value) {
                            if (value == true) {
                              isLoading = false;
                              setState(() {});
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeWidget()));
                            }
                          });
                        } else if (response.statusCode == 404) {
                          isLoading = false;
                          setState(() {});
                          print("status code ${response.statusCode}");
                          print(response.data['message']);
                        } else {
                          isLoading = false;
                          setState(() {});
                          print("status code ${response.statusCode}");
                          print(response.data['error']);
                        }
                      } else {
                        isLoading = false;
                        setState(() {});
                        print(response['error']);
                      }
                    });
                  },
                  style: ButtonStyle(),
                  child: Text(
                    "Masuk",
                    style: TextStyle(color: Color(0xff0E4DA4)),
                  ),
                ),
              ),
            ],
          ),
          isLoading
              ? UiUtils.loading(context, loadingText: "Logging In...")
              : Container()
        ],
      ),
    ));
  }
}
