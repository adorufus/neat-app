import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neat/services/localStorageService.dart';
import 'package:neat/services/restApiServices.dart';
import 'package:collection/collection.dart';

class TaskListWidget extends StatefulWidget {
  final String areaId;
  const TaskListWidget({Key? key, this.areaId = ""}) : super(key: key);

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  bool isLoading = false;
  List checklistData = [];
  List<XFile> proofImage = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    getTaskList();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 43.h, horizontal: 42.w),
            children: [
              Column(
                children: checklistData.asMap().entries.map((e){
                  return Container(
                    height: 246.h,
                    margin: EdgeInsets.only(bottom: 19.h),
                    width: ScreenUtil().screenWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(checklistData[e.key]["task_name"]),
                        SizedBox(height: 9.h,),
                        Flexible(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              await _picker.pickImage(source: ImageSource.camera).then((value){
                                proofImage.add(value!);

                                print(proofImage.length);
                                setState(() {

                                });
                              });
                            },
                            child: Container(
                              height: 209.h,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                  image: proofImage.isNotEmpty && proofImage.asMap().containsKey(e.key) ? DecorationImage(
                                    image: FileImage(
                                      File(proofImage[e.key].path)
                                    )
                                  ) : null,
                                  boxShadow: [
                                    BoxShadow(blurRadius: 4, color: Colors.black.withOpacity(.12))
                                  ]
                              ),
                              child: proofImage.isNotEmpty && proofImage.length == e.key + 1 ? Container() : Center(
                                child: Icon(Icons.camera_alt, size: 50.sp, color: Colors.grey,),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  );
                }).toList(),
              ),
              ElevatedButton(onPressed: (){
                proofImage.map((e){
                  LocalStorageService.save("proof-data", {
                    "areaId": widget.areaId,
                    "images": e.path
                  });
                });
                Navigator.pop(context);
              },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) => Color(0xff219653))
                  ),child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Icon(Icons.arrow_back), Expanded(child: Container()), Text("Simpan & Kembali"), Expanded(child: Container()),],
              ))
            ],
          ),
        ),
      ),
    );
  }

  void getTaskList() async {
    await RestApiServices.getChecklists(widget.areaId).then((response) {
      if (response.runtimeType == Response) {
        response = response as Response;
        print(response.data);

        if (response.statusCode == 200) {
          isLoading = false;
          checklistData = response.data["data"];
          print(checklistData);
          setState(() {});
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
  }
}
