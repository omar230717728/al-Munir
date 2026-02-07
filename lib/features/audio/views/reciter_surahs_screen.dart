import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:al_munir/blocs/bloc/player_bloc_bloc.dart';
import 'package:al_munir/core/constants.dart';
import 'package:al_munir/core/hive_helper.dart';
import 'package:al_munir/blocs/bloc/quran_page_player_bloc.dart';
import 'package:al_munir/features/audio/models/reciter.dart';
import 'package:al_munir/features/home/home_screen.dart';
import 'package:al_munir/core/api/api_client.dart';

import 'package:quran/quran.dart' as quran;

class ReciterSurahsScreen extends StatefulWidget {
  Reciter reciter;
  Moshaf mushaf;
  var jsonData;

  ReciterSurahsScreen(
      {super.key,
      required this.reciter,
      required this.mushaf,
      required this.jsonData});

  @override
  State<ReciterSurahsScreen> createState() => _ReciterSurahsScreenState();
}

class _ReciterSurahsScreenState extends State<ReciterSurahsScreen> {
  // List<String> get surahNumbers => widget.mushaf.surahList.split(',');
  late List surahs;

  addSuraNames() {
    surahs = [];
    filteredSurahs = [];
    if (widget.jsonData == null || (widget.jsonData as List).isEmpty) {
      // Graceful fallback if data is missing
      return;
    }

    setState(() {
      surahs = widget.mushaf.surahList.split(',').map((e) {
        var surahDataList = widget.jsonData
            .where((element) => element["id"].toString() == e.toString());

        String surahName = "Unknown Surah";
        if (surahDataList.isNotEmpty) {
          surahName = surahDataList.first["name"];
        }

        return {"surahNumber": e, "suraName": surahName};
      }).toList();
    });
  }

  List favoriteSurahs = [];
  filterFavoritesOnly() {
    favoriteSurahs = [];
    for (var element in surahs) {
      if (favoriteSurahList.contains(
          "${widget.reciter.name}${widget.mushaf.name}${int.parse(element["surahNumber"])}"
              .trim())) {
        favoriteSurahs.add(element);
      }
    }
    setState(() {});
  }

  filterDownloadsOnly() {
    favoriteSurahs = [];
    for (var element in surahs) {
      if (File(
              "${appDir.path}${widget.reciter.name}-${widget.mushaf.id}-${quran.getSurahNameArabic(int.parse(element["surahNumber"]))}.mp3")
          .existsSync()) {
        favoriteSurahs.add(element);
      }
    }
    setState(() {});
  }

  addFavorites() {
    var favList = getValue("favoriteSurahList");
    if (favList != null) {
      try {
        favoriteSurahList = json.decode(favList);
      } catch (e) {
        favoriteSurahList = [];
      }
    } else {
      favoriteSurahList = [];
    }
    setState(() {});
  }

  Future storePhotoUrl() async {
    try {
      final url =
          'https://www.googleapis.com/customsearch/v1?key=AIzaSyCR7ttKFGB4dG5MDJI3ygqiESjpWmKePrY&cx=f7b7aaf5b2f0e47e0&q=القارئ ${widget.reciter.name}&searchType=image';
      if (getValue("${widget.reciter.name} photo url") == null) {
        final apiClient = ApiClient();
        final response = await apiClient.get(url);

        if (response.statusCode == 200 &&
            response.data["items"] != null &&
            response.data["items"].isNotEmpty) {
          updateValue("${widget.reciter.name} photo url",
              response.data["items"][0]['link']);
          if (mounted) setState(() {});
        }
      }
    } catch (e) {
      print("Error fetching photo: $e");
    }
  }

  List filteredSurahs = [];

  filterSurahs(value) {
    addSuraNames();
    setState(() {
      filteredSurahs = surahs
          .where(
              (element) => quran.normalise(element["suraName"]).contains(value))
          .toList();
    });
  }

  // String photoUrl = "";
  @override
  void initState() {
    addFavorites();
    addSuraNames();
    super.initState();
    storePhotoUrl();
  }

  List favoriteSurahList = [];

