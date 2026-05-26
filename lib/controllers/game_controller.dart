// lib/controllers/game_controller.dart
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
  late AnimationController animationController;

  static final _soundPlayers = <String, List<AudioPlayer>>{};
  static final _soundPlayerIdx = <String, int>{};
  static AudioPlayer? _lastPlayedPlayer;

  final notes = <Note>[].obs;
  final currentNoteIndex = 0.obs;
  final points = 0.obs;
  final hasStarted = false.obs;
  final isPlaying = true.obs;
  final isInfiniteMode = false.obs;
  final record = 0.obs;
  final infiniteRecord = 0.obs;

  // Infinite mode state
  final loopCount = 0.obs;
  final currentSpeedMs = 300.obs;

  late List<Note> _baseNotes;
  static const int _paddingNotes = 4;

  // Tempo dinámico: duración de la nota actual en modo normal
  static const int _baseDurationMs = 300;
  static const double _speedIncreasePerLoop = 0.08;
  static const int _minDurationMs = 80;

  // ── Helpers ────────────────────────────────────────────────────────────

  /// Devuelve el durationMs de la nota activa, o _baseDurationMs como fallback.
  int _durationForIndex(int idx) {
    if (idx < notes.length) {
      final ms = notes[idx].durationMs;
      return ms > 0 ? ms : _baseDurationMs;
    }
    return _baseDurationMs;
  }

  /// Actualiza la duración del AnimationController y lanza forward().
  void _forwardWithDuration(int idx) {
    final ms = isInfiniteMode.value
        ? currentSpeedMs.value
        : _durationForIndex(idx);
    animationController.duration = Duration(milliseconds: ms);
    animationController.forward(from: 0);
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args is Map) {
      song = args['song'] as SongModel;
      final startInfinite = args['infiniteMode'] == true;
      _baseNotes = song.notesProvider();
      notes.value = List.from(_baseNotes);
      _loadRecords();
      _initAudio();

      animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _baseDurationMs),
      );
      animationController.addStatusListener(_onAnimationStatus);

      if (startInfinite) {
        isInfiniteMode.value = true;
        loopCount.value = 1;
        _applyLoopSpeed();
        _appendMoreNotes();
      }
    } else {
      song = args as SongModel;
      _baseNotes = song.notesProvider();
      notes.value = List.from(_baseNotes);
      _loadRecords();
      _initAudio();

      animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _baseDurationMs),
      );
      animationController.addStatusListener(_onAnimationStatus);
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    // Los players son estáticos — sólo detenerlos, no destruirlos,
    // para evitar la condición de carrera al reiniciar el juego.
    for (final players in _soundPlayers.values) {
      for (final p in players) p.stop();
    }
    super.onClose();
  }

  // ── Records ────────────────────────────────────────────────────────────

  Future<void> _loadRecords() async {
    record.value = await RecordService.getRecord(song.id);
    infiniteRecord.value = await RecordService.getRecord('${song.id}_infinite');
  }

  // ── Animation listener ─────────────────────────────────────────────────

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !isPlaying.value) return;

    final idx = currentNoteIndex.value;

    // Nota no tocada → game over
    if (notes[idx].state != NoteState.tapped) {
      isPlaying.value = false;
      notes[idx].state = NoteState.missed;
      notes.refresh();
      animationController.reverse().then((_) => _handleGameOver());
      return;
    }

    // Fin de la canción (solo en modo normal)
    if (!isInfiniteMode.value && idx == notes.length - _paddingNotes - 1) {
      _handleSongCompleted();
      return;
    }

    // Avanzar a la siguiente nota
    currentNoteIndex.value++;

    // Modo infinito: pre-cargar el siguiente loop cuando se acerca el padding
    if (isInfiniteMode.value) {
      final realEnd = notes.length - _paddingNotes;
      if (realEnd - currentNoteIndex.value == _paddingNotes) {
        loopCount.value++;
        _applyLoopSpeed();
        _appendMoreNotes();
      }
    }

    // Lanzar la siguiente animación con la duración correcta
    _forwardWithDuration(currentNoteIndex.value);
  }

  // ── Infinite mode ──────────────────────────────────────────────────────

  void enterInfiniteMode() {
    isInfiniteMode.value = true;
    isPlaying.value = true;
    hasStarted.value = false;
    points.value = 0;
    loopCount.value = 1;

    _baseNotes = song.notesProvider();
    notes.value = List.from(_baseNotes);
    _applyLoopSpeed();
    _appendMoreNotes();

    currentNoteIndex.value = 0;
    animationController.reset();
  }

  void _applyLoopSpeed() {
    final reduction = _speedIncreasePerLoop * loopCount.value;
    final newMs = (_baseDurationMs * (1.0 - reduction))
        .round()
        .clamp(_minDurationMs, _baseDurationMs);
    currentSpeedMs.value = newMs;
    animationController.duration = Duration(milliseconds: newMs);
  }

  void _appendMoreNotes() {
    final currentLength = notes.length - _paddingNotes;
    final newNotes = _baseNotes
        .sublist(0, _baseNotes.length - _paddingNotes)
        .map((n) => Note(
              currentLength + n.orderNumber,
              n.line,
              pitch: n.pitch,
              durationMs: n.durationMs,
            ))
        .toList();
    final padding = List.generate(
      _paddingNotes,
      (i) => Note(currentLength + newNotes.length + i, -1),
    );
    notes.value = [
      ...notes.sublist(0, currentLength),
      ...newNotes,
      ...padding,
    ];
  }

  // ── Tap ────────────────────────────────────────────────────────────────

  void onTap(Note note) {
    final allPreviousTapped = notes
        .sublist(0, note.orderNumber)
        .every((n) => n.state == NoteState.tapped);

    if (!allPreviousTapped) return;

    if (!hasStarted.value) {
      hasStarted.value = true;
      // Primera nota: usar su durationMs propio
      _forwardWithDuration(note.orderNumber);
    }

    _playNote(note);
    note.state = NoteState.tapped;
    notes.refresh();
    points.value++;
  }

  // ── Game over / completed ──────────────────────────────────────────────

  Future<void> _handleSongCompleted() async {
    isPlaying.value = false;
    await RecordService.markCompleted(song.id);
    final isNewRecord =
        await RecordService.saveIfRecord(song.id, points.value);
    if (isNewRecord) record.value = points.value;
    _showSongCompletedDialog(isNewRecord: isNewRecord);
  }

  Future<void> _handleGameOver() async {
    final scoreKey = isInfiniteMode.value ? '${song.id}_infinite' : song.id;
    final isNewRecord =
        await RecordService.saveIfRecord(scoreKey, points.value);
    if (isInfiniteMode.value) {
      if (isNewRecord) infiniteRecord.value = points.value;
    } else {
      if (isNewRecord) record.value = points.value;
    }
    _showGameOverDialog(isNewRecord: isNewRecord);
  }

  // ── Restart ────────────────────────────────────────────────────────────

  void restart() {
    final wasInfinite = isInfiniteMode.value;
    for (final players in _soundPlayers.values) {
      for (final p in players) p.stop();
    }
    _lastPlayedPlayer = null;
    for (final key in _soundPlayerIdx.keys) {
      _soundPlayerIdx[key] = 0;
    }
    isInfiniteMode.value = false;
    hasStarted.value = false;
    isPlaying.value = true;
    loopCount.value = 0;
    currentSpeedMs.value = _baseDurationMs;
    _baseNotes = song.notesProvider();
    notes.value = List.from(_baseNotes);
    points.value = 0;
    currentNoteIndex.value = 0;
    animationController.duration =
        const Duration(milliseconds: _baseDurationMs);
    animationController.reset();

    if (wasInfinite) {
      isInfiniteMode.value = true;
      loopCount.value = 1;
      _applyLoopSpeed();
      _appendMoreNotes();
    }
  }

  // ── Audio ──────────────────────────────────────────────────────────────

  Set<String> _uniqueAssetsForNotes(List<Note> notes) {
    const fallback = ['a.wav', 'c.wav', 'e.wav', 'f.wav'];
    return {
      for (final n in notes)
        if (n.line >= 0)
          n.pitch >= 0 ? pitchToAsset(n.pitch) : fallback[n.line % 4],
    };
  }

  static final _noFocusCtx = AudioContext(
    android: const AudioContextAndroid(
      audioFocus: AndroidAudioFocus.none,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
    ),
  );

  Future<void> _initAudio() async {
    final assets = _uniqueAssetsForNotes(_baseNotes);
    // Solo cargar los assets que todavía no están en el mapa (nueva canción).
    final missing = assets.where((a) => !_soundPlayers.containsKey(a)).toSet();
    if (missing.isEmpty) return;

    if (_soundPlayers.isEmpty) {
      await AudioPlayer.global.setAudioContext(_noFocusCtx);
      debugPrint('[AUDIO_INIT] Global context aplicado (audioFocus=none)');
    }

    debugPrint('[AUDIO_INIT] Cargando ${missing.length} assets nuevos...');
    for (final assetFile in missing) {
      final players = await Future.wait(List.generate(2, (_) async {
        final p = AudioPlayer();
        await p.setPlayerMode(PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setSource(AssetSource(assetFile));
        return p;
      }));
      _soundPlayers[assetFile] = players;
      _soundPlayerIdx[assetFile] = 0;
      debugPrint('[AUDIO_INIT] $assetFile listo');
    }
    debugPrint('[AUDIO_INIT] Init completo (${_soundPlayers.length} assets totales)');
  }

  void _playNote(Note note) {
    if (note.line < 0) return;

    const fallback = ['a.wav', 'c.wav', 'e.wav', 'f.wav'];
    final assetFile = note.pitch >= 0
        ? pitchToAsset(note.pitch)
        : fallback[note.line % 4];

    final players = _soundPlayers[assetFile];
    if (players == null) return;

    final idx = _soundPlayerIdx[assetFile]!;
    _soundPlayerIdx[assetFile] = (idx + 1) % 2;

    final p = players[idx];
    // Cortar nota anterior + reiniciar actual: stop luego resume se
    // procesan en orden en Android, no hace falta await.
    if (_lastPlayedPlayer != p) _lastPlayedPlayer?.stop();
    _lastPlayedPlayer = p;
    p.stop();
    p.resume();
  }

  // ── Dialogs ────────────────────────────────────────────────────────────

  void _showSongCompletedDialog({required bool isNewRecord}) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isNewRecord ? Colors.amberAccent : Colors.greenAccent,
              width: isNewRecord ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isNewRecord) ...[
                const Icon(Icons.emoji_events,
                    color: Colors.amberAccent, size: 52),
                const SizedBox(height: 8),
                const Text('¡Nuevo Récord!',
                    style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
              ] else ...[
                const Icon(Icons.check_circle_outline,
                    color: Colors.greenAccent, size: 52),
                const SizedBox(height: 8),
                const Text('¡Canción completada!',
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],

              const SizedBox(height: 20),

              Text('${points.value}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold)),
              Text('puntos',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 14)),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amberAccent, size: 16),
                  const SizedBox(width: 4),
                  Text('Récord: ${record.value}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 14)),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurpleAccent, width: 1),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.all_inclusive,
                            color: Colors.deepPurpleAccent, size: 22),
                        SizedBox(width: 8),
                        Text('Modo Infinito',
                            style: TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'La canción se repite sin fin.\nCada vuelta aumenta la velocidad.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.65), fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        enterInfiniteMode();
                      },
                      icon: const Icon(Icons.all_inclusive, size: 18),
                      label: const Text('¡Jugar Modo Infinito!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Get.until(
                              (route) =>
                                  route.settings.name == AppPages.menu),
                          icon: const Icon(Icons.home, size: 18),
                          label: const Text('Menú'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
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

  void _showGameOverDialog({required bool isNewRecord}) {
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
                const Icon(Icons.emoji_events,
                    color: Colors.amberAccent, size: 52),
                const SizedBox(height: 8),
                const Text('¡Nuevo Récord!',
                    style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
              ] else ...[
                const Icon(Icons.close, color: Colors.redAccent, size: 52),
                const SizedBox(height: 8),
                const Text('¡Game Over!',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],

              if (isInfiniteMode.value) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.all_inclusive,
                          color: Colors.deepPurpleAccent, size: 14),
                      const SizedBox(width: 6),
                      Obx(() => Text(
                            'Vuelta ${loopCount.value}',
                            style: const TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              Text('${points.value}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold)),
              Text('puntos',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 14)),

              const SizedBox(height: 8),

              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amberAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        isInfiniteMode.value
                            ? 'Récord ∞: ${infiniteRecord.value}'
                            : 'Récord: ${record.value}',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14),
                      ),
                    ],
                  )),

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
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.until(
                          (route) => route.settings.name == AppPages.menu),
                      icon: const Icon(Icons.home, size: 18),
                      label: const Text('Menú'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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
}