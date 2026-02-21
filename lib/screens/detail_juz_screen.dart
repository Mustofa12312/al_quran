import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/juz.dart';
import '../globals.dart';

class DetailJuzScreen extends StatefulWidget {
  final Juz juz;

  const DetailJuzScreen({super.key, required this.juz});

  @override
  State<DetailJuzScreen> createState() => _DetailJuzScreenState();
}

class _DetailJuzScreenState extends State<DetailJuzScreen> {
  final ScrollController _scrollController = ScrollController();

  bool autoScroll = false;

  // ============================================================
  //                      AUTO SCROLL
  // ============================================================
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

  // ============================================================
  //                    FONT SIZE MENU
  // ============================================================
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
                    "Pengaturan Teks",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Arab
                  Text(
                    "Teks Arab",
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                  Slider(
                    min: 20,
                    max: 48,
                    activeColor: Primary,
                    value: arabFontSize,
                    onChanged: (v) {
                      setSheet(() => arabFontSize = v);
                      setState(() {});
                    },
                  ),

                  // Terjemah
                  Text(
                    "Terjemahan",
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                  Slider(
                    min: 12,
                    max: 28,
                    activeColor: Primary,
                    value: translationFontSize,
                    onChanged: (v) {
                      setSheet(() => translationFontSize = v);
                      setState(() {});
                    },
                  ),

                  // Jarak Ayat
                  Text(
                    "Jarak Ayat",
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                  Slider(
                    min: 6,
                    max: 30,
                    activeColor: Primary,
                    value: ayahSpacing,
                    onChanged: (v) {
                      setSheet(() => ayahSpacing = v);
                      setState(() {});
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

  // ============================================================
  //                            UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final verses = widget.juz.verses;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          "Juz ${widget.juz.juz}",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: showFontMenu,
          ),
          IconButton(
            icon: Icon(
              autoScroll ? Icons.pause_circle : Icons.play_circle_fill,
            ),
            onPressed: autoScroll ? stopAutoScroll : startAutoScroll,
          ),
        ],
      ),

      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: verses.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _header();
          return _ayatItem(verses[index - 1]);
        },
      ),
    );
  }

  // ============================================================
  //                       HEADER JUZ
  // ============================================================
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: Column(
        children: [
          Text(
            "Juz ${widget.juz.juz}",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "${widget.juz.totalVerses} Ayat",
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //                       AYAT ITEM
  // ============================================================
  Widget _ayatItem(Verse ayah) {
    return Padding(
      padding: EdgeInsets.only(top: ayahSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nomor Ayat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: Gray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              toArabicNumber(ayah.numberInSurah ?? ayah.number ?? 0),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Arab
          SelectableText(
            ayah.arab,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: "Scheherazade",
              fontSize: arabFontSize,
              height: lineSpacing,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          // Terjemah
          if (showTranslation && ayah.translation.isNotEmpty)
            SelectableText(
              ayah.translation,
              style: GoogleFonts.poppins(
                fontSize: translationFontSize,
                height: lineSpacing,
                color: textt,
              ),
            ),
        ],
      ),
    );
  }
}
