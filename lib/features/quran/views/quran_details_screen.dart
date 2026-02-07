import 'dart:async';
import 'dart:convert';


import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/scheduler.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:al_munir/features/quran/data/remove_html_tags.dart';
import 'package:al_munir/features/quran/widgets/bookmark_dialog.dart';

import '../data/translation/get_translation_data.dart' as get_translation_data;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:al_munir/blocs/bloc/player_bloc_bloc.dart';
import 'package:al_munir/blocs/bloc/quran_page_player_bloc.dart';
import 'package:al_munir/core/utilis/logger.dart';
import 'package:al_munir/features/quran/data/translation/translationdata.dart';
import 'package:al_munir/models/TranslationInfo.dart';
import 'package:al_munir/models/reciter.dart';
import 'package:al_munir/features/quran/data/convertNumberToAr.dart';
import 'package:al_munir/features/quran/views/screenshot_preview_screen.dart';
import 'package:al_munir/features/quran/widgets/header_widget.dart';
import 'package:al_munir/features/quran/widgets/tafseer_and_translation_sheet.dart';
import 'package:al_munir/features/quran/data/custom_page_view_scroll_physics.dart';
import 'package:al_munir/features/quran/data/quran_page_utils.dart';
import 'package:al_munir/features/quran/data/result.dart';
import 'package:al_munir/features/quran/data/scroll_listener.dart';
import 'package:al_munir/features/quran/widgets/widget_span_wrapper.dart';
import 'package:al_munir/features/quran/widgets/details_page/quran_page_header.dart';
import 'package:al_munir/features/quran/widgets/details_page/quran_page_view.dart';
import 'package:al_munir/features/quran/widgets/details_page/quran_vertical_view.dart';
import 'package:al_munir/features/quran/widgets/details_page/quran_verse_by_verse_view.dart';
import 'package:al_munir/features/quran/data/quran_data_source.dart';
import 'package:al_munir/features/home/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran/quran.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:easy_container/easy_container.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:al_munir/core/constants.dart';
import 'package:al_munir/core/hive_helper.dart';
import 'package:al_munir/features/quran/widgets/quran_settings_drawer.dart';
import 'package:quran/quran.dart' as quran;

import 'package:al_munir/features/quran/widgets/details_page/ayah_options_sheet.dart';

import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';
import 'package:arabic_roman_conv/arabic_roman_conv.dart';
import '../data/translation/get_translation_data.dart' as translate;
import 'package:syncfusion_flutter_sliders/sliders.dart';

class QuranReadingPage extends StatefulWidget {
  const QuranReadingPage({super.key});

  @override
  State<QuranReadingPage> createState() => _QuranReadingPageState();
}

class _QuranReadingPageState extends State<QuranReadingPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class QuranDetailsPage extends StatefulWidget {
  int pageNumber;
  var jsonData;
  var quarterJsonData;
  var shouldHighlightText;
  var highlightVerse;
  var shouldHighlightSura;
  // var highlighSurah;
  QuranDetailsPage(
      {super.key,
      required this.pageNumber,
      required this.jsonData,
      required this.shouldHighlightText,
      required this.highlightVerse,
      required this.quarterJsonData,
      required this.shouldHighlightSura});

  @override
  State<QuranDetailsPage> createState() => QuranDetailsPageState();
}

