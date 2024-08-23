import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'app_color.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.lightBackground,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColor.lightBackground
    ),
    brightness: Brightness.light,
    dividerColor: AppColor.lightOutline,
    cardColor: AppColor.lightCardColor,
    canvasColor: AppColor.lightCanvasColor,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColor.lightBackground,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColor.darkPrimary,
        fontSize: 32.0,
        fontWeight: FontWeight.w900,
      ),
      titleLarge: TextStyle(
        color: AppColor.darkPrimary,
        fontSize: 32.0,
        fontWeight: FontWeight.w900,
      ),
      titleMedium: TextStyle(
        color: AppColor.darkPrimary,
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        color: AppColor.lightSubTitleText,
        fontSize: 12.0,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: AppColor.lightTableColumnText,
        fontSize: 11.0,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        color: AppColor.lightTableRowText,
        fontSize: 11.0,
        fontWeight: FontWeight.w600,
      ),
      bodySmall: TextStyle(
        color: AppColor.lightDescriptionText,
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all<Color>(AppColor.accent),
    ),
    // todo: implement
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColor.lightBackground
    ),
    dialogTheme: const DialogTheme(

    ),
  );

  static ThemeData dark = ThemeData(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.darkBackground,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColor.darkBackground,
    ),
    brightness: Brightness.dark,
    canvasColor: AppColor.darkCanvasColor,
    cardColor: AppColor.darkCardColor,
    //cardColor: AppColor.darkSecondary,
    dividerColor: AppColor.darkOutline,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColor.darkBackground,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColor.lightPrimary,
        fontSize: 32.0,
        fontWeight: FontWeight.w900,
      ),
      titleLarge: TextStyle(
        color: AppColor.lightPrimary,
        fontSize: 32.0,
        fontWeight: FontWeight.w900,
      ),
      titleMedium: TextStyle(
        color: AppColor.lightPrimary,
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        color: AppColor.darkSubTitleText,
        fontSize: 12.0,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: AppColor.darkTableColumnText,
        fontSize: 11.0,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        color: AppColor.darkTableRowText,
        fontSize: 11.0,
        fontWeight: FontWeight.w600,
      ),
      bodySmall: TextStyle(
        color: AppColor.darkDescriptionText,
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all<Color>(AppColor.accent),
    ),
    // todo: implement
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColor.darkBackground,
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ),
    checkboxTheme: const CheckboxThemeData(side: BorderSide(color: AppColor.darkOutline, width: 1.5,),),
  );
}