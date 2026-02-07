import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:al_munir/core/constants.dart';
import 'package:al_munir/core/hive_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:al_munir/features/azkar/model/dua_model.dart';

class ZikrPage extends StatefulWidget {
  DuaModel zikr;
  ZikrPage({super.key, required this.zikr});

  @override
  State<ZikrPage> createState() => _ZikrPageState();
}

class _ZikrPageState extends State<ZikrPage> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    if (getValue("${widget.zikr.category}zikrIndex") == null) {
      updateValue("${widget.zikr.category}zikrIndex", 0);
    }
  }

  int count = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          color: darkPrimaryColor,
          image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(
                "assets/images1/frameo.webp",
              ),
              alignment: Alignment.center,
              opacity: .15)),
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    SizedBox(
                        height:
                            (MediaQuery.of(context).size.height * .78) - 30.h,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                          child: SingleChildScrollView(
                            key: Key(
                                getValue("${widget.zikr.category}zikrIndex")
                                    .toString()),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 50.0.w),
                                    child: GestureDetector(
                                      onLongPress: () {
                                        Clipboard.setData(ClipboardData(
                                                text: widget
                                                    .zikr
                                                    .array[getValue(
                                                        "${widget.zikr.category}zikrIndex")]
                                                    .text))
                                            .then((value) =>
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Copied to Clipboard"));
                                      },
                                      child: Text(
                                        widget
                                            .zikr
                                            .array[getValue(
                                                "${widget.zikr.category}zikrIndex")]
                                            .text,
                                        textDirection: TextDirection.rtl,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            locale: const Locale("ar"),
                                            fontSize: 19.sp),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )

                        //      PageView.builder(
                        // onPageChanged: (c) {
                        //   updateValue("${widget.zikr.category}zikrIndex", c);
                        // },
                        // itemCount: widget.zikr.array.length,
                        // itemBuilder: (d, index) {
                        //   return SizedBox(
                        //     height: MediaQuery.of(context).size.height,
                        //     child: Column(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Padding(
                        //           padding:
                        //               EdgeInsets.symmetric(horizontal: 50.0.w),
                        //           child: Text(
                        //             widget.zikr.array[index].text,
                        //             textDirection: TextDirection.rtl,
                        //             textAlign: TextAlign.center,
                        //             style: TextStyle(
                        //                 color: Colors.white,
                        //                 locale: const Locale("ar"),
                        //                 fontSize: 19.sp),
                        //           ),
                        //         )
                        //       ],
                        //     ),
                        //   );
                        // }),
                        ),
                    SizedBox(
                      height: 10.h,
                    ),
                  ],
                )),
            Positioned(
                bottom: 30.h,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                          overlayColor: WidgetStatePropertyAll(
                              Colors.white.withOpacity(.25)),
                          splashColor: Colors.white.withOpacity(.25),
                          focusColor: Colors.white.withOpacity(.25),
                          hoverColor: Colors.white.withOpacity(.25),
                          highlightColor: Colors.white.withOpacity(.15),
                          borderRadius: BorderRadius.circular(200),
                          onTap: () {
                            count++;

                            setState(() {});
                          },
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                color: Colors.grey.withOpacity(.1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Text("$count",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "roboto")),
                              ),
                            ),
                          )),
                    ],
                  ),
                )),
            Positioned(
                width: MediaQuery.of(context).size.width,
                top: MediaQuery.of(context).size.height * .45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (getValue("${widget.zikr.category}zikrIndex") != 0) {
                          updateValue("${widget.zikr.category}zikrIndex",
                              getValue("${widget.zikr.category}zikrIndex") - 1);
                        }
                        setState(() {
                          count = 1;
                        });
                      },
                      child: Container(
                        height: 40.h,
                        width: 40.h,
                        decoration: const BoxDecoration(
                            color: Colors.transparent, shape: BoxShape.circle),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios,
                            color:
                                getValue("${widget.zikr.category}zikrIndex") ==
                                        0
                                    ? Colors.grey
                                    : Colors.white,
                            size: 28.sp,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (getValue("${widget.zikr.category}zikrIndex") + 1 !=
                            widget.zikr.array.length) {
                          updateValue("${widget.zikr.category}zikrIndex",
                              getValue("${widget.zikr.category}zikrIndex") + 1);
                          count = 1;
                        }

                        setState(() {});
                      },
                      child: Container(
                        height: 40.h,
                        width: 40.h,
                        decoration: const BoxDecoration(
                            color: Colors.transparent, shape: BoxShape.circle),
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color:
                                getValue("${widget.zikr.category}zikrIndex") +
                                            1 ==
                                        widget.zikr.array.length
                                    ? Colors.grey
                                    : Colors.white,
                            size: 28.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ),
        backgroundColor: Colors.transparent,
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
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xffe0cb8a),
              )),
          title: Text(
            widget.zikr.category,
            style: TextStyle(
                fontFamily: "cairo",
                color: const Color(0xffe0cb8a),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  updateValue("${widget.zikr.category}zikrIndex", 0);
                  count = 1;
                  setState(() {});
                },
                icon: const Icon(
                  Icons.replay_outlined,
                  color: Color(0xffe0cb8a),
                ))
          ],
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 4,
        ),
      ),
    );
  }
}
