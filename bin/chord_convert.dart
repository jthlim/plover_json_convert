import 'dart:io';

import 'package:plover_json_convert/chords.dart';

void main(List<String> arguments) {
  for (;;) {
    stdout.write('Enter chord: ');

    String? chordText = stdin.readLineSync();
    if (chordText == null) break;

    final chord = Chord(chordText);
    print('0x${chord.toMask().toRadixString(16)} /*$chord*/');
  }
}
