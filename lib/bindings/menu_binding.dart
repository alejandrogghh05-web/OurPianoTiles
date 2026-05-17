import 'package:get/get.dart';
import 'package:piano_tiles/controllers/menu_controller.dart';

class MenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SongMenuController>(() => SongMenuController(), fenix: true);
  }
}