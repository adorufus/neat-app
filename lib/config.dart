import 'package:dio/dio.dart';

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