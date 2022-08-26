import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';

class UiUtils {
  static Widget loading(BuildContext context, {String loadingText = ""}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white.withOpacity(.5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10.h,),
              Text(loadingText, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),)
            ],
          ),
        ),
      ),
    );
  }
}