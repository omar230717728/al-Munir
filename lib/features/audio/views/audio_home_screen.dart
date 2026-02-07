import 'dart:async'; // For Timer
import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart'; // For compute

import 'package:animations/animations.dart';
import 'package:azlistview/azlistview.dart';
import 'package:dio/dio.dart';
import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';

import 'package:al_munir/blocs/bloc/player_bloc_bloc.dart';
import 'package:al_munir/core/constants.dart';
import 'package:al_munir/core/hive_helper.dart';
import 'package:al_munir/core/utilis/logger.dart';
import 'package:al_munir/blocs/bloc/quran_page_player_bloc.dart';
import 'package:al_munir/core/api/api_client.dart';
import 'package:al_munir/core/constants/api_constants.dart';

import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:al_munir/features/audio/models/reciter.dart';
import 'package:al_munir/features/audio/views/reciter_surahs_screen.dart';
import 'package:al_munir/features/home/home_screen.dart';
import 'package:quran/quran.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_annimated_staggered/simple_annimated_staggered.dart'; // import this

// Top-level function for compute
List<Reciter> parseReciters(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Reciter>((json) => Reciter.fromJson(json)).toList();
}

// Top-level function for compute
Map<String, dynamic> parseMoshafs(String responseBody) {
  return json.decode(responseBody);
}

// Top-level function for compute
List<dynamic> parseSuwar(String responseBody) {
  return json.decode(responseBody);
}

class ReciterMoshafItem {
  final Reciter reciter;
  final Moshaf moshaf;

  ReciterMoshafItem({required this.reciter, required this.moshaf});
}

class Reciter_ImageWidget extends StatefulWidget {
  final String reciterName;
  const Reciter_ImageWidget({super.key, required this.reciterName});

  @override
  State<Reciter_ImageWidget> createState() => _Reciter_ImageWidgetState();
}

class _Reciter_ImageWidgetState extends State<Reciter_ImageWidget> {
  @override
  void initState() {
    super.initState();
    storePhotoUrl();
  }

  CancelToken? _cancelToken;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel();
    super.dispose();
  }

  Future storePhotoUrl() async {
    // Only fetch if not already cached to save API calls
    if (getValue("${widget.reciterName} photo url") == null) {
      // Use UI Avatars as a reliable fallback since Google API is down
      final encodedName = Uri.encodeComponent(widget.reciterName);
      final avatarUrl = "https://ui-avatars.com/api/?name=$encodedName&size=200&background=random&color=fff&font-size=0.4";
      
      updateValue("${widget.reciterName} photo url", avatarUrl);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String? photoUrl = getValue("${widget.reciterName} photo url");

    if (photoUrl != null) {
      return CachedNetworkImage(
        imageUrl: photoUrl,
        fit: BoxFit.cover,
        width: double.infinity, // Keep width to fill width of container
        // height: double.infinity, // REMOVED to prevent infinite height error in IntrinsicHeight
        placeholder: (context, url) => Center(
            child: Icon(Icons.mic,
                size: 30.sp, color: primaryColor.withOpacity(0.5))),
        errorWidget: (context, url, error) =>
            Center(child: Icon(Icons.mic, size: 40.sp, color: primaryColor)),
      );
    }

    return Center(
      child: Icon(Icons.mic, size: 40.sp, color: primaryColor),
    );
  }
}

class AudioHomeScreen extends StatefulWidget {
  const AudioHomeScreen({super.key, required this.jsonData});
  final dynamic jsonData;

  @override
  _AudioHomeScreenState createState() => _AudioHomeScreenState();
}

class _AudioHomeScreenState extends State<AudioHomeScreen> {
  // ... (no changes to state logic) ...
  late List<Reciter> reciters;
  bool isLoading = true;
  late Dio dio;
  List<ReciterMoshafItem> favoriteRecitersList = [];

  @override
  void initState() {
    super.initState();
    reciters = [];
    dio = Dio();
    // getFavoriteList(); // Moved to fetchReciters to ensure data exists
    fetchReciters();
  }

  // ... (omitting unchanged methods) ...

  void sortReciters() {
    Set<int> favoriteIds =
        favoriteRecitersList.map<int>((e) => e.reciter.id).toSet();

    flattenedReciters.sort((a, b) {
      bool isAFavorite = favoriteIds.contains(a.reciter.id);
      bool isBFavorite = favoriteIds.contains(b.reciter.id);

      if (isAFavorite && !isBFavorite) return -1;
      if (!isAFavorite && isBFavorite) return 1;

      return a.reciter.name.compareTo(b.reciter.name);
    });

    if (searchQuery.isNotEmpty) {
      filterReciters(searchQuery);
    } else {
      filteredFlattenedReciters = List.from(flattenedReciters);
    }
  }

  List<String>? getLettersForLocale(String locale) {
    for (var language in languagesLetters) {
      if (language.containsKey(locale)) {
        return language[locale];
      }
    }
    return [];
  }

