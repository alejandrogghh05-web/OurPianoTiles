import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piano_tiles/controllers/menu_controller.dart';
import 'package:piano_tiles/models/song_model.dart';

class MenuPage extends GetView<SongMenuController> {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset('assets/background.jpg', fit: BoxFit.cover),
          Container(color: Colors.black),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Title
                const Text(
                  'Piano Tiles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige una canción',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 48),

                // Song list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: controller.songs.length,
                    itemBuilder: (context, index) {
                      return _SongCard(
                        song: controller.songs[index],
                        onTap: () => controller.selectSong(controller.songs[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;

  const _SongCard({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: song.isLocked
              ? Colors.white
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: song.isLocked
                ? Colors.white24
                : Colors.white,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Piano icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: song.isLocked ? Colors.white12 : Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  song.isLocked ? Icons.lock_outline : Icons.music_note,
                  color: song.isLocked ? Colors.white38 : Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: TextStyle(
                        color: song.isLocked ? Colors.white38 : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist,
                      style: TextStyle(
                        color: song.isLocked
                            ? Colors.white24
                            : Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Difficulty badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _difficultyColor(song.difficulty),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  song.difficulty,
                  style: TextStyle(
                    color: song.isLocked
                        ? Colors.white38
                        : _difficultyColor(song.difficulty),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Fácil':
        return Colors.greenAccent;
      case 'Medio':
        return Colors.orangeAccent;
      case 'Difícil':
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }
}