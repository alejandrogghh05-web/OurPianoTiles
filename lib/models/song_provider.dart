// lib/models/song_provider.dart
import 'package:piano_tiles/models/note.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Utilidad: construye una sección de notas con un durationMs uniforme.
// [melody] es una lista de [line, pitch].
// [offset] es el orderNumber de la primera nota de la sección.
// Devuelve la lista de notas y actualiza [offset] para la siguiente sección.
// ─────────────────────────────────────────────────────────────────────────────
List<Note> _section(
  List<List<int>> melody,
  int durationMs,
  int offset,
) {
  final notes = <Note>[];
  for (int i = 0; i < melody.length; i++) {
    notes.add(Note(
      offset + i,
      melody[i][0],
      pitch: melody[i][1],
      durationMs: durationMs,
    ));
  }
  return notes;
}

// Repite un patrón melódico [times] veces con el mismo durationMs.
List<Note> _repeat(
  List<List<int>> pattern,
  int times,
  int durationMs,
  int offset,
) {
  final all = <Note>[];
  for (int t = 0; t < times; t++) {
    all.addAll(_section(pattern, durationMs, offset + all.length));
  }
  return all;
}

// Genera un crescendo: la duración disminuye linealmente de [fromMs] a [toMs]
// a lo largo de toda la lista de notas.
List<Note> _crescendo(
  List<List<int>> melody,
  int fromMs,
  int toMs,
  int offset,
) {
  final notes = <Note>[];
  final steps = melody.length - 1;
  for (int i = 0; i < melody.length; i++) {
    final t = steps == 0 ? 0.0 : i / steps;
    final ms = (fromMs + (toMs - fromMs) * t).round();
    notes.add(Note(
      offset + i,
      melody[i][0],
      pitch: melody[i][1],
      durationMs: ms,
    ));
  }
  return notes;
}

// Padding de silencio al final (4 notas con line = -1).
List<Note> _padding(int offset, {int durationMs = 300}) => List.generate(
      4,
      (i) => Note(offset + i, -1, durationMs: durationMs),
    );

// ══════════════════════════════════════════════════════════════════════════════
// MELODÍA 1 – FÁCIL  "Ode to Joy"
// Estructura: intro lenta → tema A normal → tema A rápido × 3 →
//             puente crescendo → tema A variado → coda lenta
// Duración aproximada: ~2 min
// ══════════════════════════════════════════════════════════════════════════════

// Fragmentos reutilizables
const _odeThemeA = [
  [2, E4], [2, E4], [3, F4], [3, G4],
  [3, G4], [3, F4], [2, E4], [1, D4],
  [0, C4], [0, C4], [1, D4], [2, E4],
  [2, E4], [1, D4], [1, D4],
];

const _odeThemeA2 = [
  [2, E4], [2, E4], [3, F4], [3, G4],
  [3, G4], [3, F4], [2, E4], [1, D4],
  [0, C4], [0, C4], [1, D4], [2, E4],
  [1, D4], [0, C4], [0, C4],
];

const _odeBridge = [
  [1, D4], [1, D4], [2, E4], [0, C4],
  [1, D4], [2, E4], [3, F4], [2, E4], [0, C4],
  [1, D4], [2, E4], [3, F4], [2, E4], [1, D4],
];

const _odeThemeB = [
  [3, G4], [3, G4], [3, A4], [3, G4], [3, F4],
  [2, E4], [1, D4], [0, C4], [1, D4], [2, E4],
  [3, F4], [2, E4], [1, D4], [0, C4],
];

const _odeChorus = [
  [0, C4], [1, E4], [2, G4], [3, C5],
  [3, B4], [2, A4], [1, G4], [0, E4],
  [0, D4], [1, F4], [2, A4], [3, D5],
  [3, C5], [2, B4], [1, A4], [0, F4],
];

const _odeCoda = [
  [0, C4], [1, D4], [0, G3],
  [0, C4], [0, C4],
];

