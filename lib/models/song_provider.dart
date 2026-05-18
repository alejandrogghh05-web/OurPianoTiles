import 'package:piano_tiles/models/note.dart';

// ── Melodía 1 – Fácil ─────────────────────────────────────────────────────────
// Patrón suave y predecible, movimientos graduales (La menor simple)
List<Note> initNotes() {
  return [
    Note(0, 0),  Note(1, 1),  Note(2, 2),  Note(3, 1),
    Note(4, 3),  Note(5, 0),  Note(6, 1),  Note(7, 2),
    Note(8, 3),  Note(9, 2),  Note(10, 3), Note(11, 0),
    Note(12, 2), Note(13, 1), Note(14, 3), Note(15, 0),
    Note(16, 1), Note(17, 2), Note(18, 3), Note(19, 2),
    Note(20, 3), Note(21, 1), Note(22, 2), Note(23, 1),
    Note(24, 3), Note(25, 0), Note(26, 1), Note(27, 2),
    Note(28, 3), Note(29, 2), Note(30, 3), Note(31, 1),
    Note(32, 2), Note(33, 1), Note(34, 3), Note(35, 0),
    Note(36, 1), Note(37, 2), Note(38, 3), Note(39, 2),
    Note(40, 3),
    Note(41, -1), Note(42, -1), Note(43, -1), Note(44, -1),
  ];
}

// ── Melodía 2 – Medio ─────────────────────────────────────────────────────────
// Inspirada en "Für Elise" (fragmento simplificado a 4 columnas).
// Más saltos entre columnas extremas, ritmo irregular.
List<Note> initNotesMedium() {
  return [
    // Frase A: mi-re#-mi-re#-mi-si-re-do (columnas: 2-1-2-1-2-3-0-3)
    Note(0, 2),  Note(1, 1),  Note(2, 2),  Note(3, 1),
    Note(4, 2),  Note(5, 3),  Note(6, 0),  Note(7, 3),
    // Frase B: la-do-mi (columnas: 0-3-2)
    Note(8, 0),  Note(9, 3),  Note(10, 2),
    // Repetición variada A
    Note(11, 2), Note(12, 1), Note(13, 2), Note(14, 1),
    Note(15, 2), Note(16, 3), Note(17, 0), Note(18, 3),
    // Frase C: saltos amplios
    Note(19, 0), Note(20, 3), Note(21, 1), Note(22, 3),
    Note(23, 0), Note(24, 2), Note(25, 3), Note(26, 1),
    // Frase D: descenso escalonado
    Note(27, 3), Note(28, 2), Note(29, 1), Note(30, 0),
    Note(31, 1), Note(32, 2), Note(33, 3), Note(34, 2),
    // Cierre
    Note(35, 1), Note(36, 0), Note(37, 1), Note(38, 2),
    Note(39, 3), Note(40, 2), Note(41, 0),
    Note(42, -1), Note(43, -1), Note(44, -1), Note(45, -1),
  ];
}

// ── Melodía 3 – Difícil ───────────────────────────────────────────────────────
// Inspirada en "Ode to Joy" con saltos rápidos y patrones cruzados.
// Muchos cambios de extremo a extremo para máxima dificultad.
List<Note> initNotesHard() {
  return [
    // Frase A: mi-mi-fa-sol (col 2-2-3-3)
    Note(0, 2),  Note(1, 2),  Note(2, 3),  Note(3, 3),
    // sol-fa-mi-re (col 3-3-2-1)
    Note(4, 3),  Note(5, 3),  Note(6, 2),  Note(7, 1),
    // do-do-re-mi (col 0-0-1-2)
    Note(8, 0),  Note(9, 0),  Note(10, 1), Note(11, 2),
    // mi-re-re (col 2-1-1)
    Note(12, 2), Note(13, 1), Note(14, 1),
    // Frase B con saltos amplios
    Note(15, 2), Note(16, 2), Note(17, 3), Note(18, 3),
    Note(19, 3), Note(20, 3), Note(21, 2), Note(22, 1),
    Note(23, 0), Note(24, 2), Note(25, 1), Note(26, 0),
    Note(27, 1), Note(28, 0), Note(29, 0),
    // Puente: saltos cruzados extremos
    Note(30, 0), Note(31, 3), Note(32, 0), Note(33, 3),
    Note(34, 1), Note(35, 2), Note(36, 0), Note(37, 3),
    Note(38, 2), Note(39, 1), Note(40, 3), Note(41, 0),
    // Repetición acelerada frase A
    Note(42, 2), Note(43, 2), Note(44, 3), Note(45, 3),
    Note(46, 3), Note(47, 2), Note(48, 1), Note(49, 0),
    Note(50, 1), Note(51, 2), Note(52, 3), Note(53, 2),
    Note(54, 1), Note(55, 0),
    Note(56, -1), Note(57, -1), Note(58, -1), Note(59, -1),
  ];
}