import 'package:cloud_firestore/cloud_firestore.dart';

class Database {

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<void> post({required String reference, required String doc, required dynamic data}) async {
    return await firestore.collection(reference).doc(doc).set(data).catchError((error) => print(error));
  }

}