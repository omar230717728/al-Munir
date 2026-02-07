import 'dart:convert';

import 'package:al_munir/core/api/api_client.dart';
import 'package:al_munir/core/constants.dart';
import 'package:al_munir/core/constants/api_constants.dart';
import 'package:al_munir/core/hive_helper.dart';
import 'package:al_munir/core/services/data_initializer.dart';
import 'package:al_munir/core/services/notification_service.dart';
import 'package:al_munir/features/home/home_screen.dart';
import 'package:al_munir/main.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

final mediaStorePlugin = MediaStore();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    //PermissionStatus status1 = await Permission.accessMediaLocation.request();
    // PermissionStatus status2 =
    //     await Permission.locationWhenInUse.request();
    print('status $status ');
    if (status.isGranted) {
      print(true);
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else if (status.isDenied) {
      print('Permission Denied');
    }
  }

  navigateToHome(context) async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (builder) => const Home(),

          // Container(height: 100,width: 100,color: Colors.amber,)
        ),
        (route) => false);
  }

  getAndStoreRecitersData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Response response;
    Response response2;
    Response response3;
    if (prefs.getString("reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}") == null ||
        prefs.getString(
                "moshaf-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}") ==
            null ||
        prefs.getString(
                "suwar-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}") ==
            null) {
      try {
        final languageParam = context.locale.languageCode == "ms"
            ? "eng"
            : (context.locale.languageCode == "en"
                ? "eng"
                : context.locale.languageCode);

        final apiClient = ApiClient();
        final responses = await Future.wait([
          apiClient
              .get('${ApiConstants.recitersEndpoint}?language=$languageParam'),
          apiClient
              .get('${ApiConstants.moshafEndpoint}?language=$languageParam'),
          apiClient
              .get('${ApiConstants.suwarEndpoint}?language=$languageParam'),
        ]);

        response = responses[0];
        response2 = responses[1];
        response3 = responses[2];

        if (response.data != null) {
          final jsonData = json.encode(response.data['reciters']);
          prefs.setString(
              "reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
              jsonData);
        }
        if (response2.data != null) {
          final jsonData2 = json.encode(response2.data);
          prefs.setString(
              "moshaf-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
              jsonData2);
        }
        if (response3.data != null) {
          final jsonData3 = json.encode(response3.data['suwar']);
          prefs.setString(
              "suwar-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}",
              jsonData3);
        }
      } catch (error) {
        print('Error while storing data: $error');
      }
    }

    prefs.setInt("zikrNotificationindex", 0);
  }

  initStoragePermission() async {
    List<Permission> permissions = [
      Permission.storage,
    ];

    if ((await mediaStorePlugin.getPlatformSDKInt()) >= 33) {
      // permissions.add(Permission.photos); // REMOVED: Not needed for saving images
      permissions.add(Permission.audio);
      permissions.add(Permission.location);

      // permissions.add(Permission.videos);
    }

    await permissions.request();
    MediaStore.appFolder = "Al-Munner";
    initMessaging();
    setOptimalDisplayMode();
  }

  @override
  void initState() {
    super.initState();
    initHiveValues();
    checkNotificationPermission();

    getAndStoreRecitersData();
    initStoragePermission();
    navigateToHome(context);
  }

  List zikrNotifs = [
    "ﷺ  صلي علي محمد",
    "اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي",
    "لا حول ولا قوة الا بالله",
    "لا اله الا الله, محمد رسول الله",
    "لا اله الا انت سبحانك اني كنت من الظالمين",
    "استغفر الله",
    "سبحان الله",
    "الحمدلله",
    "لا اله الا الله",
    "الله اكبر"
  ];
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = getValue("darkMode") ?? false;
    Color backgroundColor =
        isDarkMode ? darkPrimaryColor : quranPagesColorLight;
    Color decorationColor = isDarkMode ? goldColor : primaryColor;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              // Top Decoration
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LottieBuilder.asset(
                    "assets/images1/splash_top.json",
                    width: MediaQuery.of(context).size.width * .8,
                    delegates: LottieDelegates(
                      values: [
                        ValueDelegate.color(
                          const ['**', 'Fill 1', '**'],
                          value: decorationColor,
                        ),
                        ValueDelegate.color(
                          const ['**', 'Stroke 1', '**'],
                          value: decorationColor,
                        ),
                        ValueDelegate.strokeColor(
                          const ['**'],
                          value: decorationColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Main Content (Logo + Loader)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images1/al-munner.png",
                      height: 180.h,
                    ),
                    SizedBox(height: 30.h),
                    LottieBuilder.asset(
                      "assets/images1/loading.json",
                      repeat: true,
                      height: 80.h,
                      delegates: LottieDelegates(
                        values: [
                          ValueDelegate.color(
                            const ['**', 'Fill 1', '**'],
                            value: decorationColor,
                          ),
                          ValueDelegate.color(
                            const ['**', 'Stroke 1', '**'],
                            value: decorationColor,
                          ),
                          ValueDelegate.strokeColor(
                            const ['**'],
                            value: decorationColor,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        "صَدَقَةٌ جَارِيَةٌ عَنْ رُوحِ جَدِّي وَجَدَّتِي،\nاللَّهُمَّ تَقَبَّلْهَا عَنْهُمَا، وَاجْعَلِ القُرْآنَ نُورًا لَهُمَا فِي قُبُورِهِمَا،\nوَشَفِيعًا لَهُمَا يَوْمَ القِيَامَةِ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'cairo',
                          fontSize: 14.sp,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: decorationColor,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
