import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neat/services/localStorageService.dart';
import 'package:neat/views/new_task_list.dart';
import 'package:neat/views/task_list.dart';

class AreaList extends StatefulWidget {
  final int? floor;
  final List checklistLength;
  final List areaData;
  const AreaList(
      {Key? key,
      this.checklistLength = const [],
      this.areaData = const [],
      this.floor})
      : super(key: key);

  @override
  _AreaListState createState() => _AreaListState();
}

class _AreaListState extends State<AreaList> {
  bool activateSendButton = false;
  List data = [];
  List floorData = [];
  List downloadUrl = [];
  List urls = [];
  bool isLoading = false;

  @override
  void initState() {
    print(widget.areaData);
    checkTaskData();
    super.initState();
  }

  void checkTaskData() {

    LocalStorageService.check("downloadUrls").then((value){
      if(value) {
        LocalStorageService.load("downloadUrls").then((thisValue){
          List downloadUrls = thisValue;

          downloadUrls.removeWhere((element) => element["floor"] != widget.floor);

          for(int i = 0; i < downloadUrls.length; i++) {
            urls.add(downloadUrls[i]["downloadUrl"]);
          }

          print("test: " + downloadUrl.toString());
        });
      }
    });

    LocalStorageService.check("taskData").then((value) async {
      if (value == true) {
        LocalStorageService.load("taskData").then((thisValue) async {
          floorData = thisValue;
          floorData.removeWhere((element) => element["floor"] != widget.floor);
          print("floor data" + floorData.toString());
          setState(() {});
          List taskData = thisValue;

          Map mappedData = {};

          for (int i = 0; i < widget.areaData.length; i++) {
            mappedData = taskData.firstWhere(
                (element) =>
                    element["floor"] == widget.floor &&
                    element["areaName"] == widget.areaData[i]["name"],
                orElse: () => {});

            if (mappedData["areaName"] == widget.areaData[i]["name"] &&
                mappedData["floor"] == widget.floor &&
                mappedData["checklist_data"] != null &&
                mappedData["checklist_data"].isNotEmpty) {
              data = mappedData["checklist_data"];
              print("berak: " + data.toString());
              setState(() {});
            }
            // else {
            //   print("all condition not met");
            //   for (int i = 0; i < checklistData.length; i++) {
            //     data.add({"index": i, "value": "false"});
            //   }
            //
            //   LocalStorageService.load("taskData").then((taskDataValue) async {
            //     List varDat = taskDataValue;
            //     varDat.add({
            //       "areaName": widget.areaName,
            //       "checklist_data": data,
            //       "floor": widget.floor
            //     });
            //
            //     print(varDat);
            //
            //     await LocalStorageService.save("taskData", varDat);
            //   });
            //
            //   setState(() {});
            // }
          }
        });
      }
      // else {
      //   print("no key found");
      //   for(var checkLngth in widget.checklistLength) {
      //     for (int i = 0; i < checkLngth; i++) {
      //       data.add({"index": i, "value": "false"});
      //     }
      //   }
      //
      //   await LocalStorageService.save("taskData", [
      //     {
      //       "areaName": widget.areaName[i]["name"],
      //       "checklist_data": data,
      //       "floor": widget.floor
      //     }
      //   ]);
      //   setState(() {});
      // }
    });

    // LocalStorageService.check("taskData").then((value) {
    //   if (value == true) {
    //     LocalStorageService.load("taskData").then((value) {
    //       for (int i = 0; i < value.length; i++) {
    //         print("area:" + value[i]["areaName"]);
    //         floorData = value;
    //         setState(() {
    //
    //         });
    //
    //         for (var area in widget.areaData) {
    //           if (value[i]["areaName"] == area["name"] && value[i]["floor"] == widget.floor) {
    //             print(value[i]);
    //             print("sukses");
    //             if (value[i]["areaName"] == area["name"] &&
    //                 value[i]["floor"] == widget.floor &&
    //                 value[i]["checklist_data"] != null &&
    //                 value[i]["checklist_data"].isNotEmpty) {
    //               data = value[i]["checklist_data"];
    //               print(data);
    //               setState(() {});
    //             } else {
    //               print("all condition not met");
    //               for (var checklistLngth in widget.checklistLength) {
    //                 for (int i = 0; i < checklistLngth; i++) {
    //                   data.add({"index": i, "value": "false"});
    //                 }
    //               }
    //               setState(() {});
    //             }
    //           }
    //         }
    //       }
    //     });
    //   } else {
    //     for (var checklistLngth in widget.checklistLength) {
    //       for (int i = 0; i < checklistLngth; i++) {
    //         data.add({"index": i, "value": "false"});
    //       }
    //     }
    //     setState(() {});
    //   }
    // });
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
                title: "Ruangan",
                body: widget.areaData.isEmpty
                    ? Center(
                        child: Text(
                          "Admin harus menambahkan data area",
                          style: TextStyle(fontSize: 15.sp),
                        ),
                      )
                    : Column(
                        children: [
                          Flexible(
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 14.h),
                              itemCount: widget.areaData.length,
                              itemBuilder: (context, i) {
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TaskList(
                                            areaName: widget.areaData[i]
                                                ["name"],
                                            checklistData: widget.areaData[i]
                                                    .containsKey("checklists")
                                                ? widget.areaData[i]
                                                    ["checklists"]
                                                : widget.areaData[i]
                                                    ["Checklists"],
                                            floor: widget.floor,
                                          ),
                                        ),
                                      ).then((value) {
                                        checkTaskData();
                                      });
                                    },
                                    child: kerjaanItemWidget(
                                        areaName: widget.areaData[i]["name"],
                                        index: i));
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.w, vertical: 20.h),
                            child: ElevatedButton(
                                onPressed: () async {
                                  isLoading = true;
                                  setState(() {});

                                  List areaDetail = [];

                                  if (floorData.isEmpty) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return const AlertDialog(
                                            title: Text(
                                              "Yang bener aja >:(",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            content: Text(
                                                "Minimal kerjain satu di setiap area"),
                                          );
                                        });

                                    return;
                                  }

                                  // var total = floorData.reduce((value, element){
                                  //   print(value);
                                  //   print(element);
                                  //
                                  //   // if(value > element) {
                                  //   //   return value;
                                  //   // } else {
                                  //   //   return element;
                                  //   // }
                                  //
                                  //   return 0;
                                  // });

                                  // print(total);

                                  for (int j = 0; j < floorData.length; j++) {
                                    Map areaMap = {
                                      "completed_task": {
                                        floorData[j]["areaName"]: {
                                          "done": floorData[j]["checklist_data"]
                                              .length,
                                          "total_task":
                                              widget.checklistLength[j],
                                        },
                                        "percentage": ((floorData[j]
                                        ["checklist_data"]
                                            .length /
                                            widget
                                                .checklistLength[j]) *
                                            100 as double)
                                            .floor()
                                      }
                                    };

                                    areaDetail.add(areaMap);

                                    print(areaDetail);
                                  }

                                  if(areaDetail.length < widget.checklistLength.length){
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return const AlertDialog(
                                            title: Text(
                                              "Yang bener aja >:(",
                                              style:
                                              TextStyle(color: Colors.red),
                                            ),
                                            content: Text(
                                                "Minimal kerjain satu di setiap area"),
                                          );
                                        });
                                  } else {
                                    List allPercent = [];
                                    for(int i = 0; i < areaDetail.length; i++){
                                      allPercent.add(areaDetail[i]["completed_task"]["percentage"]);
                                    }

                                    if(allPercent.contains(0)) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return const AlertDialog(
                                              title: Text(
                                                "Yang bener aja >:(",
                                                style:
                                                TextStyle(color: Colors.red),
                                              ),
                                              content: Text(
                                                  "Minimal kerjain satu di setiap area"),
                                            );
                                          });
                                    } else {
                                      prosesUpload(areaDetail);
                                    }
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
                                    Expanded(child: Container()),
                                    Text("Selesaikan Pekerjaan"),
                                    Expanded(child: Container()),
                                  ],
                                )),
                          ),
                        ],
                      ),
                height: 415),
          ),
        ]),
      ),
    );
  }

  void prosesUpload(List areaDetail) async {
    var workDataCol = FirebaseFirestore.instance.collection("work_data");

    workDataCol.add({
      "work_start_time": await LocalStorageService.load("work_start_time"),
      "work_finished_time": DateTime.now().toLocal(),
      "pic": await LocalStorageService.load("username"),
      "floor_cleaned": widget.floor,
      "area_detail": areaDetail,
      "proof_image": urls
    }).then((value) async {
      await LocalStorageService.delete("work_start_time");
      await LocalStorageService.delete("taskData");
      await LocalStorageService.delete("downloadUrls");

      isLoading = false;
      setState(() {});

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Selesai",
                style: TextStyle(color: Colors.green),
              ),
              content: Text("Lantai ${widget.floor} telah di bersihkan"),
            );
          });

      Future.delayed(Duration(seconds: 3), () {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    });
  }

  Widget kerjaanItemWidget({String areaName = "", int index = -1}) {
    // print(floorData[index]["checklist_data"].where((c) => floorData[index]["floor"] == widget.floor && c["value"] == "true"));
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
                "${floorData.isEmpty || !floorData.asMap().containsKey(index) ? 0 : floorData[index]["checklist_data"] == null ? 0 : floorData[index]["checklist_data"].length}/${widget.checklistLength[index]} selesai",
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
            activeColor:
                floorData.isEmpty || !floorData.asMap().containsKey(index)
                    ? Colors.grey
                    : floorData[index]["checklist_data"] == null
                        ? Colors.grey
                        : floorData[index]["areaName"] == areaName &&
                                floorData[index]["floor"] == widget.floor &&
                                floorData[index]["checklist_data"].length ==
                                    widget.checklistLength[index]
                            ? Colors.green
                            : Colors.grey,
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
                    Navigator.pop(context,);
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
}
