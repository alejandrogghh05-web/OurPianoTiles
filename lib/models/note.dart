class Note {
  final int orderNumber;
  final int line;
  final int pitch; // Índice relativo: 0=C2, 1=Cs2, ..., 72=C8
  NoteState state = NoteState.ready;

  Note(this.orderNumber, this.line, {this.pitch = -1});
}

enum NoteState { ready, tapped, missed }

// ── Constantes de pitch (índice desde C2=0) ──────────────────────────────────
// Octava 2
const int C2 = 0,  Cs2 = 1,  D2 = 2,  Ds2 = 3,  E2 = 4,  F2 = 5,
          Fs2 = 6, G2 = 7,  Gs2 = 8,  A2 = 9,  As2 = 10, B2 = 11;
// Octava 3
const int C3 = 12, Cs3 = 13, D3 = 14, Ds3 = 15, E3 = 16, F3 = 17,
          Fs3 = 18, G3 = 19, Gs3 = 20, A3 = 21, As3 = 22, B3 = 23;
// Octava 4 (Do central)
const int C4 = 24, Cs4 = 25, D4 = 26, Ds4 = 27, E4 = 28, F4 = 29,
          Fs4 = 30, G4 = 31, Gs4 = 32, A4 = 33, As4 = 34, B4 = 35;
// Octava 5
const int C5 = 36, Cs5 = 37, D5 = 38, Ds5 = 39, E5 = 40, F5 = 41,
          Fs5 = 42, G5 = 43, Gs5 = 44, A5 = 45, As5 = 46, B5 = 47;
// Octava 6
const int C6 = 48, Cs6 = 49, D6 = 50, Ds6 = 51, E6 = 52, F6 = 53,
          Fs6 = 54, G6 = 55, Gs6 = 56, A6 = 57, As6 = 58, B6 = 59;
// Octava 7
const int C7 = 60, Cs7 = 61, D7 = 62, Ds7 = 63, E7 = 64, F7 = 65,
          Fs7 = 66, G7 = 67, Gs7 = 68, A7 = 69, As7 = 70, B7 = 71;
// Octava 8
const int C8 = 72;

/// Convierte un índice de pitch al path del asset WAV.
/// pitch 0 → 'C2.wav', pitch 12 → 'C3.wav', etc.
String pitchToAsset(int pitch) {
  const names = ['C','Cs','D','Ds','E','F','Fs','G','Gs','A','As','B'];
  final octave = (pitch ~/ 12) + 2;
  final name = names[pitch % 12];
  return '$name$octave.wav';
}
