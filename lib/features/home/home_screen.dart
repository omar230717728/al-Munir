import 'dart:convert';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:al_munir/core/constants.dart';
import 'package:al_munir/features/quran/views/surah_list_screen.dart';
import 'package:al_munir/features/allah_names/allah_names_page.dart';
import 'package:al_munir/features/azkar/views/screenshot_preview_screen.dart';
import 'package:al_munir/features/sibha/sibha_page.dart';
import 'package:quran/quran.dart' as quran;
import 'package:al_munir/blocs/bloc/quran_page_player_bloc.dart';
import 'package:al_munir/blocs/bloc/player_bloc_bloc.dart';
import 'package:al_munir/blocs/bloc/bloc/player_bar_bloc.dart';
import 'package:al_munir/core/hive_helper.dart';
import 'package:al_munir/features/notifications/views/all_notification_page.dart';
import 'package:superellipse_shape/superellipse_shape.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:al_munir/features/quran/data/convertNumberToAr.dart';
import 'package:al_munir/features/quran/views/screenshot_preview_screen.dart';
import 'package:al_munir/features/audio/views/audio_home_screen.dart';
import 'package:flutter/material.dart' as m;

final qurapPagePlayerBloc = QuranPagePlayerBloc();
final playerPageBloc = PlayerBlocBloc();
final playerbarBloc = PlayerBarBloc();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var widgejsonData;
  var quarterjsonData;
  int randomSura = 1;
  int randomVerse = 1;

  @override
  void initState() {
    super.initState();
    loadJsonAsset();
    _generateRandomAya();
  }

  Future<void> loadJsonAsset() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/surahs.json');
    var data = await compute(jsonDecode, jsonString);
    setState(() {
      widgejsonData = data;
    });
    final String jsonString2 =
        await rootBundle.loadString('assets/json/quarters.json');
    var data2 = await compute(jsonDecode, jsonString2);
    setState(() {
      quarterjsonData = data2;
    });
  }

  String _getFlag(String code) {
    switch (code) {
      case 'ar':
        return "🇸🇦";
      case 'en':
        return "🇺🇸";
      case 'tr':
        return "🇹🇷";
      case 'ru':
        return "🇷🇺";
      case 'ms':
        return "🇮🇩";
      case 'de':
        return "🇩🇪";
      case 'am':
        return "🇪🇹";
      case 'pt':
        return "🇵🇹";
      default:
        return "🇺🇸";
    }
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor:
            getValue("darkMode") ? const Color(0xff2d2d2d) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Text("language".tr(),
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: getValue("darkMode")
                              ? Colors.white
                              : Colors.black)),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLanguageTile(context, "🇺🇸", "English", "en"),
                        _buildLanguageTile(context, "🇸🇦", "العربية", "ar"),
                        _buildLanguageTile(context, "🇹🇷", "Türkçe", "tr"),
                        _buildLanguageTile(context, "🇷🇺", "Русский", "ru"),
                        _buildLanguageTile(context, "🇮🇩", "Indonesia", "ms"),
                        _buildLanguageTile(context, "🇩🇪", "Deutsch", "de"),
                        _buildLanguageTile(context, "🇪🇹", "አማርኛ", "am"),
                        _buildLanguageTile(context, "🇵🇹", "Português", "pt"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildLanguageTile(
      BuildContext context, String flag, String name, String code) {
    bool isSelected = context.locale.languageCode == code;
    return ListTile(
      leading: Text(flag, style: TextStyle(fontSize: 24.sp)),
      title: Text(name,
          style: TextStyle(
              color: getValue("darkMode") ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing:
          isSelected ? Icon(Icons.check_circle, color: orangeColor) : null,
      onTap: () {
        context.setLocale(Locale(code));
        setState(() {});
        Navigator.pop(context);
      },
    );
  }

  void _generateRandomAya() {
    setState(() {
      randomSura = Random().nextInt(114) + 1;
      randomVerse = Random().nextInt(quran.getVerseCount(randomSura)) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          color:
              getValue("darkMode") ? quranPagesColorDark : quranPagesColorLight,
          image: DecorationImage(
              image: const AssetImage("assets/images1/bckg.webp"),
              alignment: Alignment.topCenter,
              opacity: getValue("darkMode") ? .1 : .5)),
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
                image: AssetImage("assets/images1/back2.webp"),
                alignment: Alignment.bottomCenter,
                opacity: .3)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leadingWidth: 100.w,
            leading: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications,
                      color: getValue("darkMode") ? Colors.white : Colors.black,
                      size: 26.sp),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsPage()));
                  },
                ),
                IconButton(
                  icon: Icon(Iconsax.moon,
                      color: getValue("darkMode") ? Colors.white : Colors.black,
                      size: 26.sp),
                  onPressed: () {
                    bool isDark = getValue("darkMode") ?? false;
                    bool newValue = !isDark;
                    if (newValue) {
                      // Switching to Dark Mode
                      int currentTheme = getValue("quranPageolorsIndex") ?? 0;
                      updateValue("lastLightModeThemeIndex", currentTheme);
                      updateValue("quranPageolorsIndex",
                          10); // Set to Dark Theme (Index 10 for darker black)
                    } else {
                      // Switching back to Light Mode
                      int lastTheme = getValue("lastLightModeThemeIndex") ?? 0;
                      updateValue("quranPageolorsIndex", lastTheme);
                    }
                    updateValue("darkMode", newValue);
                    setState(() {});
                  },
                ),
              ],
            ),
            actions: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: GestureDetector(
                  onTap: () {
                    _showLanguageBottomSheet(context);
                  },
                  child: Center(
                    child: Text(
                      _getFlag(context.locale.languageCode),
                      style: TextStyle(fontSize: 28.sp),
                    ),
                  ),
                ),
              )
            ],
          ),
          body: Container(
            width: screenSize.width,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: const AssetImage("assets/images1/try2.webp"),
                    alignment: Alignment.bottomCenter,
                    opacity: .2)),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Random Aya Box removed

                  SizedBox(
                    height: screenSize.height * 0.7,
                    child: PageView(
                      controller: PageController(viewportFraction: 0.75),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildCard(
                          context,
                          title: "quran".tr(),
                          subtitle: "readAndListen".tr(),
                          imagePath: "assets/images1/Quran_page.webp",
                          color: Colors.black,
                          textColor: Colors.white,
                          onTap: () {
                            if (widgejsonData != null &&
                                quarterjsonData != null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => SurahListPage(
                                          jsonData: widgejsonData,
                                          quarterjsonData: quarterjsonData)));
                            }
                          },
                        ),
                        _buildCard(
                          context,
                          title: "azkar".tr(),
                          subtitle: "dailyAdhkar".tr(),
                          imagePath: "assets/images1/azkar.webp",
                          color: const Color(0xffF5F5F5),
                          textColor: Colors.white,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AzkarHomePage())),
                        ),
                        _buildCard(
                          context,
                          title: "allahNames".tr(),
                          subtitle: "ninetyNineNames".tr(),
                          imagePath: "assets/images1/names_of_allah.webp",
                          color: const Color(0xffF5F5F5),
                          textColor: Colors.white,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AllahNamesPage())),
                        ),
                        _buildCard(
                          context,
                          title: "sibha".tr(),
                          subtitle: "digitalTasbih".tr(),
                          imagePath: "assets/images1/sibha.webp",
                          color: const Color(0xffF5F5F5),
                          textColor: Colors.white,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SibhaPage())),
                        ),
                        _buildCard(
                          context,
                          title: "recitersTitle".tr(),
                          subtitle: "listenToQuran".tr(),
                          imagePath: "assets/images1/reciter.webp",
                          color: const Color(0xffF5F5F5),
                          textColor: Colors.white,
                          onTap: () {
                            if (widgejsonData != null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AudioHomeScreen(
                                          jsonData: widgejsonData)));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Directionality(
                    textDirection: m.TextDirection.rtl,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.0.w, vertical: 6.h),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(getValue("darkMode")
                                  ? "assets/images1/dark_ayah.webp"
                                  : "assets/images1/light_ayah.webp"),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(40.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: randomSura != null
                            ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: getValue("darkMode")
                                          ? quranPagesColorDark
                                          : quranPagesColorLight
                                              .withOpacity(.95),
                                      borderRadius:
                                          BorderRadius.circular(20.r)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: 10.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: orangeColor),
                                              child: IconButton(
                                                  onPressed: () {
                                                    _generateRandomAya();
                                                  },
                                                  icon: Icon(
                                                    Iconsax.refresh,
                                                    color: Colors.white,
                                                    size: 18.sp,
                                                  )),
                                            ),
                                            Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: getValue("darkMode")
                                                        ? orangeColor
                                                        : blueColor),
                                                child: IconButton(
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          elevation: 0,
                                                          context: context,
                                                          builder:
                                                              (ctx) => SafeArea(
                                                                    child:
                                                                        Container(
                                                                      decoration: BoxDecoration(
                                                                          color: getValue("darkMode")
                                                                              ? quranPagesColorDark
                                                                              : Colors.white,
                                                                          borderRadius: const BorderRadius.only(
                                                                              topLeft: Radius.circular(12),
                                                                              topRight: Radius.circular(12))),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          SizedBox(
                                                                              height: 15.h),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceAround,
                                                                            children: [
                                                                              Container(
                                                                                decoration: BoxDecoration(
                                                                                    color: getValue("darkMode")
                                                                                        ? Colors.black26
                                                                                        : quranPagesColorDark,
                                                                                    borderRadius: BorderRadius.circular(12)),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(0.0),
                                                                                  child: TextButton(
                                                                                      onPressed: () {
                                                                                        Navigator.push(
                                                                                            context,
                                                                                            MaterialPageRoute(
                                                                                                builder: (builder) => ScreenShotPreviewPage(
                                                                                                    isQCF: true,
                                                                                                    index: 5,
                                                                                                    surahNumber: randomSura,
                                                                                                    jsonData: widgejsonData,
                                                                                                    firstVerse: randomVerse,
                                                                                                    lastVerse: randomVerse)));
                                                                                      },
                                                                                      child: Text("asimage".tr(),
                                                                                          style: TextStyle(
                                                                                              color: Colors.white,
                                                                                              fontSize: 14.sp))),
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                decoration: BoxDecoration(
                                                                                    color: getValue("darkMode")
                                                                                        ? Colors.black26
                                                                                        : quranPagesColorDark,
                                                                                    borderRadius: BorderRadius.circular(12)),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(0.0),
                                                                                  child: TextButton(
                                                                                      onPressed: () {
                                                                                        var verse = quran.getVerse(
                                                                                            randomSura,
                                                                                            randomVerse,
                                                                                            verseEndSymbol: true);
                                                                                        var suraName = quran.getSurahNameArabic(randomSura);
                                                                                        Share.share("$verse \nسورة $suraName");
                                                                                      },
                                                                                      child: Text("astext".tr(),
                                                                                          style: TextStyle(
                                                                                              color: Colors.white,
                                                                                              fontSize: 14.sp))),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                              height: 30.h)
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ));
                                                    },
                                                    icon: Icon(Iconsax.share,
                                                        color: Colors.white,
                                                        size: 18.sp)))
                                          ],
                                        ),
                                        SizedBox(height: 20.h),
                                        SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            quran.getVerse(
                                                randomSura, randomVerse),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: getValue("darkMode")
                                                    ? Colors.white70
                                                    : goldColor,
                                                fontSize: 22.sp,
                                                fontFamily: "UthmanicHafs13"),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              quran.getSurahNameArabic(
                                                  randomSura),
                                              style: TextStyle(
                                                  color: getValue("darkMode")
                                                      ? Colors.white70
                                                      : goldColor,
                                                  fontSize: 14.sp,
                                                  fontFamily: "UthmanicHafs13"),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 10.h)
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? imagePath,
    IconData? icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: imagePath == null ? color : null, // Only use color if no image
          image: imagePath != null
              ? DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2),
                      BlendMode.darken) // Optional readability overlay
                  )
              : null,
          borderRadius: BorderRadius.circular(32.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (icon !=
                null) // Only show icon circle if icon is provided (fallback)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: textColor == Colors.white
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32.sp, color: textColor),
              ),
            if (imagePath != null)
              SizedBox(height: 16.h), // Spacer if using image background
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: textColor.withOpacity(0.95),
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: textColor.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("open".tr(),
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp)),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward, size: 14.sp, color: textColor),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
