import 'package:dio/dio.dart';
import 'package:neat/services/localStorageService.dart';

String baseUrl = "http://192.168.1.92:8000/api/v1/";

var dio = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    followRedirects: false,
    validateStatus: (status) {
      return status! <= 500;
    }
  )
);

void setWorkStartTime() async {
  await LocalStorageService.check("work_start_time").then((value) {
    if(value == false) {
      LocalStorageService.save("work_start_time", DateTime.now());
    }
  });
}