List<Note> initNotes() {
  final all = <Note>[];

  // 1. Intro lenta (500 ms/nota)
  all.addAll(_section(_odeThemeA as List<List<int>>, 500, all.length));

  // 2. Tema A normal (350 ms)
  all.addAll(_section(_odeThemeA2 as List<List<int>>, 350, all.length));

  // 3. Puente lento→normal (crescendo invertido 480→320)
  all.addAll(_crescendo(_odeBridge as List<List<int>>, 480, 320, all.length));

  // 4. Estribillo rápido × 3 (220 ms)
  all.addAll(_repeat(_odeChorus as List<List<int>>, 3, 220, all.length));

  // 5. Tema B normal (300 ms)
  all.addAll(_section(_odeThemeB as List<List<int>>, 300, all.length));

  // 6. Crescendo hacia el clímax (300→160)
  all.addAll(_crescendo(_odeThemeA as List<List<int>>, 300, 160, all.length));

  // 7. Clímax muy rápido × 4 (160 ms)
  all.addAll(_repeat(_odeChorus as List<List<int>>, 4, 160, all.length));

  // 8. Puente de transición (260 ms)
  all.addAll(_section(_odeBridge as List<List<int>>, 260, all.length));

  // 9. Tema A variado × 2 (300 ms)
  all.addAll(_repeat(_odeThemeA2 as List<List<int>>, 2, 300, all.length));

  // 10. Decrescendo final (260→480)
  all.addAll(_crescendo(_odeCoda as List<List<int>>, 260, 480, all.length));

  // 11. Coda lenta (520 ms)
  all.addAll(_section(_odeThemeA as List<List<int>>, 520, all.length));

  // Padding
  all.addAll(_padding(all.length));
  return all;
}

// ══════════════════════════════════════════════════════════════════════════════
// MELODÍA 2 – MEDIO  "Für Elise"
// Estructura: intro muy lenta → tema A × 2 normal → tema B rápido →
//             puente crescendo → tema A rápido × 3 → clímax → decrescendo
// Duración aproximada: ~2.5 min
// ══════════════════════════════════════════════════════════════════════════════

const _furThemeA = [
  [2, E5], [1, Ds5], [2, E5], [1, Ds5],
  [2, E5], [0, B4],  [1, D5], [0, C5],
  [0, A4], [1, C5],  [2, E5],
];

const _furThemeA2 = [
  [2, E5], [1, Ds5], [2, E5], [1, Ds5],
  [2, E5], [0, B4],  [1, D5], [0, C5],
  [0, A3], [1, E4],  [2, Gs4], [3, B4],
];

const _furThemeB = [
  [0, A4], [0, B4], [1, C5], [1, D5],
  [2, E5], [3, F5],
  [3, E5], [2, D5], [1, C5], [0, B4], [0, A4],
];

const _furBridge = [
  [1, E4], [2, A4], [3, E5], [2, C5], [1, A4],
  [0, E4], [0, A3],
  [1, Gs4], [2, B4], [3, E5], [2, B4], [1, Gs4],
  [0, E4], [0, B3],
];

const _furChorus = [
  [3, E5], [2, D5], [1, C5], [0, B4],
  [1, C5], [2, D5], [3, E5], [2, C5],
  [0, A4], [1, B4], [2, C5], [3, D5],
  [3, E5], [3, F5], [3, E5], [2, D5],
];

const _furClimax = [
  [3, A5], [2, Gs5], [3, A5], [2, Gs5],
  [3, A5], [1, E5],  [2, G5], [0, F5],
  [0, E5], [1, Gs5], [2, B5],
];

const _furCoda = [
  [2, E5], [1, Ds5], [2, E5], [1, Ds5],
  [2, E5], [0, B4], [1, D5], [0, C5],
  [0, A4], [0, A3],
];

