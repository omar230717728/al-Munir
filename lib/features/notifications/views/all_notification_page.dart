import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:al_munir/core/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:al_munir/core/hive_helper.dart';
import 'package:al_munir/core/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as notificationPlugin;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List periods = [
    {"index": 0, "name": "15 ${"minute".tr()}", "minutes": 15},
    {"index": 1, "name": "20 ${"minute".tr()}", "minutes": 20},
    {"index": 2, "name": "25 ${"minute".tr()}", "minutes": 25},
    {"index": 3, "name": "30 ${"minute".tr()}", "minutes": 30},
    {"index": 4, "name": "45 ${"minute".tr()}", "minutes": 45},
    {"index": 5, "name": "hour".tr(), "minutes": 60},
    {"index": 6, "name": "1.5 ${"hour".tr()}", "minutes": 90},
    {"index": 7, "name": "2 ${"hour".tr()}", "minutes": 120},
    {"index": 8, "name": "3 ${"hour".tr()}", "minutes": 180}
  ];
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: getValue("darkMode")
                  ? [darkModeSecondaryColor, darkModeSecondaryColor]
                  : [primaryColor, const Color(0xff5D4037)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xffe0cb8a)),
        title: Text(
          "notifications".tr(),
          style: TextStyle(
            color: const Color(0xffe0cb8a),
            fontSize: 20.sp,
            fontFamily: "cairo",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color:
            getValue("darkMode") ? quranPagesColorDark : quranPagesColorLight,
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              child: Card(
                elevation: .8,
                color: getValue("darkMode")
                    ? darkModeSecondaryColor
                    : Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),

                      Padding(
                        padding: EdgeInsets.only(left: 3.0.w, right: 14.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // const SizedBox(
                            //   width: 10,
                            // ),
                            CupertinoSwitch(
                                // overrides the default green color of the track
                                activeColor: blueColor,
                                // color of the round icon, which moves from right to left
                                thumbColor: Colors.white,
                                // when the switch is off
                                trackColor: Colors.grey,
                                // boolean variable value
                                value: getValue("shouldShowSallyNotification"),
                                // changes the state of the switch
                                onChanged: (value) async {
                                  updateValue(
                                      "shouldShowSallyNotification", value);
                                  if (value == true) {
                                    Workmanager().registerOneOffTask(
                                        "sallahEnable", "sallahEnable");
                                    // Instant feedback
                                    flutterLocalNotificationsPlugin.show(
                                        3,
                                        "صلِّ على النبي ﷺ",
                                        "",
                                        const notificationPlugin
                                            .NotificationDetails(
                                            android: notificationPlugin
                                                .AndroidNotificationDetails(
                                                    "channelId3", "Sally",
                                                    importance:
                                                        notificationPlugin
                                                            .Importance.max,
                                                    priority: notificationPlugin
                                                        .Priority.high,
                                                    groupKey: "sallah")));
                                  } else {
                                    Workmanager().registerOneOffTask(
                                        "sallahDisable", "sallahDisable");
                                    flutterLocalNotificationsPlugin.cancel(3);
                                  }

                                  setState(() {});
                                }),

                            Row(
                              children: [
                                Text(
                                  "${"Muhammed Notification".tr()} ﷺ",
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      color: getValue("darkMode")
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'cairo'),
                                ),
                                SizedBox(
                                  width: 5.w,
                                ),
                                CircleAvatar(
                                  radius: 5,
                                  backgroundColor:
                                      getValue("shouldShowSallyNotification")
                                          ? Colors.green
                                          : Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0.w),
                        child: Text(
                          "sallahNotificationDetails".tr(),
                          softWrap: true,
                          style: TextStyle(
                            color: getValue("darkMode")
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // You can add more properties from the Reciter class here
                      // For example:
                      // Text('Other Property: ${reciter.otherProperty}'),
                      // ...
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              child: Card(
                elevation: .8,
                color: getValue("darkMode")
                    ? darkModeSecondaryColor
                    : Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
/**/

                      Padding(
                        padding: EdgeInsets.only(left: 3.0.w, right: 14.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoSwitch(
                                // overrides the default green color of the track
                                activeColor: blueColor,
                                // color of the round icon, which moves from right to left
                                thumbColor: Colors.white,
                                // when the switch is off
                                trackColor: Colors.grey,
                                // boolean variable value
                                value: getValue("shouldShowAyahNotification"),
                                // changes the state of the switch
                                onChanged: (value) async {
                                  updateValue(
                                      "shouldShowAyahNotification", value);
                                  if (value == true) {
                                    Workmanager().registerPeriodicTask(
                                        "ayahNotfication", "ayahNot",
                                        frequency: Duration(
                                            minutes: periods[getValue(
                                                    "timesForShowingAyahNotifications")]
                                                ["index"])

                                        // frequency: const Duration(
                                        //     minutes:1
                                        //     //  24 *
                                        //     //     60 ~/
                                        //     //     getValue(
                                        //     //         "timesFoShowingAyahNotifications")

                                        //             )
                                        );
                                    // Instant Feedback regarding Ayah
                                    Workmanager().registerOneOffTask(
                                        "ayahNotTest", "ayahNotTest");
                                  } else {
                                    // Fluttertoast.showToast(
                                    //     msg:
                                    //         "وَلَقَدْ خَلَقْنَا الْإِنسَانَ وَنَعْلَمُ مَا تُوَسْوِسُ بِهِ نَفْسُهُ",
                                    //     toastLength: Toast.LENGTH_LONG,
                                    //     gravity: ToastGravity.TOP_RIGHT);
                                    Workmanager()
                                        .cancelByUniqueName("ayahNotfication");
                                  }

                                  setState(() {});
                                }),
                            TextButton(
                                onPressed: () async {
                                  if ((await Permission
                                          .notification.isGranted) ==
                                      false) {
                                    await Permission.notification.request();
                                  }

                                  if (await Permission.notification.isGranted) {
                                    Workmanager().registerOneOffTask(
                                        "ayahNotTest", "ayahNotTest");
                                  }
                                  setState(() {});
                                },
                                child: Text(
                                  "test".tr(),
                                  style: TextStyle(
                                    color: getValue("darkMode")
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 14.sp,
                                    fontFamily: 'cairo',
                                  ),
                                )),
                            Row(
                              children: [
                                Text(
                                  "ayahnotification".tr(),
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      color: getValue("darkMode")
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'cairo'),
                                ),
                                SizedBox(
                                  width: 5.w,
                                ),
                                CircleAvatar(
                                  radius: 5,
                                  backgroundColor:
                                      getValue("shouldShowAyahNotification")
                                          ? Colors.green
                                          : Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0.w),
                        child: Text(
                          "ayahnotificationdetails".tr(),
                          softWrap: true,
                          style: TextStyle(
                            color: getValue("darkMode")
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      // Text(
                      //   'Letter: ${reciter.letter}',
                      //   style: const TextStyle(fontSize: 16),
                      // ),
                      // Text(
                      //   'ID: ${reciter.id}',
                      //   style: const TextStyle(fontSize: 16),
                      // ),

                      // padding: EdgeInsets.all(8.0),

                      Padding(
                        padding: const EdgeInsets.all(8),
                        child:
                            Image.asset("assets/images1/ayahNotification.webp"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Material(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: screenSize.width * .8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "shownotificationevery".tr(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: getValue("darkMode")
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16.sp,
                                          fontFamily: 'cairo'),
                                    ),
                                    DropdownButton(
                                        value: getValue(
                                            "timesForShowingAyahNotifications"),
                                        items: periods
                                            .map((e) => DropdownMenuItem(
                                                value: e["index"],
                                                child: Text(
                                                  e["name"],
                                                  style: TextStyle(
                                                      color:
                                                          getValue("darkMode")
                                                              ? Colors.white
                                                              : Colors.black,
                                                      fontSize: 16.sp,
                                                      fontFamily: 'cairo'),
                                                )))
                                            .toList(),
                                        onChanged: (f) {
                                          updateValue(
                                              "timesForShowingAyahNotifications",
                                              f);
                                          setState(() {});
                                        }),
                                    Text(
                                      "daily".tr(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: getValue("darkMode")
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16.sp,
                                          fontFamily: 'cairo'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // You can add more properties from the Reciter class here
                      // For example:
                      // Text('Other Property: ${reciter.otherProperty}'),
                      // ...
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              child: Card(
                elevation: .8,
                color: getValue("darkMode")
                    ? darkModeSecondaryColor
                    : Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),

                      Padding(
                        padding: EdgeInsets.only(left: 3.0.w, right: 14.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // const SizedBox(
                            //   width: 10,
                            // ),
                            CupertinoSwitch(
                                // overrides the default green color of the track
                                activeColor: blueColor,
                                // color of the round icon, which moves from right to left
                                thumbColor: Colors.white,
                                // when the switch is off
                                trackColor: Colors.grey,
                                // boolean variable value
                                value: getValue("shouldShowZikrNotification2"),
                                // changes the state of the switch
                                onChanged: (value) async {
                                  updateValue(
                                      "shouldShowZikrNotification2", value);
                                  if (value == true) {
                                    Workmanager().registerPeriodicTask(
                                        "zikrNotification2",
                                        "zikrNotification2",
                                        frequency: Duration(
                                            minutes: periods[getValue(
                                                    "timesForShowingZikrNotifications2")]
                                                ["index"]));
                                    // Instant Feedback
                                    Workmanager().registerOneOffTask(
                                        "zikrNotificationTest2",
                                        "zikrNotificationTest2");
                                  } else {
                                    Workmanager().cancelByUniqueName(
                                        "zikrNotification2");
                                  }

                                  setState(() {});
                                }),
                            //  IconButton(
                            // onPressed: () async {

                            // },
                            // icon: Icon(
                            //   size: 20,
                            //   FontAwesome.heart_empty,
                            //   color: quranPagesColor.withOpacity(.6),
                            // )),
                            TextButton(
                                onPressed: () async {
                                  Workmanager().registerOneOffTask(
                                      "zikrNotificationTest2",
                                      "zikrNotificationTest2");

                                  setState(() {});
                                },
                                child: Text(
                                  "test".tr(),
                                  style: TextStyle(
                                      color: getValue("darkMode")
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14.sp,
                                      fontFamily: 'cairo'),
                                )),
                            Row(
                              children: [
                                Text(
                                  "zikrNotification".tr(),
                                  style: TextStyle(
                                      color: getValue("darkMode")
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'cairo'),
                                ),
                                SizedBox(
                                  width: 5.w,
                                ),
                                CircleAvatar(
                                  radius: 5,
                                  backgroundColor:
                                      getValue("shouldShowZikrNotification2")
                                          ? Colors.green
                                          : Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0.w),
                        child: Text(
                          "zikrNotificationDetails2".tr(),
                          softWrap: true,
                          style: TextStyle(
                            color: getValue("darkMode")
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      )
                      // Text(
                      //   'Letter: ${reciter.letter}',
                      //   style: const TextStyle(fontSize: 16),
                      // ),
                      // Text(
                      //   'ID: ${reciter.id}',
                      //   style: const TextStyle(fontSize: 16),
                      // ),

                      // padding: EdgeInsets.all(8.0),
                      ,
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                            "assets/images1/zikrnotification2.webp"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Material(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: screenSize.width * .8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "shownotificationevery".tr(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: getValue("darkMode")
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16.sp,
                                          fontFamily: 'cairo'),
                                    ),
                                    DropdownButton(
                                        value: getValue(
                                            "timesForShowingZikrNotifications2"),
                                        items: periods
                                            .map((e) => DropdownMenuItem(
                                                value: e["index"],
                                                child: Text(
                                                  e["name"],
                                                  style: TextStyle(
                                                      color:
                                                          getValue("darkMode")
                                                              ? Colors.white
                                                              : Colors.black,
                                                      fontSize: 16.sp,
                                                      fontFamily: 'cairo'),
                                                )))
                                            .toList(),
                                        onChanged: (f) {
                                          updateValue(
                                              "timesForShowingZikrNotifications2",
                                              f);
                                          setState(() {});
                                        }),
                                    Text(
                                      "daily".tr(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: getValue("darkMode")
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16.sp,
                                          fontFamily: 'cairo'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // You can add more properties from the Reciter class here
                      // For example:
                      // Text('Other Property: ${reciter.otherProperty}'),
                      // ...
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              child: Card(
                elevation: .8,
                color: getValue("darkMode")
                    ? darkModeSecondaryColor
                    : Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),

                      Padding(
                        padding: EdgeInsets.only(left: 3.0.w, right: 14.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // const SizedBox(
                            //   width: 10,
                            // ),
                            CupertinoSwitch(
                                // overrides the default green color of the track
                                activeColor: blueColor,
                                // color of the round icon, which moves from right to left
                                thumbColor: Colors.white,
                                // when the switch is off
                                trackColor: Colors.grey,
                                // boolean variable value
                                value: getValue("shouldShowZikrNotification"),
                                // changes the state of the switch
                                onChanged: (value) async {
                                  if ((await FlutterOverlayWindow
                                          .isPermissionGranted()) ==
                                      false) {
                                    await FlutterOverlayWindow
                                        .requestPermission();
                                  }

                                  if (await FlutterOverlayWindow
                                      .isPermissionGranted()) {
                                    updateValue(
                                        "shouldShowZikrNotification", value);
                                    if (value == true) {
                                      Workmanager().registerPeriodicTask(
                                          "zikrNotification",
                                          "zikrNotification",
                                          frequency: Duration(
                                              minutes: periods[getValue(
                                                      "timesForShowingZikrNotifications")]
                                                  ["index"]));
                                      // Instant Feedback
                                      Workmanager().registerOneOffTask(
                                          "zikrNotificationTest",
                                          "zikrNotificationTest");
                                    } else {
                                      Workmanager().cancelByUniqueName(
                                          "zikrNotification");
                                    }
                                  }
                                  setState(() {});
                                }),
                            //  IconButton(
                            // onPressed: () async {

                            // },
                            // icon: Icon(
                            //   size: 20,
                            //   FontAwesome.heart_empty,
                            //   color: quranPagesColor.withOpacity(.6),
                            // )),
                            TextButton(
                                onPressed: () async {
                                  if ((await FlutterOverlayWindow
                                          .isPermissionGranted()) ==
                                      false) {
                                    await FlutterOverlayWindow
                                        .requestPermission();
                                  }

                                  if (await FlutterOverlayWindow
                                      .isPermissionGranted()) {
                                    Workmanager().registerOneOffTask(
                                        "zikrNotificationTest",
                                        "zikrNotificationTest");
                                  }
                                  setState(() {});
                                },
                                child: Text(
                                  "test".tr(),
                                  style: TextStyle(
                                      color: getValue("darkMode")
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14.sp,
                                      fontFamily: 'cairo'),
                                )),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "${"zikrNotification".tr()} (Beta)",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 17.sp,
                                          color: getValue("darkMode")
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'cairo'),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  CircleAvatar(
                                    radius: 5,
                                    backgroundColor:
                                        getValue("shouldShowZikrNotification")
                                            ? Colors.green
                                            : Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0.w),
                        child: Text(
                          "zikrNotificationDetails".tr(),
                          softWrap: true,
                          style: TextStyle(
                            color: getValue("darkMode")
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      )
                      // Text(
                      //   'Letter: ${reciter.letter}',
                      //   style: const TextStyle(fontSize: 16),
                      // ),
                      // Text(
                      //   'ID: ${reciter.id}',
                      //   style: const TextStyle(fontSize: 16),
                      // ),

                      // padding: EdgeInsets.all(8.0),
                      ,
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset("assets/images1/zikrnotif.webp"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Material(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: screenSize.width * .8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "shownotificationevery".tr(),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: getValue("darkMode")
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 16.sp,
                                            fontFamily: 'cairo'),
                                      ),
                                    ),
                                    DropdownButton(
                                        value: getValue(
                                            "timesForShowingZikrNotifications"),
                                        items: periods
                                            .map((e) => DropdownMenuItem(
                                                value: e["index"],
                                                child: Text(
                                                  e["name"],
                                                  style: TextStyle(
                                                      color:
                                                          getValue("darkMode")
                                                              ? Colors.white
                                                              : Colors.black,
                                                      fontSize: 16.sp,
                                                      fontFamily: 'cairo'),
                                                )))
                                            .toList(),
                                        onChanged: (f) {
                                          updateValue(
                                              "timesForShowingZikrNotifications",
                                              f);
                                          setState(() {});
                                        }),
                                    Flexible(
                                      child: Text(
                                        "daily".tr(),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: getValue("darkMode")
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 16.sp,
                                            fontFamily: 'cairo'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // You can add more properties from the Reciter class here
                      // For example:
                      // Text('Other Property: ${reciter.otherProperty}'),
                      // ...
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
