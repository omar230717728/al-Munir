import 'package:easy_container/easy_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:al_munir/core/constants.dart';
import 'package:al_munir/core/hive_helper.dart';

class QuranSettingsDrawer extends StatefulWidget {
  final VoidCallback onUpdate;
  const QuranSettingsDrawer({Key? key, required this.onUpdate})
      : super(key: key);

  @override
  State<QuranSettingsDrawer> createState() => _QuranSettingsDrawerState();
}

class _QuranSettingsDrawerState extends State<QuranSettingsDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.height,
      color: backgroundColors[getValue("quranPageolorsIndex") ?? 0]
          .withOpacity(0.8),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Text(
              "settings".tr(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: primaryColors[getValue("quranPageolorsIndex") ?? 0],
                fontFamily: "cairo",
              ),
            ),
            Divider(color: primaryColors[getValue("quranPageolorsIndex") ?? 0]),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  // Font Size Section
                  Text(
                    "fontsize".tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color:
                          secondaryColors[getValue("quranPageolorsIndex") ?? 0],
                      fontFamily: "cairo",
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(Icons.text_fields, size: 16.sp, color: Colors.grey),
                      Expanded(
                        child: Slider(
                          value: (getValue("verticalViewFontSize") ?? 20)
                              .toDouble(),
                          min: 15,
                          max: 50,
                          activeColor: secondaryColors[
                              getValue("quranPageolorsIndex") ?? 0],
                          onChanged: (val) {
                            updateValue("verticalViewFontSize", val.toInt());
                            updateValue("pageViewFontSize", val.toInt());
                            updateValue("verseByVerseFontSize", val.toInt());
                            widget.onUpdate();
                            setState(() {});
                          },
                        ),
                      ),
                      Icon(Icons.text_fields, size: 28.sp, color: Colors.grey),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Text Alignment Section
                  Text(
                    "alignment"
                        .tr(), // Ensure key exists or use "Text Alignment"
                    style: TextStyle(
                      fontSize: 16.sp,
                      color:
                          secondaryColors[getValue("quranPageolorsIndex") ?? 0],
                      fontFamily: "cairo",
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<TextAlign>(
                          title: Text("center".tr(),
                              style: TextStyle(
                                  fontFamily: "cairo", fontSize: 14.sp)),
                          value: TextAlign.center,
                          groupValue: getValue("textAlignIndex") == 1
                              ? TextAlign.justify
                              : TextAlign.center,
                          activeColor: secondaryColors[
                              getValue("quranPageolorsIndex") ?? 0],
                          onChanged: (val) {
                            updateValue("textAlignIndex", 0); // 0 for Center
                            widget.onUpdate();
                            setState(() {});
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<TextAlign>(
                          title: Text("justify".tr(),
                              style: TextStyle(
                                  fontFamily: "cairo", fontSize: 14.sp)),
                          value: TextAlign.justify,
                          groupValue: getValue("textAlignIndex") == 1
                              ? TextAlign.justify
                              : TextAlign.center,
                          activeColor: secondaryColors[
                              getValue("quranPageolorsIndex") ?? 0],
                          onChanged: (val) {
                            updateValue("textAlignIndex", 1); // 1 for Justify
                            widget.onUpdate();
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Reading Options Section
                  Text(
                    "readingOptions".tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color:
                          secondaryColors[getValue("quranPageolorsIndex") ?? 0],
                      fontFamily: "cairo",
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SwitchListTile(
                    activeColor:
                        secondaryColors[getValue("quranPageolorsIndex") ?? 0],
                    title: Text("allowLandscape".tr(),
                        style: TextStyle(fontFamily: "cairo", fontSize: 14.sp)),
                    value: getValue("quran_landscape_mode") ?? false,
                    onChanged: (val) {
                      updateValue("quran_landscape_mode", val);
                      widget.onUpdate();
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    activeColor:
                        secondaryColors[getValue("quranPageolorsIndex") ?? 0],
                    title: Text("enableZoom".tr(),
                        style: TextStyle(fontFamily: "cairo", fontSize: 14.sp)),
                    value: getValue("quran_zoom_mode") ?? false,
                    onChanged: (val) {
                      updateValue("quran_zoom_mode", val);
                      widget.onUpdate();
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 20.h),

                  // Themes Section
                  Text(
                    "choosetheme".tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color:
                          secondaryColors[getValue("quranPageolorsIndex") ?? 0],
                      fontFamily: "cairo",
                    ),
                  ),
                  SizedBox(height: 10.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // Adjust count as needed
                        childAspectRatio: 2.0, // Adjust for rectangle shape
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h),
                    itemCount: backgroundColors.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          updateValue("quranPageolorsIndex", index);
                          widget.onUpdate();
                          setState(() {});
                        },
                        child: Stack(
                          children: [
                            // Rectangle Background
                            Center(
                              child: Container(
                                width: 90.w, // Match previous width or adjust
                                height: 40.h,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 1,
                                          color: Colors.grey.withOpacity(.5))
                                    ],
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: backgroundColors[index],
                                    border:
                                        getValue("quranPageolorsIndex") == index
                                            ? Border.all(
                                                color: secondaryColors[index],
                                                width: 2)
                                            : null),
                              ),
                            ),
                            // Circle Overlay
                            Center(
                              child: Container(
                                  width: 20.w,
                                  height: 20.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryColors[index],
                                  ),
                                  child:
                                      getValue("quranPageolorsIndex") == index
                                          ? Icon(Icons.check,
                                              size: 12.sp,
                                              color: backgroundColors[index])
                                          : null),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Text(
                      "v1.0.0",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: "cairo",
                        color: secondaryColors[
                            getValue("quranPageolorsIndex") ?? 0],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