List<Note> initNotesMedium() {
  final all = <Note>[];

  // 1. Intro muy lenta (600 ms)
  all.addAll(_section(_furThemeA as List<List<int>>, 600, all.length));

  // 2. Tema A normal (380 ms)
  all.addAll(_section(_furThemeA2 as List<List<int>>, 380, all.length));

  // 3. Tema B moderado (320 ms)
  all.addAll(_section(_furThemeB as List<List<int>>, 320, all.length));

  // 4. Puente crescendo (420→240)
  all.addAll(_crescendo(_furBridge as List<List<int>>, 420, 240, all.length));

  // 5. Estribillo rápido × 3 (200 ms)
  all.addAll(_repeat(_furChorus as List<List<int>>, 3, 200, all.length));

  // 6. Tema A rápido × 2 (220 ms)
  all.addAll(_repeat(_furThemeA as List<List<int>>, 2, 220, all.length));

  // 7. Clímax muy rápido (160 ms)
  all.addAll(_section(_furClimax as List<List<int>>, 160, all.length));

  // 8. Estribillo rápido × 2 (180 ms)
  all.addAll(_repeat(_furChorus as List<List<int>>, 2, 180, all.length));

  // 9. Puente moderado (280 ms)
  all.addAll(_section(_furBridge as List<List<int>>, 280, all.length));

  // 10. Tema A × 2 (300 ms)
  all.addAll(_repeat(_furThemeA2 as List<List<int>>, 2, 300, all.length));

  // 11. Crescendo hacia clímax 2 (300→160)
  all.addAll(_crescendo(_furChorus as List<List<int>>, 300, 160, all.length));

  // 12. Clímax 2 × 3 (160 ms)
  all.addAll(_repeat(_furClimax as List<List<int>>, 3, 160, all.length));

  // 13. Decrescendo final (200→550)
  all.addAll(_crescendo(_furCoda as List<List<int>>, 200, 550, all.length));

  // 14. Coda lenta (580 ms)
  all.addAll(_section(_furThemeA as List<List<int>>, 580, all.length));

  // Padding
  all.addAll(_padding(all.length));
  return all;
}

// ══════════════════════════════════════════════════════════════════════════════
// MELODÍA 3 – DIFÍCIL  "Moonlight Sonata"
// Estructura: intro muy lenta → desarrollo → clímax con arpegios rápidos →
//             múltiples crescendos → coda dramática
// Duración aproximada: ~3 min
// ══════════════════════════════════════════════════════════════════════════════

const _moonArp1 = [
  [0, Gs3], [1, Cs4], [2, E4],
  [0, Gs3], [1, Cs4], [2, E4],
];

const _moonArp2 = [
  [0, Gs3], [1, Ds4], [3, Fs4],
  [0, Gs3], [1, Ds4], [3, Fs4],
];

const _moonArp3 = [
  [0, A3],  [1, Cs4], [2, E4],
  [0, A3],  [1, Cs4], [2, E4],
];

const _moonArp4 = [
  [0, E3],  [1, B3],  [2, E4],
  [0, E3],  [1, B3],  [2, E4],
];

const _moonMelody = [
  [3, Cs5], [2, B4],  [3, Cs5], [2, A4],
  [1, Gs4], [0, Fs4], [1, Gs4], [0, E4],
];

const _moonDescent = [
  [3, E5],  [2, Cs5], [1, A4],  [0, Gs3],
  [3, Ds5], [2, B4],  [1, Gs4], [0, Fs3],
];

const _moonScale = [
  [0, Cs4], [1, Ds4], [2, E4],  [3, Fs4],
  [3, Gs4], [2, A4],  [1, B4],  [0, Cs5],
];

const _moonClimax = [
  [3, E5],  [3, Ds5], [3, E5],  [3, Ds5],
  [3, E5],  [2, B4],  [1, D5],  [0, C5],
];

const _moonResolution = [
  [0, A3],  [1, E4],  [2, A4],  [3, Cs5],
  [2, A4],  [1, E4],  [0, A3],  [0, E3],
];

const _moonCoda = [
  [0, A2],  [1, E3],  [2, A3],
  [0, Cs3], [1, Gs3], [2, Cs4],
  [0, A2],
];

