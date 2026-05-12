import 'package:get/get.dart';
import 'package:piano_tiles/models/song_model.dart';
import 'package:piano_tiles/routes/app_pages.dart';

class SongMenuController extends GetxController {
  final songs = availableSongs;

  void selectSong(SongModel song) {
    if (song.isLocked) {
      Get.snackbar(
        'Canción bloqueada',
        'Completa canciones anteriores para desbloquear.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(AppPages.game, arguments: song);
  }
}