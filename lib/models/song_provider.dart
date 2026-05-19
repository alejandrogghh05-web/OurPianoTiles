import 'package:piano_tiles/models/note.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Melodía 1 – Fácil: "Ode to Joy" (Beethoven) en Do mayor, octava 4-5
// 4 columnas visuales, cada nota tiene un pitch musical real.
// columna 0 → voz más grave del acorde
// columna 1 → segunda voz
// columna 2 → tercera voz
// columna 3 → voz más aguda
// ══════════════════════════════════════════════════════════════════════════════
List<Note> initNotes() {
  // Himno a la Alegría – fragmento principal (E4-E4-F4-G4-G4-F4-E4-D4-C4-C4-D4-E4-E4-D4-D4)
  const melody = [
    // line, pitch
    [2, E4], [2, E4], [3, F4], [3, G4],
    [3, G4], [3, F4], [2, E4], [1, D4],
    [0, C4], [0, C4], [1, D4], [2, E4],
    [2, E4], [1, D4], [1, D4],
    // Segunda frase
    [2, E4], [2, E4], [3, F4], [3, G4],
    [3, G4], [3, F4], [2, E4], [1, D4],
    [0, C4], [0, C4], [1, D4], [2, E4],
    [1, D4], [0, C4], [0, C4],
    // Puente
    [1, D4], [1, D4], [2, E4], [0, C4],
    [1, D4], [2, E4], [3, F4], [2, E4], [0, C4],
    [1, D4], [2, E4], [3, F4], [2, E4], [1, D4],
    // Coda
    [0, C4], [1, D4], [0, G3],
  ];

  final notes = <Note>[];
  for (int i = 0; i < melody.length; i++) {
    notes.add(Note(i, melody[i][0] as int, pitch: melody[i][1] as int));
  }
  // Padding de silencio
  final end = notes.length;
  for (int i = 0; i < 4; i++) {
    notes.add(Note(end + i, -1));
  }
  return notes;
}

// ══════════════════════════════════════════════════════════════════════════════
// Melodía 2 – Medio: "Für Elise" (Beethoven) – fragmento A+B
// Tonalidad La menor. Usa octavas 4 y 5 para más rango.
// ══════════════════════════════════════════════════════════════════════════════
List<Note> initNotesMedium() {
  const melody = [
    // Tema A: E5-Ds5-E5-Ds5-E5-B4-D5-C5
    [2, E5], [1, Ds5], [2, E5], [1, Ds5],
    [2, E5], [0, B4],  [1, D5], [0, C5],
    // A4-C4-E4-A4 (acorde Am)
    [0, A4], [1, C5], [2, E5],
    // Tema A repetido variado
    [2, E5], [1, Ds5], [2, E5], [1, Ds5],
    [2, E5], [0, B4],  [1, D5], [0, C5],
    // A3-E4-Gs4-B4 (acorde E)
    [0, A3], [1, E4], [2, Gs4], [3, B4],
    // Tema A de nuevo
    [2, E5], [1, Ds5], [2, E5], [1, Ds5],
    [2, E5], [0, B4],  [1, D5], [0, C5],
    // Tema B: A4-B4-C5-D5-E5-F5
    [0, A4], [0, B4], [1, C5], [1, D5],
    [2, E5], [3, F5],
    // Descenso: E5-D5-C5-B4-A4
    [3, E5], [2, D5], [1, C5], [0, B4], [0, A4],
    // Cadencia final
    [1, E4], [2, A4], [3, E5], [2, C5], [1, A4],
    [0, E4], [0, A3],
  ];

  final notes = <Note>[];
  for (int i = 0; i < melody.length; i++) {
    notes.add(Note(i, melody[i][0] as int, pitch: melody[i][1] as int));
  }
  final end = notes.length;
  for (int i = 0; i < 4; i++) {
    notes.add(Note(end + i, -1));
  }
  return notes;
}

// ══════════════════════════════════════════════════════════════════════════════
// Melodía 3 – Difícil: "Moonlight Sonata" Op.27 No.2 (Beethoven) – 1er mov.
// Arpegios en triples con saltos amplios entre octavas 3, 4 y 5.
// Máxima dificultad: saltos frecuentes entre columnas extremas.
// ══════════════════════════════════════════════════════════════════════════════
List<Note> initNotesHard() {
  const melody = [
    // Compás 1: Gs3-Cs4-E4 (arpegio Cs menor)
    [0, Gs3], [1, Cs4], [2, E4],
    [0, Gs3], [1, Cs4], [2, E4],
    // Compás 2: Gs3-Ds4-Fs4 (Gs mayor)
    [0, Gs3], [1, Ds4], [3, Fs4],
    [0, Gs3], [1, Ds4], [3, Fs4],
    // Compás 3: A3-Cs4-E4 (La mayor)
    [0, A3],  [1, Cs4], [2, E4],
    [0, A3],  [1, Cs4], [2, E4],
    // Compás 4: E3-B3-E4 (Mi mayor)
    [0, E3],  [1, B3],  [2, E4],
    [0, E3],  [1, B3],  [2, E4],
    // Sección B: melodía superior
    [3, Cs5], [2, B4],  [3, Cs5], [2, A4],
    [1, Gs4], [0, Fs4], [1, Gs4], [0, E4],
    // Arpegios descendentes rápidos
    [3, E5],  [2, Cs5], [1, A4],  [0, Gs3],
    [3, Ds5], [2, B4],  [1, Gs4], [0, Fs3],
    // Escalas con saltos
    [0, Cs4], [1, Ds4], [2, E4],  [3, Fs4],
    [3, Gs4], [2, A4],  [1, B4],  [0, Cs5],
    // Clímax: octava alta
    [3, E5],  [3, Ds5], [3, E5],  [3, Ds5],
    [3, E5],  [2, B4],  [1, D5],  [0, C5],
    // Resolución final
    [0, A3],  [1, E4],  [2, A4],  [3, Cs5],
    [2, A4],  [1, E4],  [0, A3],  [0, E3],
    [0, A2],
  ];

  final notes = <Note>[];
  for (int i = 0; i < melody.length; i++) {
    notes.add(Note(i, melody[i][0] as int, pitch: melody[i][1] as int));
  }
  final end = notes.length;
  for (int i = 0; i < 4; i++) {
    notes.add(Note(end + i, -1));
  }
  return notes;
}