const _moonFullArp = [
  [0, Gs3], [1, Cs4], [2, E4],
  [0, A3],  [1, Cs4], [2, E4],
  [0, Fs3], [1, Cs4], [2, Ds4],
  [0, E3],  [1, B3],  [2, E4],
  [0, Gs3], [1, B3],  [2, E4],
  [0, A3],  [1, E4],  [2, A4],
];

const _moonHighRun = [
  [1, Fs5], [2, Gs5], [3, A5],
  [2, B5],  [1, A5],  [0, Gs5],
  [1, Fs5], [2, E5],  [3, Ds5],
  [2, Cs5], [1, B4],  [0, A4],
];

List<Note> initNotesHard() {
  final all = <Note>[];

  // 1. Intro muy lenta – arpegios sostenidos (700 ms)
  all.addAll(_section(_moonArp1 as List<List<int>>, 700, all.length));
  all.addAll(_section(_moonArp2 as List<List<int>>, 700, all.length));
  all.addAll(_section(_moonArp3 as List<List<int>>, 700, all.length));
  all.addAll(_section(_moonArp4 as List<List<int>>, 700, all.length));

  // 2. Melodía superior aparece (500 ms)
  all.addAll(_section(_moonMelody as List<List<int>>, 500, all.length));

  // 3. Descenso dramático (480 ms)
  all.addAll(_section(_moonDescent as List<List<int>>, 480, all.length));

  // 4. Arpegios completos × 2 (450 ms)
  all.addAll(_repeat(_moonFullArp as List<List<int>>, 2, 450, all.length));

  // 5. Primer crescendo (500→280)
  all.addAll(_crescendo(_moonScale as List<List<int>>, 500, 280, all.length));

  // 6. Sección de desarrollo (320 ms)
  all.addAll(_section(_moonMelody as List<List<int>>, 320, all.length));
  all.addAll(_section(_moonDescent as List<List<int>>, 320, all.length));
  all.addAll(_section(_moonScale as List<List<int>>, 320, all.length));

  // 7. Arpegios más rápidos × 3 (280 ms)
  all.addAll(_repeat(_moonArp1 as List<List<int>>, 3, 280, all.length));
  all.addAll(_repeat(_moonArp3 as List<List<int>>, 3, 280, all.length));

  // 8. Segundo crescendo (320→180)
  all.addAll(_crescendo(_moonFullArp as List<List<int>>, 320, 180, all.length));

  // 9. Primer clímax (180 ms)
  all.addAll(_repeat(_moonClimax as List<List<int>>, 3, 180, all.length));

  // 10. Run agudo (160 ms)
  all.addAll(_section(_moonHighRun as List<List<int>>, 160, all.length));

  // 11. Resolución momentánea (280 ms)
  all.addAll(_section(_moonResolution as List<List<int>>, 280, all.length));

  // 12. Reexposición acelerada (240 ms)
  all.addAll(_section(_moonMelody as List<List<int>>, 240, all.length));
  all.addAll(_section(_moonDescent as List<List<int>>, 240, all.length));

  // 13. Tercer crescendo (260→140)
  all.addAll(_crescendo(_moonClimax as List<List<int>>, 260, 140, all.length));

  // 14. Clímax final muy rápido × 4 (140 ms)
  all.addAll(_repeat(_moonClimax as List<List<int>>, 4, 140, all.length));

  // 15. Run agudo × 2 (140 ms)
  all.addAll(_repeat(_moonHighRun as List<List<int>>, 2, 140, all.length));

  // 16. Decrescendo dramático (200→600)
  all.addAll(_crescendo(_moonResolution as List<List<int>>, 200, 600, all.length));

  // 17. Arpegios finales lentos (650 ms)
  all.addAll(_section(_moonArp1 as List<List<int>>, 650, all.length));
  all.addAll(_section(_moonArp3 as List<List<int>>, 650, all.length));

  // 18. Coda muy lenta (700 ms)
  all.addAll(_section(_moonCoda as List<List<int>>, 700, all.length));

  // Padding
  all.addAll(_padding(all.length, durationMs: 700));
  return all;
}