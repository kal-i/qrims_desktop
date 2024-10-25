import 'package:flutter/material.dart';
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
    dividerColor: AppColor.lightOutlineBorder,
    cardColor: AppColor.lightCardColor,
    canvasColor: AppColor.lightCanvasColor,
    fontFamily: 'Inter',
    iconTheme: const IconThemeData(
      color: AppColor.icon,
      size: 20.0,
    ),
    primaryColor: AppColor.lightPrimary,
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
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: AppColor.accent,
        fontSize: 13.0,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        color: AppColor.lightDescriptionText,
        fontSize: 13.0,
        fontWeight: FontWeight.w500,
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
    dividerColor: AppColor.darkOutlineBorder,
    fontFamily: 'Inter',
    iconTheme: const IconThemeData(
      color: AppColor.icon,
      size: 20.0,
    ),
    primaryColor: AppColor.darkPrimary,
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
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        color: AppColor.darkHighlightedText,
        fontSize: 13.0,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        color: AppColor.darkDescriptionText,
        fontSize: 13.0,
        fontWeight: FontWeight.w500,
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