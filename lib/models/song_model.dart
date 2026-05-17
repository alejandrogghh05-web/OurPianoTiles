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
    title: 'Melodía 1',
    artist: 'Piano Tiles',
    difficulty: 'Fácil',
    notesProvider: initNotes,
  ),
  SongModel(
    id: 'song_2',
    title: 'Melodía 2',
    artist: 'Piano Tiles',
    difficulty: 'Medio',
    notesProvider: initNotes,
  ),
  SongModel(
    id: 'song_3',
    title: 'Melodía 3',
    artist: 'Piano Tiles',
    difficulty: 'Difícil',
    notesProvider: initNotes,
  ),
];