import 'package:flutter/material.dart';
import 'package:piano_tiles/models/note.dart';
import 'package:piano_tiles/widgets/tile.dart';

class Line extends AnimatedWidget {
  final int lineNumber;
  final List<Note> currentNotes;
  final Function(Note) onTileTap;

  const Line({
    super.key,
    required this.currentNotes,
    required this.lineNumber,
    required this.onTileTap,
    required Animation<double> animation,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = super.listenable as Animation<double>;
    final height = MediaQuery.of(context).size.height;
    final tileHeight = height / 4;

    final thisLineNotes =
        currentNotes.where((note) => note.line == lineNumber).toList();

    final tiles = thisLineNotes.map((note) {
      final index = currentNotes.indexOf(note);
      final offset = (3 - index + animation.value) * tileHeight;

      return Transform.translate(
        offset: Offset(0, offset),
        child: Tile(
          height: tileHeight,
          state: note.state,
          onTap: () => onTileTap(note),
        ),
      );
    }).toList();

    return SizedBox.expand(
      child: Stack(children: tiles),
    );
  }
}