  getFavoriteList() {
    var jsonData = getValue("favoriteRecitersList");
    if (jsonData != null) {
      final data = json.decode(jsonData) as List<dynamic>;

      // No setState needed here if called inside fetchReciters before final setState
      favoriteRecitersList = [];
      for (var reciterId in data) {
        // Using firstWhere or where to find matches
        var matches = flattenedReciters
            .where((element) => element.reciter.id == reciterId)
            .toList();
        favoriteRecitersList.addAll(matches);
      }
    }
  }

  final ContainerTransitionType _transitionType =
      ContainerTransitionType.fadeThrough;
  List<ReciterMoshafItem> flattenedReciters = [];
  List<ReciterMoshafItem> filteredFlattenedReciters = [];
  List<Moshaf> rewayat = [];
  List suwar = [];

  getAndStoreRecitersData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final apiClient = ApiClient();
      final languageParam = context.locale.languageCode == "en" ? "eng" : context.locale.languageCode;
      
      final response = await apiClient.get('${ApiConstants.recitersEndpoint}?language=$languageParam');
      final response2 = await apiClient.get('${ApiConstants.moshafEndpoint}?language=$languageParam');
      final response3 = await apiClient.get('${ApiConstants.suwarEndpoint}?language=$languageParam');

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

  Future<void> fetchReciters() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString(
              "reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}") ==
          null) {
        await getAndStoreRecitersData();
      }

      final jsonData = prefs.getString(
          "reciters-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}");
      final jsonData2 = prefs.getString(
          "moshaf-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}");
      final jsonData3 = prefs.getString(
          "suwar-${context.locale.languageCode == "en" ? "eng" : context.locale.languageCode}");

      if (jsonData != null) {
        // Use compute to parse in background
        reciters = await compute(parseReciters, jsonData);

        // Flatten the list
        flattenedReciters = [];
        for (var reciter in reciters) {
          for (var moshaf in reciter.moshaf) {
            flattenedReciters
                .add(ReciterMoshafItem(reciter: reciter, moshaf: moshaf));
          }
        }

        final data2 = await compute(parseMoshafs, jsonData2!);
        rewayat = (data2["riwayat"] as List)
            .map((reciter) => Moshaf.fromJson(reciter))
            .toList();

        final data3 = await compute(parseSuwar, jsonData3!);
        suwar = data3;

        // Apply Favorites and Sort
        getFavoriteList();
        sortReciters();

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Failed to load data. Please check internet connection.");
      }
    } catch (error) {
      print('Error while fetching data: $error');
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Error: $error");
    }
  }

  void filterReciters(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredFlattenedReciters = flattenedReciters.where((item) {
        return item.reciter.name.toLowerCase().contains(lowerQuery);
      }).toList();
    });

    if (scrollController.hasClients) {
      scrollController.animateTo(0,
          duration: const Duration(seconds: 1), curve: Curves.easeInOut);
    }
  }

  getRewayaReciters(String id) {
    filteredFlattenedReciters = [];
    for (var element in flattenedReciters) {
      if (element.moshaf.id.toString() == id) {
        filteredFlattenedReciters.add(element);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  ScrollController scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  var searchQuery = "";
  var selectedMode = "all";
  @override
  Widget build(BuildContext context) {
    var recitersToDisplay = selectedMode == "favorite"
        ? favoriteRecitersList
        : filteredFlattenedReciters;
// ... (omitting unchanging parts of build) ...
    final screenSize = MediaQuery.of(context).size;
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
          "allReciters".tr(),
          style: const TextStyle(
              color: Color(0xffe0cb8a),
              fontWeight: FontWeight.bold,
              fontFamily: "cairo"),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xffe0cb8a),
            )),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Column(
        children: [
          // Search Bar Area
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            decoration: BoxDecoration(
              color:
                  getValue("darkMode") ? darkModeSecondaryColor : primaryColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                Row(
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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
                                  filterReciters(value);
                                },
                                decoration: InputDecoration(
                                  hintText: "searchreciters".tr(),
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
                                icon: const Icon(Icons.close,
                                    color: Colors.white70),
                                onPressed: () {
                                  textEditingController.clear();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  setState(() {
                                    searchQuery = "";
                                    filterReciters("");
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
                            _showFilterSheet(context);
                          },
                          icon: const Icon(FontAwesome.sliders,
                              color: Colors.black87)),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
                      itemCount: recitersToDisplay.length,
                      itemBuilder: (context, index) {
                        final item = recitersToDisplay[index];
                        final reciter = item.reciter;
                        final moshaf = item.moshaf;

                        return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50,
                              child: FadeInAnimation(
                                child:
                                    _buildReciterCard(context, reciter, moshaf),
                              ),
                            ));
                      },
                    ),
                  ),
          )
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
        backgroundColor:
            getValue("darkMode") ? const Color(0xff2d2d2d) : Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.all_inclusive, color: primaryColor),
                  title: Text("all".tr(),
                      style: TextStyle(
                          color: getValue("darkMode")
                              ? Colors.white
                              : Colors.black)),
                  onTap: () {
                    setState(() {
                      selectedMode = "all";
                    });
                    Navigator.pop(context);
                    filterReciters(searchQuery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.redAccent),
                  title: Text("favorites".tr(),
                      style: TextStyle(
                          color: getValue("darkMode")
                              ? Colors.white
                              : Colors.black)),
                  onTap: () {
                    setState(() {
                      selectedMode = "favorite";
                    });
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: rewayat
                        .map((e) => ListTile(
                              leading: Image.asset(
                                  "assets/images1/reading.webp",
                                  height: 24,
                                  color: primaryColor),
                              title: Text(e.name,
                                  style: TextStyle(
                                      color: getValue("darkMode")
                                          ? Colors.white
                                          : Colors.black)),
                              onTap: () {
                                Navigator.pop(context);
                                getRewayaReciters(e.id.toString());
                                setState(() {
                                  selectedMode = "filtered"; // Custom mode
                                });
                              },
                            ))
                        .toList(),
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget _buildReciterCard(
      BuildContext context, Reciter reciter, Moshaf moshaf) {
    bool isFavorite =
        favoriteRecitersList.any((element) => element.reciter.id == reciter.id);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      // height: 140.h, // Removed fixed height to prevent overflow
      decoration: BoxDecoration(
        color: getValue("darkMode") ? darkModeSecondaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: IntrinsicHeight(
          // Ensure both sides stretch
          child: Stack(
            children: [
              // Background Decoration (Optional Pattern)
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    "assets/images1/al-munner.png", // Assuming this exists or similar
                    width: 150.w,
                    color: Colors.black,
                  ),
                ),
              ),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Stretch children vertically
                children: [
                  // Left Image/Side
                  Container(
                    width: 100.w,
                    height: 50
                        .h, // Minimum height to prevent intrinsic high calculation issues
                    decoration: BoxDecoration(
                      color: const Color(0xffe0cb8a)
                          .withOpacity(0.2), // Light Gold bg
                    ),
                    child: Reciter_ImageWidget(reciterName: reciter.name),
                  ),

                  // Right Content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            reciter.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: "cairo",
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: getValue("darkMode")
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              moshaf.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          FittedBox(
                            // Prevent button overflow
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (suwar.isEmpty) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Data is loading, please wait..."
                                                    .tr());
                                        return;
                                      }
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (builder) =>
                                                  BlocProvider(
                                                    create: (context) =>
                                                        playerPageBloc,
                                                    child:
                                                        ReciterSurahsScreen(
                                                      reciter: reciter,
                                                      mushaf: moshaf,
                                                      jsonData: suwar,
                                                    ),
                                                  )));
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                        color: getValue("darkMode")
                                            ? const Color(0xffe0cb8a)
                                            : primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(30.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.play_arrow_rounded,
                                              color: getValue("darkMode")
                                                  ? Colors.black
                                                  : Colors.white,
                                              size: 18),
                                          SizedBox(width: 4.w),
                                          Text(
                                            "Listen".tr(),
                                            style: TextStyle(
                                                color: getValue("darkMode")
                                                    ? Colors.black
                                                    : Colors.white,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                // Download Button
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      final appDir = Directory(
                                          "/storage/emulated/0/Download/Al-Munner/");
                                      List<String> surahNumbers =
                                          moshaf.surahList.split(',');
                                      bool allExist =
                                          surahNumbers.every((element) {
                                        // TODO: check if this file naming is consistent with app logic
                                        return File(
                                                "${appDir.path}${reciter.name}-${moshaf.id}-${getSurahNameArabic(int.parse(element))}.mp3")
                                            .existsSync();
                                      });

                                      if (allExist) {
                                        Fluttertoast.showToast(
                                            msg: "Files already downloaded",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.grey,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "downloading".tr(),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.black,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        playerPageBloc.add(DownloadAllSurahs(
                                            moshaf: moshaf, reciter: reciter));
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: getValue("darkMode")
                                                  ? const Color(0xffe0cb8a)
                                                  : primaryColor),
                                          shape: BoxShape.circle),
                                      child: Icon(Icons.download_rounded,
                                          color: getValue("darkMode")
                                              ? const Color(0xffe0cb8a)
                                              : primaryColor,
                                          size: 18.sp),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                    width: 40
                                        .w), // Replaces Spacer for FittedBox compatibility
                                IconButton(
                                  onPressed: () {
                                    if (isFavorite) {
                                      favoriteRecitersList.removeWhere(
                                          (e) => e.reciter.id == reciter.id);
                                      List<int> ids = favoriteRecitersList
                                          .map<int>((e) => e.reciter.id)
                                          .toSet()
                                          .toList();
                                      updateValue("favoriteRecitersList",
                                          json.encode(ids));
                                    } else {
                                      favoriteRecitersList.add(
                                          ReciterMoshafItem(
                                              reciter: reciter,
                                              moshaf: moshaf));
                                      List<int> ids = favoriteRecitersList
                                          .map<int>((e) => e.reciter.id)
                                          .toSet()
                                          .toList();
                                      updateValue("favoriteRecitersList",
                                          json.encode(ids));
                                    }
                                    sortReciters(); // Sort immediately
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    isFavorite
                                        ? FontAwesome.heart
                                        : FontAwesome.heart_empty,
                                    color: isFavorite
                                        ? Colors.redAccent
                                        : Colors.grey,
                                    size: 20.sp,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
