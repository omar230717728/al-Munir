import 'package:al_munir/core/hive_helper.dart';
import 'package:quran/quran.dart';

initHiveValues() async {
  nullValidator("headerPhotoIndex", 0);
  nullValidator("quranPageolorsIndex", 0);
  
  // Migration: Robust check for Old Default (2) -> New Default (0)
  // This is safe to run inside initHiveValues as it's just a value check/update
  var currentTheme = getValue("quranPageolorsIndex");
  if (currentTheme == 2 || currentTheme.toString() == "2") {
    updateValue("quranPageolorsIndex", 0);
  }

  nullValidator("selectedFontFamily", "UthmanicHafs13");

  nullValidator("pageViewFontSize", 23);
  nullValidator("verseByVerseFontSize", 24);
  nullValidator("verticalViewFontSize", 22);

  nullValidator("currentHeight", 2.0);
  // nullValidator("currentWordSpacing", 0.0);
  nullValidator("currentLetterSpacing", 0.0);
  nullValidator("lastRead", "non");
  nullValidator("alignmentType", "pageview");
  nullValidator("addAppSlogan", true);
  nullValidator("showSuraHeader", true);
  nullValidator("textWithoutDiacritics", false);
  nullValidator("selectedShareTypeIndex", 0);
  nullValidator("showTafseerOrTranslation", true);
  nullValidator("translationName", "enSaheeh");
  nullValidator("reciterIndex", 0);
  nullValidator("favoriteRecitersList", "[]");
  nullValidator("favoriteSurahList", "[]");
  nullValidator("downloadedSurahs", "[]");

  nullValidator("addTafseerValue", 0);
  nullValidator("addTafseer", false);
  nullValidator("showBottomBar", false);
  nullValidator("shouldShowAyahNotification", true);
  nullValidator("shouldShowZikrNotification", true);
  nullValidator("shouldShowZikrNotification2", true);
  nullValidator("shouldShowSallyNotification", true);

  nullValidator("shouldUsePrayerTimes", false);

  nullValidator("timesForShowingAyahNotifications", 0); // 15 min
  nullValidator("timesForShowingZikrNotifications", 2); // 25 min (Third one)
  nullValidator("zikrNotificationindex", 0);
  nullValidator("timesForShowingZikrNotifications2", 1); // 20 min (Second one)
  nullValidator("zikrNotificationindex2", 0);
  nullValidator("indexOfTranslation", 0);
  nullValidator("indexOfTranslationInVerseByVerse", 1);
  nullValidator("darkMode", false);

  nullValidator("bookmarks", "[]");

  nullValidator("timesOfAppOpen", 0);
  nullValidator("showedDialog", false);
}
