import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piano_tiles/controllers/game_controller.dart';
import 'package:piano_tiles/widgets/line.dart';
import 'package:piano_tiles/widgets/line_divider.dart';

class GamePage extends GetView<GameController> {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset('assets/background.jpg', fit: BoxFit.cover),

          // Tile columns — rebuilt only when index or notes change
          Obx(() {
            final idx = controller.currentNoteIndex.value;
            final notes = controller.notes;
            final safeEnd = (idx + 5).clamp(0, notes.length);
            if (safeEnd - idx < 5) return const SizedBox.shrink();

            return Row(
              children: [
                _buildLine(0, idx, notes),
                const LineDivider(),
                _buildLine(1, idx, notes),
                const LineDivider(),
                _buildLine(2, idx, notes),
                const LineDivider(),
                _buildLine(3, idx, notes),
              ],
            );
          }),

          // Top HUD
          _TopHud(controller: controller),

          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildLine(int lineNumber, int idx, notes) {
    return Expanded(
      child: Line(
        lineNumber: lineNumber,
        currentNotes: notes.sublist(idx, idx + 5),
        onTileTap: controller.onTap,
        animation: controller.animationController,
      ),
    );
  }
}

// ── Top HUD ───────────────────────────────────────────────────────────────────

class _TopHud extends StatelessWidget {
  final GameController controller;
  const _TopHud({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Points
              Obx(() => Text(
                    '${controller.points.value}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                    ),
                  )),

              // Infinite mode indicators
              Obx(() {
                if (!controller.isInfiniteMode.value) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Loop badge
                      _HudBadge(
                        icon: Icons.all_inclusive,
                        color: Colors.deepPurpleAccent,
                        label: 'Vuelta ${controller.loopCount.value}',
                      ),
                      const SizedBox(width: 10),
                      // Speed badge
                      _SpeedBadge(controller: controller),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _HudBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _HudBadge({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SpeedBadge extends StatelessWidget {
  final GameController controller;
  const _SpeedBadge({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Normalise speed: 300ms = 1×, 80ms = ~3.75×
    final ms = controller.currentSpeedMs.value;
    final multiplier = (300 / ms).toStringAsFixed(1);

    // Colour shifts from white → orange → red as speed increases
    final Color color;
    if (ms >= 220) {
      color = Colors.white;
    } else if (ms >= 140) {
      color = Colors.orangeAccent;
    } else {
      color = Colors.redAccent;
    }

    return _HudBadge(
      icon: Icons.speed,
      color: color,
      label: '${multiplier}×',
    );
  }
}
