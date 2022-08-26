import 'package:dio/dio.dart';
import 'package:neat/config.dart';
import 'package:neat/services/localStorageService.dart';

class RestApiServices {
  static Future<dynamic> login({String? username, String? password}) async {
    try {
      return dio.post("auth/login",
          data: {"username": username, "password": password});
    } on DioError catch (e) {
      print(e.message);
      print(e.response ?? "");
      return {"error": e.message};
    }
  }

  // options: Options(headers: {"Authorization": "Bearer $token"})

  static Future<dynamic> getFloor() async {
    String token = await LocalStorageService.load("token");
    try {
      return dio.get(
        "neat/floor/all",
      );
    } on DioError catch (e) {
      print(e.message);
      print(e.response ?? "");
      return {"error": e.response ?? e.message};
    }
  }

  static Future<dynamic> getArea(String floorId) async {
    String token = await LocalStorageService.load("token");
    try {
      return dio.get(
        "neat/areas?floor_id=$floorId",
      );
    } on DioError catch (e) {
      print(e.message);
      print(e.response ?? "");
      return {"error": e.response ?? e.message};
    }
  }
  
  static Future<dynamic> getChecklists(String areaId) async {
    try {
      return dio.get("neat/checklists?area_id=$areaId");
    } on DioError catch (e) {
      print(e.message);
      print(e.response ?? "");
      return {"error": e.response ?? e.message};
    }
  }
}
