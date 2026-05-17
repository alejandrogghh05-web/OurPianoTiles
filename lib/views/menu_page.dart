import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piano_tiles/controllers/menu_controller.dart';
import 'package:piano_tiles/models/song_model.dart';

// Design tokens from Stitch
const _bgDeep = Color(0xFF090e1c);
const _bgSurface = Color(0xFF0e1321);
const _bgContainerHigh = Color(0xFF252a39);
const _primary = Color(0xFFbaf2ff);
const _primaryFixedDim = Color(0xFF00daf8);
const _primaryContainer = Color(0xFF00e0ff);
const _secondaryFixed = Color(0xFFffe16d);
const _onSurfaceVariant = Color(0xFFbac9cd);
const _surfaceVariant = Color(0xFF303444);
const _error = Color(0xFFffb4ab);

class MenuPage extends GetView<SongMenuController> {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgSurface,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bgDeep, _bgSurface, Colors.black],
              ),
            ),
          ),
          // Radial glow top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    _primaryContainer.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Piano texture (vertical lines)
          Positioned.fill(
            child: CustomPaint(painter: _PianoTexturePainter()),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _TopBar(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                    children: [
                      // Page header
                      const Text(
                        'Piano Tiles',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: _secondaryFixed,
                          shadows: [
                            Shadow(
                              color: Color(0x66ffe16d),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Elige una canción',
                        style: TextStyle(
                          fontSize: 13,
                          letterSpacing: 0.05 * 13,
                          fontWeight: FontWeight.w600,
                          color: _onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Song list
                      ...controller.songs.map(
                        (song) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _SongCard(
                            song: song,
                            onTap: () => controller.selectSong(song),
                            onInfiniteTap: song.isLocked
                                ? null
                                : () => controller.selectInfiniteMode(song),
                          ),
                        ),
                      ),

                      // Featured card
                      const SizedBox(height: 8),
                      _FeaturedCard(),
                    ],
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

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: _bgSurface.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.menu, color: _primary),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Rhythm Echo',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _primary.withValues(alpha: 0.3),
                  ),
                  color: _primaryContainer.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.person, color: _primary, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback? onInfiniteTap;

  const _SongCard({required this.song, required this.onTap, this.onInfiniteTap});

  @override
  Widget build(BuildContext context) {
    final locked = song.isLocked;
    final hasInfinite = onInfiniteTap != null;

    return Opacity(
      opacity: locked ? (song.difficulty == 'Difícil' ? 0.3 : 0.5) : 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                // Main row — tap to play normal
                GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icon box
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: locked
                                ? _surfaceVariant
                                : _primaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: locked
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : _primaryContainer.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            locked ? Icons.lock_outline : Icons.library_music,
                            color: locked ? _onSurfaceVariant : _primaryFixedDim,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      song.title,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: locked ? _onSurfaceVariant : Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _DifficultyBadge(difficulty: song.difficulty),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song.artist,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceVariant.withValues(
                                    alpha: locked ? 0.4 : 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Infinite mode row — only shown when song is completed
                if (hasInfinite) ...[
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.06),
                    indent: 16,
                    endIndent: 16,
                  ),
                  GestureDetector(
                    onTap: onInfiniteTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Icon(
                              Icons.all_inclusive,
                              color: Color(0xFFa78bfa),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Modo Infinito',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFa78bfa),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFFa78bfa),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final (dotColor, textColor, bgColor, borderColor) = switch (difficulty) {
      'Fácil' => (
          const Color(0xFF22c55e),
          const Color(0xFF4ade80),
          const Color(0x1A22c55e),
          const Color(0x3322c55e),
        ),
      'Medio' => (
          _secondaryFixed,
          _secondaryFixed,
          const Color(0x1Affe16d),
          const Color(0x33ffe16d),
        ),
      _ => (
          _error,
          _error,
          const Color(0x1Affb4ab),
          const Color(0x33ffb4ab),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              boxShadow: [BoxShadow(color: dotColor.withValues(alpha: 0.6), blurRadius: 4)],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            difficulty.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 160,
        decoration: const BoxDecoration(
          color: _bgContainerHigh,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder image background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0a1628), Color(0xFF0d2137), Color(0xFF061020)],
                ),
              ),
            ),
            // Piano keys illustration
            CustomPaint(painter: _PianoKeysPainter()),
            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _bgContainerHigh],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Novedad',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Classic Echoes',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Pack de 5 nuevas pistas',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _PianoTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += size.width / 4) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PianoKeysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()..color = Colors.white.withValues(alpha: 0.06);
    final blackPaint = Paint()..color = Colors.black.withValues(alpha: 0.4);
    const keyCount = 14;
    final keyWidth = size.width / keyCount;

    for (int i = 0; i < keyCount; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * keyWidth + 1, 0, keyWidth - 2, size.height),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, whitePaint);
    }

    // Black keys pattern: skip 3rd, 7th positions
    const blackPattern = [0, 1, 3, 4, 5, 7, 8, 10, 11, 12];
    for (final i in blackPattern) {
      if (i >= keyCount - 1) continue;
      final x = (i + 1) * keyWidth - keyWidth * 0.3;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, keyWidth * 0.6, size.height * 0.6),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, blackPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
