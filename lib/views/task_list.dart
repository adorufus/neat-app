import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neat/services/localStorageService.dart';

class TaskData {
  final String? taskName;
  final int? floorNumber;
  final String? imageUrl;

  TaskData({this.taskName, this.floorNumber, this.imageUrl});

  factory TaskData.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data();
    return TaskData(
        floorNumber: data?['floor_number'],
        imageUrl: data?['image_url'],
        taskName: data?['task_name']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'task_name': taskName,
      'floor_number': floorNumber,
      'image_url': imageUrl
    };
  }
}

class TaskListWidget extends StatefulWidget {
  final String? taskName;
  final String? areaName;
  final int? floor;
  final int? thisItemIndex;
  const TaskListWidget(
      {Key? key, this.taskName, this.floor, this.areaName, this.thisItemIndex})
      : super(key: key);

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

typedef OnItemAddedCallback = Function(Map<String, List> item);

class _TaskListWidgetState extends State<TaskListWidget> {
  bool isLoading = false;
  List checklistData = [];
  String proofImage = "";
  final ImagePicker _picker = ImagePicker();
  final storage = FirebaseStorage.instance;

  @override
  void initState() {
    // checklistData = widget.checklistData;
    // for (int i = 0; i < checklistData.length; i++) {
    //   proofImage.add({"task_name": checklistData[i], "image": null});
    // }

    print(proofImage);
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Container(
            height: ScreenUtil().screenHeight,
            width: ScreenUtil().screenWidth,
            child: card(
              title: widget.taskName!,
              body: Center(
                child: Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
                  width: ScreenUtil().screenWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            await _picker
                                .pickImage(source: ImageSource.camera)
                                .then((value) {
                              proofImage = value!.path;

                              print(proofImage);
                              setState(() {});
                            });
                          },
                          child: Container(
                            height: 720.h,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                image: proofImage.isNotEmpty
                                    ? DecorationImage(
                                        fit: BoxFit.fill,
                                        image: FileImage(
                                          File(proofImage),
                                        ),
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 4,
                                      color: Colors.black.withOpacity(.12))
                                ]),
                            child: proofImage.isNotEmpty
                                ? Container()
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 50.sp,
                                          color: Colors.grey,
                                        ),
                                        Text("Sentuh untuk mengambil foto"),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            isLoading = true;
                            setState(() {});

                            String pic =
                                await LocalStorageService.load("username");
                            if (proofImage.isNotEmpty) {
                              final taskDataCollection = FirebaseFirestore
                                  .instance
                                  .collection('task_data');
                              final imageRef = storage
                                  .ref()
                                  .child('image/${DateTime.now()}');

                              imageRef
                                  .putFile(File(proofImage))
                                  .then((snapshot) async {
                                LocalStorageService.check("downloadUrls")
                                    .then((value) async {
                                  if (value) {
                                    List downloadUrls =
                                        await LocalStorageService.load(
                                            "downloadUrls");
                                    downloadUrls.add({
                                      "area_name": widget.areaName,
                                      "downloadUrl":
                                          await snapshot.ref.getDownloadURL(),
                                      "floor": widget.floor
                                    });

                                    await LocalStorageService.save(
                                        "downloadUrls", downloadUrls);
                                  } else {
                                    List downloadUrls = [];
                                    downloadUrls.add({
                                      "area_name": widget.areaName,
                                      "downloadUrl":
                                          await snapshot.ref.getDownloadURL(),
                                      "floor": widget.floor
                                    });
                                    await LocalStorageService.save(
                                        "downloadUrls", downloadUrls);
                                  }
                                });

                                print(await LocalStorageService.load(
                                    "downloadUrls"));

                                taskDataCollection.add({
                                  "floor_number": widget.floor,
                                  "task_name": widget.taskName,
                                  "area_name": widget.areaName,
                                  "pic": pic,
                                  "created": DateTime.now(),
                                  "image_url":
                                      await snapshot.ref.getDownloadURL()
                                }).then((value) {
                                  isLoading = false;
                                  setState(() {});
                                  Navigator.pop(context, {
                                    "value": "true",
                                    "task_name": widget.taskName
                                  });
                                }).onError((error, stackTrace) {
                                  isLoading = false;
                                  setState(() {});
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Error nich"),
                                          content: Text(
                                              "Adding to collection error: " +
                                                  error.toString(),
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        );
                                      });
                                  print("Adding to collection error: " +
                                      error.toString());
                                });
                              }).onError((error, stackTrace) {
                                isLoading = false;
                                setState(() {});
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Error nich",
                                            style:
                                                TextStyle(color: Colors.red)),
                                        content: Text(
                                            "Adding to storage error: " +
                                                error.toString()),
                                      );
                                    });
                                print(error);
                              });
                            } else {
                              isLoading = false;
                              setState(() {});
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        "Error nich",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      content: Text("Foto dulu dong mas :("),
                                    );
                                  });
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => Color(0xff219653))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back),
                              Expanded(child: Container()),
                              Text("Kirim & Kembali"),
                              Expanded(child: Container()),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          isLoading
              ? Container(
                  height: ScreenUtil().screenHeight,
                  width: ScreenUtil().screenWidth,
                  color: Colors.white.withOpacity(.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container()
        ]),
      ),
    );
  }

  Widget card({String title = "", Widget? body, double height = 0.0}) {
    return Container(
      height: height.h,
      clipBehavior: Clip.antiAlias,
      width: ScreenUtil().screenWidth,
      decoration: BoxDecoration(color: Colors.white,
          // borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(blurRadius: 4, color: Colors.black.withOpacity(.12))
          ]),
      child: Column(
        children: [
          Container(
            height: 56.h,
            width: ScreenUtil().screenWidth,
            padding: EdgeInsets.only(left: 19.w, top: 17.h, bottom: 17.h),
            color: Color(0xffDFDADA),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 25.sp,
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.sp,
                      color: Color(0xff4F4F4F),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Flexible(child: body ?? Container())
        ],
      ),
    );
  }

  // void getTaskList() async {
  //   await RestApiServices.getChecklists(widget.areaId).then((response) {
  //     if (response.runtimeType == Response) {
  //       response = response as Response;
  //       print(response.data);
  //
  //       if (response.statusCode == 200) {
  //         isLoading = false;
  //         checklistData = response.data["data"];
  //         print(checklistData);
  //         setState(() {});
  //       } else if (response.statusCode == 404) {
  //         isLoading = false;
  //         setState(() {});
  //         print("status code ${response.statusCode}");
  //         print(response.data['message']);
  //       } else {
  //         isLoading = false;
  //         setState(() {});
  //         print("status code ${response.statusCode}");
  //         print(response.data['error']);
  //       }
  //     } else {
  //       isLoading = false;
  //       setState(() {});
  //       print(response['error']);
  //     }
  //   });
  // }
}
