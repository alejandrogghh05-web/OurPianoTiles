import 'package:piano_tiles/models/note.dart';
import 'package:piano_tiles/models/song_provider.dart';

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String difficulty;
  final List<Note> Function() notesProvider;
  final bool isLocked;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.difficulty,
    required this.notesProvider,
    this.isLocked = false,
  });
}

final List<SongModel> availableSongs = [
  SongModel(
    id: 'song_1',
    title: 'Calentamiento',
    artist: 'Reflex Rush',
    difficulty: 'Fácil',
    notesProvider: initNotes,
  ),
  SongModel(
    id: 'song_2',
    title: 'Pulso',
    artist: 'Reflex Rush',
    difficulty: 'Medio',
    notesProvider: initNotesMedium,
  ),
  SongModel(
    id: 'song_3',
    title: 'Tormenta',
    artist: 'Reflex Rush',
    difficulty: 'Difícil',
    notesProvider: initNotesHard,
  ),
];