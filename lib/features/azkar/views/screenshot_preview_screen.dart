import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:al_munir/core/constants.dart';
import 'package:al_munir/core/hive_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:al_munir/features/azkar/data/azkar.dart';
import 'package:al_munir/features/azkar/model/dua_model.dart';
import 'package:al_munir/features/azkar/views/zikr_details_screen.dart';

import 'package:quran/quran.dart';
import 'package:superellipse_shape/superellipse_shape.dart';

class AzkarHomePage extends StatefulWidget {
  const AzkarHomePage({super.key});

  @override
  State<AzkarHomePage> createState() => _AzkarHomePageState();
}

class _AzkarHomePageState extends State<AzkarHomePage> {
  int index = 0;
  List tempAzkar = azkar;
  searchFunction(searchwords) {
    tempAzkar = azkar
        .where((element) =>
            removeDiacritics(element["category"]).contains(searchwords))
        .toList();

    // hadithes = filteredHadithes;
    if (searchwords == "") {
      tempAzkar = azkar;
    }

    setState(() {});
  }

  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                "assets/images1/try6.webp",
              ),
              alignment: Alignment.center,
              opacity: .6)),
      child: Scaffold(
        backgroundColor:
            getValue("darkMode") ? quranPagesColorDark : quranPagesColorLight,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              pinned: true,
              iconTheme: const IconThemeData(color: Color(0xffe0cb8a)),
              backgroundColor:
                  getValue("darkMode") ? darkModeSecondaryColor : primaryColor,
              elevation: 4,
              title: Text(
                "azkar".tr(),
                style: TextStyle(
                    color: const Color(0xffe0cb8a),
                    fontSize: 16.sp,
                    fontFamily: "cairo",
                    fontWeight: FontWeight.bold),
              ),
              expandedHeight: 120.h,
              collapsedHeight: kToolbarHeight,
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
                child: FlexibleSpaceBar(
                  background: Container(
                    alignment: Alignment.bottomCenter,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    child: Container(
                      height: 45.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          const Icon(Icons.search, color: Color(0xffe0cb8a)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              controller: textEditingController,
                              onChanged: (val) {
                                searchFunction(val);
                              },
                              decoration: InputDecoration(
                                  hintText: 'SearchDua'.tr(),
                                  hintStyle: const TextStyle(
                                      color: Colors.white70,
                                      fontFamily: "cairo"),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(bottom: 8.h)),
                            ),
                          ),
                          if (tempAzkar.length != azkar.length)
                            IconButton(
                                onPressed: () {
                                  textEditingController.clear();
                                  searchFunction("");
                                },
                                icon: const Icon(Icons.close,
                                    color: Colors.white70))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverList.builder(
                // shrinkWrap: true,
                itemCount: tempAzkar.length,
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (f, i) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 6.h),
                    child: Material(
                      color: getValue("darkMode")
                          ? darkModeSecondaryColor.withOpacity(.8)
                          : const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(.2),
                      shape: SuperellipseShape(
                        borderRadius: BorderRadius.circular(34.0.r),
                      ),
                      child:
                          // AnimatedOpacity(
                          // duration: const Duration(milliseconds: 500),
                          // opacity: dominantColor != null ? 1.0 : 0,
                          // child:
                          InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (builder) => ZikrPage(
                                        zikr: DuaModel.fromJson(tempAzkar[i]),
                                      )));
                        },
                        splashColor: getValue("darkMode")
                            ? darkModeSecondaryColor.withOpacity(.5)
                            : primaryColor.withOpacity(.2),
                        borderRadius: BorderRadius.circular(17.0.r),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 12.h,
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 12.0.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tempAzkar[i]["category"],
                                        style: TextStyle(
                                          color: getValue("darkMode")
                                              ? Colors.white.withOpacity(.9)
                                              : primaryColor,
                                          fontSize: 18.sp,
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Add ellipsis for handling very long text gracefully
                                      ),
                                    ),
                                    SizedBox(width: 8.w), // Add proper spacing
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: goldColor,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 12.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