class QuranDetailsPageState extends State<QuranDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  // var controller;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  // final bool _isScrolling = false;

  // List bookmarks = [
  //   getValue("greenBookmark"),
  //   getValue("redBookmark"),
  //   getValue("blueBookmark"),
  // ];

  // reloadBookmarks() {
  //   setState(() {
  //     bookmarks = [
  //       getValue("greenBookmark"),
  //       getValue("redBookmark"),
  //       getValue("blueBookmark"),
  //     ];
  //   });
  // }
  List bookmarks = [];
  fetchBookmarks() {
    bookmarks = json.decode(getValue("bookmarks"));
    setState(() {});
    // print(bookmarks);
  }

  var dataOfCurrentTranslation;
  getTranslationData() async {
    if (getValue("indexOfTranslationInVerseByVerse") > 1) {
      File file = File(
          "${appDir!.path}/${translationDataList[getValue("indexOfTranslationInVerseByVerse")].typeText}.json");

      String jsonData = await file.readAsString();
      dataOfCurrentTranslation = json.decode(jsonData);
    }
    setState(() {});
  }

  var currentVersePlaying;
  // late final ScrollController _controller;
  int index = 0;
  setIndex() {
    setState(() {
      index = widget.pageNumber;
    });
  }

  double valueOfSlider = 0;

  late Timer timer;
  Directory? appDir;
  initialize() async {
    appDir = await getTemporaryDirectory();
    getTranslationData();
    if (mounted) {
      setState(() {});
    }
  }

  checkIfSelectHighlight() async {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (selectedSpan != "") {
        setState(() {
          selectedSpan = "";
        });
      }
    });
  }

  int playIndexPage = 0;

  @override
  void initState() {
    fetchBookmarks();
    //var formatter = NumberFormat('', 'ar');print("ننتاا");
    initialize();
    getTranslationData();
    // reloadBookmarks();
    // verticalScrollController.addListener((event) {
    //   _handleCallbackEvent(event.direction, event.success);
    // });
    checkIfSelectHighlight();
    setIndex();

    changeHighlightSurah();
    // _model = ScrollListener.initialise(controller);

    highlightVerseFunction();
    _scrollController.addListener(_scrollListener);

    _updateOrientation();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pageController = PageController(initialPage: index);
    _pageController.addListener(_pagecontroller_scrollListner);
    // assignPageNumberToIndex+1();
    // addTextSpans(); // TODO: implement initState
    WakelockPlus.enable();
    updateValue("lastRead", widget.pageNumber);
    addReciters(); // addValueToFontSize();
    // updateValue("quranPageolorsIndex", 0);
    super.initState();
  }

  void _updateOrientation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _scrollListener() {
    if (_scrollController.position.isScrollingNotifier.value &&
        selectedSpan != "") {
      setState(() {
        selectedSpan = "";
      });
    } else {}
  }

  void _pagecontroller_scrollListner() {
    if (_pageController.position.isScrollingNotifier.value &&
        selectedSpan != "") {
      setState(() {
        selectedSpan = "";
      });
    } else {}
  }

  var highlightVerse;
  var shouldHighlightText;
  changeHighlightSurah() async {
    await Future.delayed(const Duration(seconds: 2));
    widget.shouldHighlightSura = false;
  }

  highlightVerseFunction() {
    setState(() {
      shouldHighlightText = widget.shouldHighlightText;
    });
    if (widget.shouldHighlightText) {
      setState(() {
        highlightVerse = widget.highlightVerse;
      });

      Timer.periodic(const Duration(milliseconds: 400), (timer) {
        if (mounted) {
          setState(() {
            shouldHighlightText = false;
          });
        }
        Timer(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              shouldHighlightText = true;
            });
          }
          if (timer.tick == 4) {
            if (mounted) {
              setState(() {
                highlightVerse = "";

                shouldHighlightText = false;
              });
            }
            timer.cancel();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    WakelockPlus.disable();
    getTotalCharacters(quran.getVersesTextByPage(widget.pageNumber));
    super.dispose();
  }

  int total = 0;
  int total1 = 0;
  int total3 = 0;
  int getTotalCharacters(List<String> stringList) {
    return QuranPageUtils.getTotalCharacters(stringList);
  }

  checkIfAyahIsAStartOfSura() {}
  String? swipeDirection;
  late PageController _pageController;

  var english = RegExp(r'[a-zA-Z]');

  String selectedSpan = "";

  ScreenshotController screenshotController = ScreenshotController();

  double currentHeight = 2.0;
  // double currentWordSpacing = 0.0;
  double currentLetterSpacing = 0.0;


  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: QuranSettingsDrawer(
        onUpdate: () {
          _updateOrientation();
          setState(() {});
        },
      ),
      backgroundColor: Colors.transparent,
      body: Builder(builder: (context) {
        bool isLandscape = getValue("quran_landscape_mode") ?? false;
        Widget content;
        if (getValue("alignmentType") == "pageview") {
          content = QuranPageView(
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                selectedSpan = "";
              });
              this.index = index;
              updateValue("lastRead", index);
            },
            onBack: () => Navigator.pop(context),
            onSettings: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
            onShowAyahOptions: (p, s, v) => showAyahOptionsSheet(p, s, v),
            bookmarks: bookmarks,
            jsonData: widget.jsonData,
            quarterJsonData: widget.quarterJsonData,
            shouldHighlightText: widget.shouldHighlightText,
            highlightVerse: widget.highlightVerse,
            index: index,
            savedPageBookmarkIndex: getValue("savedPageBookmark") ?? -1,
            onBookmarkPage: (pageIndex) => handlePageBookmark(pageIndex),
          );
        } else if (getValue("alignmentType") == "verticalview") {
          content = QuranVerticalView(
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            onPageChanged: (i) {
              this.index = i;
              updateValue("lastRead", i);
            },
            bookmarks: bookmarks,
            jsonData: widget.jsonData,
            quarterJsonData: widget.quarterJsonData,
            shouldHighlightText: widget.shouldHighlightText,
            highlightVerse: widget.highlightVerse,
            onShowAyahOptions: (p, s, v) => showAyahOptionsSheet(p, s, v),
          );
        } else {
          content = QuranVerseByVerseView(
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            onPageChanged: (i) {
              this.index = i;
              updateValue("lastRead", i);
            },
            bookmarks: bookmarks,
            jsonData: widget.jsonData,
            shouldHighlightText: widget.shouldHighlightText,
            highlightVerse: widget.highlightVerse,
            onShowAyahOptions: (p, s, v) => showAyahOptionsSheet(p, s, v),
            translationDataList: translationDataList,
            dataOfCurrentTranslation: dataOfCurrentTranslation,
            isVerseStarred: isVerseStarred,
            onBack: () => Navigator.pop(context),
          );
        }
        return RotatedBox(quarterTurns: isLandscape ? 3 : 0, child: content);
      }),
    );
  }

  showAyahOptionsSheet(index, surahNumber, verseNumber) {
    AyahOptionsSheet.show(
      context,
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      index: index,
      bookmarks: bookmarks,
      jsonData: widget.jsonData,
      onAddBookmark: (s, v) async {
        List<String> colorOptions = [
          "0xFF2196F3",
          "0xFFF44336",
          "0xFFE91E63",
          "0xFF9C27B0",
          "0xFF3F51B5"
        ];
        String selectedColor = colorOptions[0];
        bookmarks.add({
          "suraNumber": s,
          "verseNumber": v,
          "name":
              "${"surah".tr()} ${context.locale.languageCode == "ar" ? quran.getSurahNameArabic(s) : quran.getSurahNameEnglish(s)} - ${"ayah".tr()} $v",
          "color": selectedColor.replaceAll("0x", "")
        });
        updateValue("bookmarks", json.encode(bookmarks));
        setState(() {});
      },
      onRemoveBookmark: (s, v) {
        bookmarks.removeWhere((element) =>
            element["suraNumber"] == s && element["verseNumber"] == v);
        updateValue("bookmarks", json.encode(bookmarks));
        setState(() {});
      },
      isVerseStarred: isVerseStarred,
      onToggleStar: (s, v) {
        if (isVerseStarred(s, v)) {
          removeStarredVerse(s, v);
        } else {
          addStarredVerse(s, v);
        }
        setState(() {});
      },
    );
  }

  bool showSuraHeader = true;
  bool addAppSlogan = true;

  Set<String> starredVerses = {};

  addStarredVerse(int surahNumber, int verseNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the data as a string, not as a map
    final String? savedData = prefs.getString("starredVerses");

    if (savedData != null) {
      // Decode the JSON string to a List<String>
      starredVerses = Set<String>.from(json.decode(savedData));
    }

    final verseKey = "$surahNumber-$verseNumber"; // Create a unique key
    starredVerses.add(verseKey);

    final jsonData = json.encode(
        starredVerses.toList()); // Convert Set to List for serialization
    prefs.setString("starredVerses", jsonData);
    Fluttertoast.showToast(msg: "Added to Starred verses");
  }

  removeStarredVerse(int surahNumber, int verseNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the data as a string, not as a map
    final String? savedData = prefs.getString("starredVerses");

    if (savedData != null) {
      // Decode the JSON string to a List<String>
      starredVerses = Set<String>.from(json.decode(savedData));
    }

    final verseKey = "$surahNumber-$verseNumber"; // Create the same unique key
    starredVerses.remove(verseKey);

    final jsonData = json.encode(
        starredVerses.toList()); // Convert Set to List for serialization
    prefs.setString("starredVerses", jsonData);
    Fluttertoast.showToast(msg: "Removed from Starred verses");
  }

  bool isVerseStarred(int surahNumber, int verseNumber) {
    final verseKey = "$surahNumber-$verseNumber";
    return starredVerses.contains(verseKey);
  }

  bool isDownloading = false;

  void handlePageBookmark(int pageIndex) {
    int? savedPage = getValue("savedPageBookmark");
    if (savedPage == null || savedPage == -1) {
      savePageBookmark(pageIndex);
    } else if (savedPage == pageIndex) {
      // Toggle off (remove)
      removePageBookmark();
    } else {
      // Different page exists
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "replace_bookmark".tr(),
            style: TextStyle(fontFamily: "cairo"),
          ),
          content: Text(
            "replace_bookmark_desc".tr(),
            style: TextStyle(fontFamily: "cairo"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "cancel".tr(),
                style: TextStyle(fontFamily: "cairo"),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                savePageBookmark(pageIndex);
              },
              child: Text(
                "replace".tr(),
                style: TextStyle(fontFamily: "cairo"),
              ),
            ),
          ],
        ),
      );
    }
  }

  void savePageBookmark(int pageIndex) async {
    await updateValue("savedPageBookmark", pageIndex);
    setState(() {});
    Fluttertoast.showToast(msg: "page_saved".tr());
  }

  void removePageBookmark() async {
    await updateValue("savedPageBookmark", -1);
    setState(() {});
  }
}
