import 'package:get/get.dart';
import 'package:piano_tiles/routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToMenu();
  }

  Future<void> _navigateToMenu() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offNamed(AppPages.menu);
  }
}