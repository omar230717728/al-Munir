import 'package:flutter/material.dart';

class CustomPageViewScrollPhysics extends PageScrollPhysics {
  const CustomPageViewScrollPhysics({super.parent});

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 400.0; 
}


