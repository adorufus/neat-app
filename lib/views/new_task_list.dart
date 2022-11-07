import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neat/services/localStorageService.dart';
import 'package:neat/utils/pretty_print.dart';
import 'package:neat/views/task_list.dart';

class TaskList extends StatefulWidget {
  final List checklistData;
  final String? areaName;
  final int? floor;
  const TaskList(
      {Key? key, this.checklistData = const [], this.areaName, this.floor})
      : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List checklistData = [];
  List data = [];
  Map<String, dynamic> savedData = {};

  @override
  void initState() {
    checklistData = widget.checklistData;
    print(widget.areaName);

    LocalStorageService.check("taskData").then((value) async {
      if (value == true) {
        LocalStorageService.load("taskData").then((value) async {
          PrettyPrint(value);
          List taskData = value;

          Map mappedData = {};

          mappedData = taskData.firstWhere(
              (element) =>
                  element["floor"] == widget.floor &&
                  element["areaName"] == widget.areaName,
              orElse: () => {});

          if (mappedData["areaName"] == widget.areaName &&
              mappedData["floor"] == widget.floor &&
              mappedData["checklist_data"] != null &&
              mappedData["checklist_data"].isNotEmpty) {
            data = mappedData["checklist_data"];
            print("berak: " + data.toString());
            setState(() {});
          } else {
            print("all condition not met");
            for (int i = 0; i < checklistData.length; i++) {
              data.add({"task_name": checklistData[i], "value": "false"});
            }

            LocalStorageService.load("taskData").then((taskDataValue) async {
              List varDat = taskDataValue;
              if ((varDat.singleWhere(
                      (element) => element["areaName"] == widget.areaName,
                      orElse: () => null)) !=
                  null) {
                    var singleData = varDat.firstWhere(
              (element) =>
                  element["floor"] == widget.floor &&
                  element["areaName"] == widget.areaName,
              orElse: () => {});

                      singleData["checklist_data"] = data;
                PrettyPrint(singleData);
                for(int i = 0; i < varDat.length; i++){
                  if(varDat[i]["areaName"] == singleData["areaName"]) {
                    varDat[i]["checklist_data"] = data;
                  }
                }
                // varDat[0]["checklist_data"] = data;
              } else {
                varDat.add({
                  "areaName": widget.areaName,
                  "checklist_data": data,
                  "floor": widget.floor
                });
              }

              PrettyPrint(varDat);

              await LocalStorageService.save("taskData", varDat);
            });

            setState(() {});
          }
        });
      } else {
        print("no key found");
        for (int i = 0; i < checklistData.length; i++) {
          data.add({"task_name": checklistData[i], "value": "false"});
        }

        await LocalStorageService.save("taskData", [
          {
            "areaName": widget.areaName,
            "checklist_data": data,
            "floor": widget.floor
          }
        ]);
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          child: card(
              title: "Tugas",
              body: checklistData.isEmpty
                  ? Center(
                      child: Text(
                        "Admin harus menambahkan data tugas",
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 14.h),
                      itemCount: checklistData.length,
                      itemBuilder: (context, i) {
                        return GestureDetector(
                            onTap: () {
                              if (data[i]["value"] != "true") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskListWidget(
                                        taskName: checklistData[i],
                                        floor: widget.floor,
                                        areaName: widget.areaName,
                                        thisItemIndex: i),
                                  ),
                                ).then((value) async {
                                  if (value != null) {
                                    data[i] = value;
                                    setState(() {});

                                    print('current index: ' + i.toString());

                                    savedData = {
                                      "areaName": widget.areaName,
                                      "checklist_data": data,
                                      "floor": widget.floor
                                    };

                                    LocalStorageService.check("taskData")
                                        .then((value) {
                                      if (value) {
                                        LocalStorageService.load("taskData")
                                            .then((taskData) async {
                                          List dat0 = taskData;
                                          for (int i = 0;
                                              i < dat0.length;
                                              i++) {
                                            if (dat0[i]
                                                    .containsKey("areaName") &&
                                                dat0[i].containsKey("floor") &&
                                                dat0[i]["areaName"] ==
                                                    widget.areaName &&
                                                dat0[i]["floor"] ==
                                                    widget.floor) {
                                              dat0[i] = savedData;

                                              await LocalStorageService.save(
                                                  "taskData", dat0);
                                              print(await LocalStorageService
                                                  .load("taskData"));
                                            }
                                          }
                                        });
                                      }
                                    });

                                    print(data);
                                  }
                                });
                              }
                            },
                            child: kerjaanItemWidget(
                                areaName: checklistData[i], index: i));
                      },
                    ),
              height: 415),
        ),
      ),
    );
  }

  Widget kerjaanItemWidget({String areaName = "", int index = -1}) {
    print(checklistData[index]);
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
          Container(
            width: 350.w,
            child: Text(
              areaName,
              overflow: TextOverflow.ellipsis,
              textWidthBasis: TextWidthBasis.parent,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  decoration: data.isEmpty
                      ? TextDecoration.none
                      : data[index]["value"] == "false"
                          ? TextDecoration.none
                          : TextDecoration.lineThrough),
            ),
          ),
          Expanded(child: Container()),
          Checkbox(
            value: true,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity:
                VisualDensity(vertical: VisualDensity.minimumDensity),
            onChanged: (val) {},
            activeColor: data.isEmpty
                ? Colors.grey
                : data[index]["value"] == "true"
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
                    Navigator.pop(context, savedData);
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
