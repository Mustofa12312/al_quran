import 'dart:convert';
import 'package:al_quran_fix/globals.dart';
import 'package:al_quran_fix/models/ayat.dart';
import 'package:al_quran_fix/models/surah.dart';
// import 'package:al_quran_fix/screens/search_screen.dart';
import 'package:al_quran_fix/services/bookmark_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailScreen extends StatefulWidget {
  final int noSurah;
  const DetailScreen({super.key, required this.noSurah});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ScrollController _scrollController = ScrollController();

  bool autoScroll = false;

  // ======================================================
  // AUTO SCROLL
  // ======================================================
  void startAutoScroll() async {
    autoScroll = true;
    setState(() {});

    while (autoScroll) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!_scrollController.hasClients) continue;

      final max = _scrollController.position.maxScrollExtent;
      final now = _scrollController.offset;

      if (now >= max) {
        stopAutoScroll();
        break;
      }

      _scrollController.animateTo(
        now + autoScrollSpeed,
        duration: const Duration(milliseconds: 120),
        curve: Curves.linear,
      );
    }
  }

  void stopAutoScroll() {
    autoScroll = false;
    setState(() {});
  }

  // ======================================================
  // FONT & SCROLL MENU
  // ======================================================
  void showFontMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Gray,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setSheet) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Pengaturan Tampilan",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _slider(
                    label: "Ukuran Arab",
                    value: arabFontSize,
                    min: 22,
                    max: 48,
                    onChanged: (v) {
                      arabFontSize = v;
                      setSheet(() {});
                      setState(() {});
                    },
                  ),

                  _slider(
                    label: "Ukuran Terjemah",
                    value: translationFontSize,
                    min: 12,
                    max: 28,
                    onChanged: (v) {
                      translationFontSize = v;
                      setSheet(() {});
                      setState(() {});
                    },
                  ),

                  _slider(
                    label: "Jarak Ayat",
                    value: ayahSpacing,
                    min: 10,
                    max: 40,
                    onChanged: (v) {
                      ayahSpacing = v;
                      setSheet(() {});
                      setState(() {});
                    },
                  ),

                  _slider(
                    label: "Kecepatan Scroll",
                    value: autoScrollSpeed,
                    min: 10,
                    max: 80,
                    onChanged: (v) {
                      autoScrollSpeed = v;
                      setSheet(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white70)),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: Primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ======================================================
  // LOAD DATA
  // ======================================================
  Future<Surah> loadSurah() async {
    final data = await rootBundle.loadString(
      "assets/datas/surah/${widget.noSurah}.json",
    );
    return Surah.fromJson(json.decode(data));
  }

  // ======================================================
  // UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Surah>(
      future: loadSurah(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return Scaffold(backgroundColor: backgroundColor);
        }

        final surah = snap.data!;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: _buildAppBar(surah),
          body: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: surah.ayat!.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) return _buildHeader(surah);
              return _buildAyat(surah.ayat![i - 1]);
            },
          ),
        );
      },
    );
  }

  // ======================================================
  // APP BAR
  // ======================================================
  AppBar _buildAppBar(Surah surah) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      title: Text(
        surah.namaLatin,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.text_fields),
          onPressed: showFontMenu,
        ),
        IconButton(
          icon: Icon(autoScroll ? Icons.pause_circle : Icons.play_circle_fill),
          onPressed: autoScroll ? stopAutoScroll : startAutoScroll,
        ),
      ],
    );
  }

  // ======================================================
  // HEADER
  // ======================================================
  Widget _buildHeader(Surah s) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: Column(
        children: [
          Text(
            s.namaLatin,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(s.arti, style: GoogleFonts.poppins(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            "${s.tempatTurun.name} • ${s.jumlahAyat} Ayat",
            style: GoogleFonts.poppins(color: textt),
          ),
          const SizedBox(height: 25),
          if (s.nomor != 1 && s.nomor != 9)
            SvgPicture.asset("assets/svgs/bismillah.svg", height: 55),
        ],
      ),
    );
  }

  // ======================================================
  // AYAT
  // ======================================================
  Widget _buildAyat(Ayat ayat) {
    return FutureBuilder<bool>(
      future: BookmarkService.isBookmarked(widget.noSurah, ayat.nomor),
      builder: (_, snap) {
        final active = snap.data ?? false;

        return Padding(
          padding: EdgeInsets.only(top: ayahSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER AYAT
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Primary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      toArabicNumber(ayat.nomor),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      active ? Icons.bookmark : Icons.bookmark_border,
                      color: active ? Primary : Colors.white,
                    ),
                    onPressed: () async {
                      active
                          ? await BookmarkService.removeBookmark(
                              widget.noSurah,
                              ayat.nomor,
                            )
                          : await BookmarkService.addBookmark(
                              widget.noSurah,
                              ayat.nomor,
                              ayat.ar,
                            );
                      setState(() {});
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ARAB
              SelectableText(
                ayat.ar,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: "Scheherazade",
                  fontSize: arabFontSize,
                  height: lineSpacing,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // TERJEMAH
              if (showTranslation)
                SelectableText(
                  ayat.idn,
                  textAlign: TextAlign.justify,
                  style: GoogleFonts.poppins(
                    fontSize: translationFontSize,
                    height: lineSpacing,
                    color: textt,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