  var selectedMode = "all";
  var searchQuery = "";
  final appDir = Directory("/storage/emulated/0/Download/Al-Munner/");

  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // Determine the list to display based on mode
    List<dynamic> currentList;
    if (filteredSurahs.isNotEmpty) {
      currentList = filteredSurahs;
    } else if (selectedMode == "favorite") {
      currentList = favoriteSurahs;
    } else if (selectedMode == "downloads") {
      currentList =
          favoriteSurahs; // Logic for downloads reuses favoriteSurahs variable in original code
    } else {
      currentList = surahs;
    }

    return Scaffold(
      backgroundColor:
          getValue("darkMode") ? quranPagesColorDark : const Color(0xfff5f5f5),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: getValue("darkMode")
                  ? [darkModeSecondaryColor, darkModeSecondaryColor]
                  : [primaryColor, const Color(0xff5D4037)], // Brown gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        title: Text(
          "${widget.reciter.name}",
          style: TextStyle(
              color: const Color(0xffe0cb8a),
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: "cairo"),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xffe0cb8a),
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xffe0cb8a),
              radius: 18,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: primaryColor,
                backgroundImage: CachedNetworkImageProvider(
                    "${getValue("${widget.reciter.name} photo url")}"),
              ),
            ),
          )
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
            decoration: BoxDecoration(
              color:
                  getValue("darkMode") ? darkModeSecondaryColor : primaryColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                        color: getValue("darkMode")
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(15.r)),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Icon(FontAwesome.search,
                              color: const Color(0xffe0cb8a), size: 18.sp),
                        ),
                        Expanded(
                          child: TextField(
                            controller: textEditingController,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                              filterSurahs(value);
                              if (value == "") {
                                addSuraNames();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "searchBysura".tr(),
                              hintStyle: TextStyle(
                                  fontFamily: "cairo",
                                  fontSize: 14.sp,
                                  color: Colors.white70),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (searchQuery.isNotEmpty)
                          IconButton(
                            icon:
                                const Icon(Icons.close, color: Colors.white70),
                            onPressed: () {
                              textEditingController.clear();
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                searchQuery = "";
                                addSuraNames();
                              });
                            },
                          )
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xffe0cb8a), // Gold
                      borderRadius: BorderRadius.circular(15.r)),
                  child: IconButton(
                      onPressed: () {
                        _showFilterModal(context);
                      },
                      icon: const Icon(FontAwesome.sliders,
                          color: Colors.black87)),
                ),
              ],
            ),
          ),

          // List Content
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: currentList.length,
              itemBuilder: (context, index) {
                dynamic surah = currentList[index];
                return _buildSurahTile(
                    surah, index); // Extracted for cleanliness
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor:
            getValue("darkMode") ? const Color(0xff2d2d2d) : Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterOption(Icons.all_inclusive, "all".tr(), "all"),
                _buildFilterOption(Icons.favorite, "favorites".tr(), "favorite",
                    iconColor: Colors.redAccent),
                _buildFilterOption(
                    Icons.download, "downloaded".tr(), "downloads",
                    iconColor: primaryColor),
              ],
            ),
          );
        });
  }

  Widget _buildFilterOption(IconData icon, String title, String mode,
      {Color iconColor = primaryColor}) {
    bool isSelected = selectedMode == mode;
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title,
          style: TextStyle(
              color: getValue("darkMode") ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: primaryColor)
          : null,
      onTap: () {
        setState(() {
          selectedMode = mode;
        });
        if (mode == "favorite") filterFavoritesOnly();
        if (mode == "downloads") filterDownloadsOnly();
        if (mode == "all") addSuraNames();

        Navigator.pop(context);
      },
    );
  }

  Widget _buildSurahTile(dynamic surah, int index) {
    return EasyContainer(
      borderRadius: 12.r,
      elevation: 0,
      padding: 0,
      margin: 0,
      color: getValue("darkMode")
          ? darkModeSecondaryColor.withOpacity(.9)
          : Colors.transparent, // Transparent to blend with bg
      onTap: () async {
        if (qurapPagePlayerBloc.state is QuranPagePlayerPlaying) {
          // Logic to warn user or just kill player is fine.
          // keeping existing behavior simplified
          qurapPagePlayerBloc.add(KillPlayerEvent());
        }
        playerPageBloc.add(StartPlaying(
            buildContext: context,
            moshaf: widget.mushaf,
            reciter: widget.reciter,
            suraNumber: int.parse(surah["surahNumber"]),
            initialIndex: surahs.indexWhere((element) =>
                element["surahNumber"] ==
                surah["surahNumber"]), // Correct index lookup
            jsonData: widget.jsonData));
      },
      child: ListTile(
          leading: Image.asset(
            "assets/images1/${quran.getPlaceOfRevelation(int.parse(surah["surahNumber"])) == "Makkah" ? "Makkah" : "Madinah"}.webp",
            height: 30.h,
            width: 30.w,
          ),
          title: Text(
            "${context.locale.languageCode == "ar" ? widget.jsonData[(int.parse(surah["surahNumber"])) - 1]["name"] : surah["suraName"]}",
            style: TextStyle(
                fontFamily:
                    context.locale.languageCode == "ar" ? "qaloon" : "roboto",
                fontSize: context.locale.languageCode == "ar" ? 20.sp : 17.sp,
                fontWeight: FontWeight.bold,
                color: getValue("darkMode")
                    ? Colors.white.withOpacity(.9)
                    : Colors.black87),
          ),
          subtitle: Text(
            "${widget.mushaf.name}",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ),
          trailing: SizedBox(
            width: 140.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    playerPageBloc.add(StartPlaying(
                        moshaf: widget.mushaf,
                        reciter: widget.reciter,
                        buildContext: context,
                        suraNumber: int.parse(surah["surahNumber"]),
                        initialIndex: surahs.indexWhere((element) =>
                            element["surahNumber"] == surah["surahNumber"]),
                        jsonData: widget.jsonData));
                  },
                  icon: Icon(
                    Icons.play_circle_fill,
                    size: 32.sp,
                    color: getValue("darkMode")
                        ? const Color(0xffe0cb8a)
                        : primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    String path =
                        "${appDir.path}${widget.reciter.name}-${widget.mushaf.id}-${quran.getSurahNameArabic(int.parse(surah["surahNumber"]))}.mp3";
                    if (!File(path).existsSync()) {
                      playerPageBloc.add(DownloadSurah(
                          reciter: widget.reciter,
                          moshaf: widget.mushaf,
                          suraNumber: surah["surahNumber"],
                          url:
                              "${widget.mushaf.server}/${(surah["surahNumber"]).padLeft(3, "0")}.mp3"));
                    }
                  },
                  icon: Icon(
                      File("${appDir.path}${widget.reciter.name}-${widget.mushaf.id}-${quran.getSurahNameArabic(int.parse(surah["surahNumber"]))}.mp3")
                              .existsSync()
                          ? Icons.check_circle
                          : Icons.download_rounded,
                      size: 24.sp,
                      color:
                          File("${appDir.path}${widget.reciter.name}-${widget.mushaf.id}-${quran.getSurahNameArabic(int.parse(surah["surahNumber"]))}.mp3")
                                  .existsSync()
                              ? Colors.green
                              : getValue("darkMode")
                                  ? const Color(0xffe0cb8a)
                                  : primaryColor),
                ),
                IconButton(
                  onPressed: () {
                    String key =
                        "${widget.reciter.name}${widget.mushaf.name}${surah["surahNumber"]}"
                            .trim();
                    if (favoriteSurahList.contains(key)) {
                      favoriteSurahList.remove(key);
                    } else {
                      favoriteSurahList.add(key);
                    }
                    updateValue(
                        "favoriteSurahList", json.encode(favoriteSurahList));
                    setState(() {});
                  },
                  icon: Icon(
                      favoriteSurahList.contains(
                              "${widget.reciter.name}${widget.mushaf.name}${surah["surahNumber"]}"
                                  .trim())
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 24.sp,
                      color: Colors.redAccent),
                )
              ],
            ),
          )),
    );
  }
}
