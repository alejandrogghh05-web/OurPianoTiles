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
        fit: StackFit.passthrough,
        children: [
          Image.asset('assets/background.jpg', fit: BoxFit.cover),
          Obx(() {
            final idx = controller.currentNoteIndex.value;
            final notes = controller.notes;
            return Row(
              children: [
                _drawLine(0, idx, notes),
                const LineDivider(),
                _drawLine(1, idx, notes),
                const LineDivider(),
                _drawLine(2, idx, notes),
                const LineDivider(),
                _drawLine(3, idx, notes),
              ],
            );
          }),
          _drawPoints(),
          _drawBackButton(),
        ],
      ),
    );
  }

  Widget _drawLine(int lineNumber, int idx, notes) {
    return Expanded(
      child: Line(
        lineNumber: lineNumber,
        currentNotes: notes.sublist(idx, idx + 5),
        onTileTap: controller.onTap,
        animation: controller.animationController,
      ),
    );
  }

  Widget _drawPoints() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Obx(
          () => Text(
            '${controller.points.value}',
            style: const TextStyle(color: Colors.white, fontSize: 60),
          ),
        ),
      ),
    );
  }

  Widget _drawBackButton() {
    return Positioned(
      top: 40,
      left: 16,
      child: SafeArea(
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
    );
  }
}