import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//* NEW ELEGANT COLOR PALETTE
const Color cPrimary = Color(0xFF1A237E); // Indigo yang dalam
const Color cPrimaryLight = Color(0xFF534BAE);
const Color cAccent = Color(0xFFFFAB40); // Oranye sebagai aksen

// Light Theme Colors
const Color cBackgroundLight = Color(0xFFF5F5F7);
const Color cCardLight = Color(0xFFFFFFFF);
const Color cTextPrimaryLight = Color(0xFF212121);
const Color cTextSecondaryLight = Color(0xFF5F6368);

// Dark Theme Colors
const Color cBackgroundDark = Color(0xFF121212);
const Color cCardDark = Color(0xFF1E1E1E);
const Color cTextPrimaryDark = Color(0xFFE8EAED);
const Color cTextSecondaryDark = Color(0xFF9E9E9E);

//* ================================================================

//* Old Colors (can be removed later)
Color cTextBlue = const Color(0xff4E4B66);
Color cLinear = const Color(0xffA9B5DF);
Color cBlack = const Color(0xff000000);
Color cWhite = const Color(0xffFFFFFF);
Color cGrey = const Color(0xffF1F1F5);
Color cError = const Color(0xffD32F2F);
Color cSuccess = const Color(0xff388E3C);
const Color cwhite = Colors.white;

//* Spacing
const Widget hsSuperTiny = SizedBox(width: 4.0);
const Widget hsTiny = SizedBox(width: 8.0);
const Widget hsSmall = SizedBox(width: 12.0);
const Widget hsMedium = SizedBox(width: 16.0);
const Widget hsLarge = SizedBox(width: 24.0);
const Widget hsXLarge = SizedBox(width: 36.0);
const Widget vsSuperTiny = SizedBox(height: 4.0);
const Widget vsTiny = SizedBox(height: 8.0);
const Widget vsSmall = SizedBox(height: 12.0);
const Widget vsMedium = SizedBox(height: 16.0);
const Widget vsLarge = SizedBox(height: 24.0);
const Widget vsXLarge = SizedBox(height: 36.0);

//* Divider
Widget spacedDivider = Padding(
  padding: const EdgeInsets.symmetric(vertical: 12.0),
  child: Divider(color: cGrey.withOpacity(0.5), height: 1.0),
);

//* Screen
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

//* Font Weight
FontWeight thin = FontWeight.w100;
FontWeight extralight = FontWeight.w200;
FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight semibold = FontWeight.w600;
FontWeight bold = FontWeight.w700;
FontWeight extrabold = FontWeight.w800;

//* TextStyle
TextStyle headline1 = GoogleFonts.poppins(fontSize: 40);
TextStyle headline2 = GoogleFonts.poppins(fontSize: 34);
TextStyle headline3 = GoogleFonts.poppins(fontSize: 24);
TextStyle headline4 = GoogleFonts.poppins(fontSize: 20);
TextStyle subtitle1 = GoogleFonts.poppins(fontSize: 16);
TextStyle subtitle2 = GoogleFonts.poppins(fontSize: 14);
TextStyle caption = GoogleFonts.poppins(fontSize: 12);
TextStyle overline = GoogleFonts.poppins(fontSize: 10);