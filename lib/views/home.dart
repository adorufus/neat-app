import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neat/services/localStorageService.dart';
import 'package:neat/services/restApiServices.dart';
import 'package:neat/utils/uiUtils.dart';
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

  @override
  void initState() {
    getUsername();
    getData();
    super.initState();
  }

  void getUsername() async {
    username = await LocalStorageService.load("username");
    setState(() {});
  }

  void getData() async {
    getFloor().then((value) {
      isLoading = false;
      setState(() {});
    });
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
                      body: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: floorData.asMap().entries.map((e) {
                            return Flexible(
                              child: Row(
                                children: [
                                  Radio(
                                      value: floorData[e.key]["floor"] as int,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity(
                                          vertical:
                                              VisualDensity.minimumDensity),
                                      groupValue: rValue,
                                      onChanged: (int? value) async {
                                        print(value);
                                        rValue = value ?? -1;
                                        setState(() {});
                                        await getArea(floorData[e.key]["_id"]);
                                      }),
                                  Text(
                                    "Lantai ${floorData[e.key]["floor"]}",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            );
                          }).toList()
                          // [
                          //   // Flexible(
                          //   //   child: SizedBox(
                          //   //     height: 22.h,
                          //   //   ),
                          //   // ),
                          //   // Flexible(
                          //   //   child: SizedBox(
                          //   //     height: 23.h,
                          //   //   ),
                          //   // ),
                          //   // Flexible(
                          //   //   child: SizedBox(
                          //   //     height: 23.h,
                          //   //   ),
                          //   // ),
                          //   // Flexible(
                          //   //   child: Row(
                          //   //     children: [
                          //   //       Radio(
                          //   //           value: 2,
                          //   //           materialTapTargetSize:
                          //   //               MaterialTapTargetSize.shrinkWrap,
                          //   //           visualDensity: VisualDensity(
                          //   //               vertical: VisualDensity.minimumDensity),
                          //   //           groupValue: rValue,
                          //   //           onChanged: (int? value) {
                          //   //             rValue = value ?? -1;
                          //   //             setState(() {});
                          //   //           }),
                          //   //       Text(
                          //   //         "Lantai 3",
                          //   //         style: TextStyle(
                          //   //             fontSize: 16.sp,
                          //   //             fontWeight: FontWeight.bold),
                          //   //       )
                          //   //     ],
                          //   //   ),
                          //   // ),
                          //   // Flexible(
                          //   //   child: SizedBox(
                          //   //     height: 22.h,
                          //   //   ),
                          //   // ),
                          // ],
                          ),
                      height: 209),
                  SizedBox(
                    height: 25.h,
                  ),
                  card(
                      title: "Kerjaan",
                      body: areaData.isEmpty
                          ? Center(
                              child: Text(
                                "Admin harus menambahkan data area",
                                style: TextStyle(fontSize: 15.sp),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 14.h),
                              itemCount: areaData.length,
                              itemBuilder: (context, i) {
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TaskListWidget(
                                                    areaId: areaData[i]["_id"],
                                                  )));
                                    },
                                    child: kerjaanItemWidget(
                                        areaName: areaData[i]["area_name"],
                                        index: i));
                              },
                            ),
                      height: 415)
                ],
              ),
            ),
            isLoading ? UiUtils.loading(context) : Container()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.send),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      ),
    );
  }

  Widget kerjaanItemWidget({String areaName = "", int index = -1}) {
    return Container(
      height: 61.h,
      width: ScreenUtil().screenWidth,
      padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 8.h),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r), color: Color(0xffEEEDED)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                areaName,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5.61.sp,
              ),
              Text(
                "0/${checklists[index]} selesai",
                style: TextStyle(fontSize: 14.sp),
              )
            ],
          ),
          Expanded(child: Container()),
          Checkbox(
            value: true,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity:
                VisualDensity(vertical: VisualDensity.minimumDensity),
            onChanged: (val) {},
            activeColor: Colors.grey,
          )
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
