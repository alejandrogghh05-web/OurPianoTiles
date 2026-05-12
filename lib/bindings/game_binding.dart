import 'package:get/get.dart';
import 'package:piano_tiles/controllers/game_controller.dart';

class GameBinding extends Bindings {
  @override
  void dependencies() {
    Get.delete<GameController>(force: true);
    Get.put<GameController>(GameController());
  }
}