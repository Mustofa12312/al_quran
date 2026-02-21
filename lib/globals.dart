import 'package:flutter/material.dart';

/// ===============================
/// WARNA GLOBAL
/// ===============================
Color backgroundColor = const Color(0xFF040C23);
Color secondaryColor = const Color(0xFF121931);
Color primaryColor = const Color(0xFFA44AFF);
Color accentColor = const Color(0xFFF9B091);
Color textColor = const Color(0xFFA19CC5);

// Aliases for compatibility with existing code
Color Gray = secondaryColor;
Color Primary = primaryColor;
Color textt = textColor;
Color Orange = accentColor;

/// ===============================
/// VISIBILITAS & MODE
/// ===============================
bool showTranslation = true;
bool autoScrollEnabled = false;

/// ===============================
/// FONT & TAMPILAN AYAT
/// ===============================
double arabFontSize = 28; // ukuran teks Arab
double translationFontSize = 14; // ukuran terjemah
double tafsirFontSize = 12; // (future ready)
double lineSpacing = 1.6; // jarak antar baris
double ayahSpacing = 24.0; // jarak antar ayat

/// ===============================
/// AUTO SCROLL
/// ===============================
double autoScrollSpeed = 25; // kecepatan scroll (px)

/// ===============================
/// AUDIO & TAFSIR (future)
/// ===============================
String audioSource = "Mishary Alafasy";
String tafsirSource = "Tafsir Kemenag";

/// ===============================
/// TERAKHIR DIBACA
/// ===============================
int lastReadSurah = 1;
int lastReadAyah = 1;

/// ===============================
/// UTIL: ANGKA ARAB (١ ٢ ٣)
/// ===============================
String toArabicNumber(int number) {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number
      .toString()
      .split('')
      .map((e) => arabicDigits[int.parse(e)])
      .join();
}
