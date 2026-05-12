import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piano_tiles/models/song_model.dart';
import 'package:piano_tiles/models/note.dart';
import 'package:piano_tiles/routes/app_pages.dart';
import 'package:piano_tiles/services/record_service.dart';

class GameController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final SongModel song;
  late final AudioPlayer player;
  late final AnimationController animationController;

  final notes = <Note>[].obs;
  final currentNoteIndex = 0.obs;
  final points = 0.obs;
  final hasStarted = false.obs;
  final isPlaying = true.obs;
  final isInfiniteMode = false.obs;
  final record = 0.obs;

  late List<Note> _baseNotes;
  static const int _paddingNotes = 4;

  @override
  void onInit() {
    super.onInit();
    song = Get.arguments as SongModel;
    player = AudioPlayer();
    _baseNotes = song.notesProvider();
    notes.value = List.from(_baseNotes);
    _loadRecord();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying.value) {
        final idx = currentNoteIndex.value;

        if (notes[idx].state != NoteState.tapped) {
          isPlaying.value = false;
          notes[idx].state = NoteState.missed;
          notes.refresh();
          animationController.reverse().then((_) => _handleGameOver());
        } else if (idx == notes.length - _paddingNotes - 1) {
          if (isInfiniteMode.value) {
            _appendMoreNotes();
            currentNoteIndex.value++;
            animationController.forward(from: 0);
          } else {
            _handleGameOver(songCompleted: true);
          }
        } else {
          currentNoteIndex.value++;
          animationController.forward(from: 0);
        }
      }
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    player.dispose();
    super.onClose();
  }

  Future<void> _loadRecord() async {
    record.value = await RecordService.getRecord(song.id);
  }

  void _appendMoreNotes() {
    final currentLength = notes.length - _paddingNotes;
    final newNotes = _baseNotes
        .sublist(0, _baseNotes.length - _paddingNotes)
        .map((n) => Note(currentLength + n.orderNumber, n.line))
        .toList();

    notes.removeRange(notes.length - _paddingNotes, notes.length);
    notes.addAll(newNotes);
    notes.addAll(List.generate(
      _paddingNotes,
      (i) => Note(notes.length + i, -1),
    ));
    notes.refresh();
  }

  void toggleInfiniteMode() {
    isInfiniteMode.value = !isInfiniteMode.value;
  }

  void onTap(Note note) {
    final allPreviousTapped = notes
        .sublist(0, note.orderNumber)
        .every((n) => n.state == NoteState.tapped);

    if (!allPreviousTapped) return;

    if (!hasStarted.value) {
      hasStarted.value = true;
      animationController.forward();
    }

    _playNote(note);
    note.state = NoteState.tapped;
    notes.refresh();
    points.value++;
  }

  Future<void> _handleGameOver({bool songCompleted = false}) async {
    final isNewRecord = await RecordService.saveIfRecord(song.id, points.value);
    if (isNewRecord) record.value = points.value;
    _showFinishDialog(songCompleted: songCompleted, isNewRecord: isNewRecord);
  }

  void restart() {
    hasStarted.value = false;
    isPlaying.value = true;
    notes.value = List.from(_baseNotes);
    points.value = 0;
    currentNoteIndex.value = 0;
    animationController.reset();
  }

  void _showFinishDialog({bool songCompleted = false, bool isNewRecord = false}) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isNewRecord ? Colors.amberAccent : Colors.white24,
              width: isNewRecord ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isNewRecord) ...[
                const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 52),
                const SizedBox(height: 8),
                const Text(
                  '¡Nuevo Récord!',
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ] else if (songCompleted) ...[
                const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 52),
                const SizedBox(height: 8),
                const Text(
                  '¡Canción completada!',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] else ...[
                const Icon(Icons.close, color: Colors.redAccent, size: 52),
                const SizedBox(height: 8),
                const Text(
                  '¡Game Over!',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              Text(
                '${points.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'puntos',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amberAccent, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Récord: ${record.value}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        restart();
                      },
                      icon: const Icon(Icons.replay, size: 18),
                      label: const Text('Reintentar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.until(
                        (route) => route.settings.name == AppPages.menu,
                      ),
                      icon: const Icon(Icons.home, size: 18),
                      label: const Text('Menú'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _playNote(Note note) {
    final files = ['a.wav', 'c.wav', 'e.wav', 'f.wav'];
    if (note.line >= 0 && note.line < files.length) {
      player.play(AssetSource(files[note.line]));
    }
  }
}