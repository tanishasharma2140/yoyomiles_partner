import 'package:flutter/cupertino.dart';

class Sizes{

  static late double screenWidth;
  static late double screenHeight;

  static void init(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
  }


  static double get fontSizeZero => screenWidth < 500 ? screenWidth / 80 : screenWidth / 90;
  static double get fontSizeOne => screenWidth < 500 ? screenWidth / 60 : screenWidth / 70;
  static double get fontSizeTwo => screenWidth < 500 ? screenWidth / 50 : screenWidth / 60;
  static double get fontSizeThree => screenWidth < 500 ? screenWidth / 40 : screenWidth / 50;
  static double get fontSizeFour => screenWidth < 500 ? screenWidth / 35 : screenWidth / 45;
  static double get fontSizeFive => screenWidth < 500 ? screenWidth / 28 : screenWidth / 38;
  static double get fontSizeSix => screenWidth < 500 ? screenWidth / 23 : screenWidth / 33;
  static double get fontSizeSeven => screenWidth < 500 ? screenWidth / 20 : screenWidth / 30;
  static double get fontSizeEight => screenWidth < 500 ? screenWidth / 18 : screenWidth / 28;
  static double get fontSizeNine => screenWidth < 500 ? screenWidth / 16 : screenWidth / 26;
  static double get fontSizeTen => screenWidth < 500 ? screenWidth / 14 : screenWidth / 24;

}