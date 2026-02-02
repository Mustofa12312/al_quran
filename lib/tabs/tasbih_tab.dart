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

  late AnimationController beadController;

  @override
  void initState() {
    super.initState();

    beadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: -0.15,
      upperBound: 0.15,
    );

    HardwareKeyboard.instance.addHandler(_onKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    beadController.dispose();
    super.dispose();
  }

  // =======================
  // TOMBOL VOLUME
  // =======================
  bool _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
        increment();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
        decrement();
        return true;
      }
    }
    return false;
  }

  // =======================
  // VIBRATION
  // =======================
  Future<void> vibrateSoft() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 70, amplitude: 180);
    }
  }

  Future<void> vibrateStrong() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 200, 120, 200], intensities: [255, 255]);
    }
  }

  // =======================
  // COUNTER LOGIC
  // =======================
  void increment() {
    beadController.forward(from: 0);
    setState(() => counter++);

    if (target > 0 && counter >= target) {
      vibrateStrong();
      counter = 0;
    } else if (vibration) {
      vibrateSoft();
    }
  }

  void decrement() {
    if (counter > 0) {
      beadController.forward(from: 0);
      setState(() => counter--);
      if (vibration) vibrateSoft();
    }
  }

  void reset() {
    vibrateStrong();
    setState(() => counter = 0);
  }

  // =======================
  // SET TARGET MANUAL
  // =======================
  void setTargetDialog() {
    final controller = TextEditingController(text: target.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2036),
        title: const Text(
          "Set Target Tasbih",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Masukkan angka bebas",
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                setState(() {
                  target = value;
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

  // =======================
  // UI
  // =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1324),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              Text(
                "Digital Tasbih",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              // COUNTER
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A2EFF), Color(0xFF6100FF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$counter",
                  style: GoogleFonts.poppins(
                    fontSize: 60,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // BIJI TASBIH
              AnimatedBuilder(
                animation: beadController,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: beadController.value,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: increment,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF9C27FF), Color(0xFF6200EA)],
                      ),
                    ),
                    child: const Icon(Icons.add, size: 80, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // TARGET SETTING
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Target: $target",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: setTargetDialog,
                    child: const Text("Ubah"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // RESET + VIBRATION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reset"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        "Vibration",
                        style: TextStyle(color: Colors.white),
                      ),
                      Switch(
                        value: vibration,
                        onChanged: (v) => setState(() => vibration = v),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                "Gunakan tombol volume untuk menambah / mengurangi",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
