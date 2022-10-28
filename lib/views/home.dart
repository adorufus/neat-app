import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neat/services/localStorageService.dart';
import 'package:neat/services/restApiServices.dart';
import 'package:neat/utils/uiUtils.dart';
import 'package:neat/views/area_list.dart';
import 'package:neat/views/task_list.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  int rValue = 0;
  int selectedValue = -1;
  String username = "";
  bool isLoading = false;

  List floorData = [];
  List areaData = [];
  List checklists = [];

  CollectionReference floorReference =
      FirebaseFirestore.instance.collection('floors');

  @override
  void initState() {
    getUsername();
    // getData();
    super.initState();
  }

  void getUsername() async {
    username = await LocalStorageService.load("username");
    setState(() {});
  }

  void getData() async {
    // getFloor().then((value) {
    //   isLoading = false;
    //   setState(() {});
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: ScreenUtil().screenHeight,
              width: ScreenUtil().screenWidth,
              padding: EdgeInsets.symmetric(horizontal: 42.w, vertical: 54.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: Color(0xff263238),
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: "Hi", style: TextStyle(fontSize: 48.sp)),
                        TextSpan(
                            text: " $username",
                            style: TextStyle(fontSize: 34.sp)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 69.h,
                  ),
                  card(
                      title: "Pilih Lantai",
                      body: FutureBuilder<QuerySnapshot>(
                          future: floorReference
                              .orderBy("floor", descending: false)
                              .get(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                var data = snapshot.data;

                                return ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 14.h),
                                  itemCount: data!.docs.length,
                                  itemBuilder: (context, i) {
                                    print(data.docs[i]["floor"]);
                                    return GestureDetector(
                                      onTap: () {
                                        areaData = data.docs[i]["areas"];
                                        checklists = data.docs[i]["checklists_length"];
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AreaList(
                                                  areaData: areaData,
                                                  checklistLength: checklists,
                                                  floor: data.docs[i]["floor"],
                                                ),
                                          ),
                                        );
                                      },
                                      child: lantaiItemWidget(
                                        data.docs,
                                          floorName: "Lantai " +
                                              data.docs[i]["floor"].toString(),
                                          index: i),
                                    );
                                  },
                                );
                              } else {
                                return Center(
                                  child: Text(
                                    "Admin harus menambahkan data lantai",
                                    style: TextStyle(fontSize: 15.sp),
                                  ),
                                );
                              }
                            } else {
                              return Container();
                            }
                          }),
                      height: 400.h),
                ],
              ),
            ),
            isLoading ? UiUtils.loading(context) : Container()
          ],
        ),
      ),
    );
  }

  Widget lantaiItemWidget(List data, {String floorName = "", int index = -1}) {
    return Container(
      height: 61.h,
      width: ScreenUtil().screenWidth,
      padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 8.h),
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r), color: Color(0xffEEEDED)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                floorName,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Text("0/${data[index]["areas"].length} area selesai", style: TextStyle(fontSize: 14.sp),)
            ],
          ),
          const Expanded(child: SizedBox()),
          const Icon(Icons.arrow_forward_ios_rounded, size: 15,)
        ],
      ),
    );
  }

  Widget card({String title = "", Widget? body, double height = 0.0}) {
    return Container(
      height: height.h,
      clipBehavior: Clip.antiAlias,
      width: ScreenUtil().screenWidth,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
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
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 20.sp,
                  color: Color(0xff4F4F4F),
                  fontWeight: FontWeight.bold),
            ),
          ),
          Flexible(child: body ?? Container())
        ],
      ),
    );
  }

  Future getFloor() async {
    isLoading = true;
    setState(() {});
    await RestApiServices.getFloor().then((response) {
      if (response.runtimeType == Response) {
        response = response as Response;

        if (response.statusCode == 200) {
          floorData = response.data["data"];
          setState(() {});
        } else if (response.statusCode == 404) {
          print("status code ${response.statusCode}");
          print(response.data['message']);
        } else {
          print("status code ${response.statusCode}");
          print(response.data['error']);
        }
      } else {
        print(response['error']);
      }
    });
  }

  Future getArea(String floorId) async {
    isLoading = true;
    setState(() {});
    await RestApiServices.getArea(floorId).then((response) {
      if (response.runtimeType == Response) {
        response = response as Response;
        print(response.data);

        if (response.statusCode == 200) {
          isLoading = false;
          areaData = response.data["data"];
          checklists = response.data["checklist_length"];
          print(areaData);
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
