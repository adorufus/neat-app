import 'package:glutton/glutton.dart';

class LocalStorageService {
  static Future<bool> save  (String key, dynamic value) async {
    try {
      return await Glutton.eat(key, value);
    } on GluttonException catch (e) {
      print(e);
      return false;
    }
  }

  static Future<dynamic> load (String key) async {
    try {
      return await Glutton.vomit(key);
    } on GluttonException catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> delete (String key) async {
    try {
      return await Glutton.digest(key);
    } on GluttonException catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> deleteAll () async {
    try {
      return await Glutton.flush();
    } on GluttonException catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> check (String key) async {
    try {
      return await Glutton.have(key);
    } on GluttonException catch (e) {
      print(e);
      return false;
    }
  }
}