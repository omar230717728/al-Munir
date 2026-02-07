import 'dart:ui' as ui;

import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:al_munir/core/constants.dart';
import 'package:al_munir/core/hive_helper.dart';
import 'package:al_munir/features/quran/data/quran_page_utils.dart';
import 'package:quran/quran.dart' as quran;

class QuranPageHeader extends StatelessWidget {
  final int index;
  final dynamic jsonData;
  final dynamic quarterJsonData;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const QuranPageHeader({
    Key? key,
    required this.index,
    required this.jsonData,
    required this.quarterJsonData,
    required this.onBack,
    required this.onSettings,
    required this.isBookmarked,
    required this.onBookmark,
  }) : super(key: key);

  final bool isBookmarked;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final pageData = quran.getPageData(index);
    final surahNumber = pageData[0]["surah"];
    final surahName = context.locale.languageCode == "ar"
        ? quran.getSurahNameArabic(surahNumber)
        : quran.getSurahNameEnglish(surahNumber);

    return SizedBox(
      width: screenSize.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left Side: Back Button & Surah Name
          Align(
            alignment: Alignment.centerLeft,
            child: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: onBack,
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 24.sp,
                        color: secondaryColors[getValue("quranPageolorsIndex")],
                      )),
                  Flexible(
                    child: Text(surahName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: secondaryColors[
                                getValue("quranPageolorsIndex")],
                            fontFamily: "Taha",
                            fontSize: 14.sp)),
                  ),
                ],
              ),
            ),
          ),

          // Center: Page Info
          Align(
            alignment: Alignment.center,
            child: _buildPageInfoChunk(index, pageData),
          ),

          // Right Side: Actions (Bookmark & Settings)
          Align(
            alignment: Alignment.centerRight,
            child: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: onBookmark,
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 24.sp,
                        color: isBookmarked
                            ? Colors.red
                            : secondaryColors[getValue("quranPageolorsIndex")],
                      )),
                  IconButton(
                      onPressed: onSettings,
                      icon: Icon(
                        Icons.settings,
                        size: 24.sp,
                        color: secondaryColors[getValue("quranPageolorsIndex")],
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageInfoChunk(int index, dynamic pageData) {
    final result = QuranPageUtils.checkIfPageIncludesQuarterAndQuarterIndex(
        quarterJsonData, pageData, indexes);

    if (result.includesQuarter) {
      return EasyContainer(
        borderRadius: 12.r,
        color: secondaryColors[getValue("quranPageolorsIndex")].withOpacity(.5),
        borderColor: primaryColors[getValue("quranPageolorsIndex")],
        showBorder: true,
        height: 20.h,
        width: 160.w,
        padding: 0,
        margin: 0,
        child: Text(
          result.includesQuarter == true
              ? "${"page".tr()} ${(index).toString()} | ${(result.quarterIndex + 1) == 1 ? "" : "${(result.quarterIndex).toString()}/${4.toString()}"} ${"hizb".tr()} ${(result.hizbIndex + 1).toString()} | ${"juz".tr()} ${quran.getJuzNumber(pageData[0]["surah"], pageData[0]["start"])} "
              : "${"page".tr()} $index | ${"juz".tr()} ${quran.getJuzNumber(pageData[0]["surah"], pageData[0]["start"])}",
          style: TextStyle(
            fontFamily: 'aldahabi',
            fontSize: 10.sp,
            color: backgroundColors[getValue("quranPageolorsIndex")],
          ),
        ),
      );
    } else {
      return EasyContainer(
        borderRadius: 12.r,
        color: secondaryColors[getValue("quranPageolorsIndex")].withOpacity(.5),
        borderColor: backgroundColors[getValue("quranPageolorsIndex")],
        showBorder: true,
        height: 20.h,
        width: 120.w,
        padding: 0,
        margin: 0,
        child: Center(
          child: Text(
            "${"page".tr()} $index | ${"juz".tr()} ${quran.getJuzNumber(pageData[0]["surah"], pageData[0]["start"])}",
            style: TextStyle(
              fontFamily: 'aldahabi',
              fontSize: 12.sp,
              color: backgroundColors[getValue("quranPageolorsIndex")],
            ),
          ),
        ),
      );
    }
  }
}
