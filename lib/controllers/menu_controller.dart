import 'package:get/get.dart';
import 'package:piano_tiles/models/song_model.dart';
import 'package:piano_tiles/routes/app_pages.dart';
import 'package:piano_tiles/services/record_service.dart';

class SongMenuController extends GetxController {
  final songs = availableSongs;
  final completedSongs = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCompletionStates();
  }

  Future<void> _loadCompletionStates() async {
    final results = <String, bool>{};
    for (final song in songs) {
      results[song.id] = await RecordService.isCompleted(song.id);
    }
    completedSongs.value = results;
  }

  bool isCompleted(SongModel song) => completedSongs[song.id] ?? false;

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

  void selectInfiniteMode(SongModel song) {
    Get.toNamed(AppPages.game, arguments: {'song': song, 'infiniteMode': true});
  }
}