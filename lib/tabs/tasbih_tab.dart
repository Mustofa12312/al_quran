import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';

class TasbihTab extends StatefulWidget {
  const TasbihTab({super.key});

  @override
  State<TasbihTab> createState() => _TasbihTabState();
}

class _TasbihTabState extends State<TasbihTab> with TickerProviderStateMixin {
  int counter = 0;
  int target = 33;
  bool vibration = true;

  late AnimationController tapAnim;

  @override
  void initState() {
    super.initState();

    tapAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );

    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    tapAnim.dispose();
    super.dispose();
  }

  // ================= VOLUME =================
  bool _onKey(KeyEvent e) {
    if (e is KeyDownEvent) {
      if (e.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
        increment();
        return true;
      }
      if (e.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
        decrement();
        return true;
      }
    }
    return false;
  }

  // ================= VIBRATION =================
  Future<void> softVibrate() async {
    if (vibration && (await Vibration.hasVibrator() ?? false)) {
      Vibration.vibrate(duration: 40);
    }
  }

  Future<void> strongVibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 120, 80, 120]);
    }
  }

  // ================= LOGIC =================
  void increment() {
    tapAnim.forward(from: 0.96);
    setState(() => counter++);

    if (counter >= target) {
      strongVibrate();
      counter = 0;
    } else {
      softVibrate();
    }
  }

  void decrement() {
    if (counter > 0) {
      tapAnim.forward(from: 0.96);
      setState(() => counter--);
      softVibrate();
    }
  }

  void reset() {
    strongVibrate();
    setState(() => counter = 0);
  }

  // ================= TARGET =================
  void setTarget() {
    final c = TextEditingController(text: target.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2849),
        title: const Text("Set Target", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Masukkan angka",
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              final v = int.tryParse(c.text);
              if (v != null && v > 0) {
                setState(() {
                  target = v;
                  counter = 0;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121931),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      Text(
                        "Tasbih",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 50),

                      Text(
                        "$counter",
                        style: GoogleFonts.poppins(
                          fontSize: 72,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Target $target",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                      ),

                      const SizedBox(height: 40),

                      ScaleTransition(
                        scale: tapAnim,
                        child: GestureDetector(
                          onTap: increment,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF9055FF),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: setTarget,
                            child: const Text("Ubah Target"),
                          ),
                          const SizedBox(width: 20),
                          TextButton(
                            onPressed: reset,
                            child: const Text("Reset"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Vibrasi",
                            style: TextStyle(color: Colors.white70),
                          ),
                          Switch(
                            value: vibration,
                            activeColor: const Color(0xFF9055FF),
                            onChanged: (v) => setState(() => vibration = v),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Gunakan tombol volume untuk dzikir",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
