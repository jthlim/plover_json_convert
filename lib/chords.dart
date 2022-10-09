import 'dart:io';

class Chord {
  const Chord(this._chord);

  final String _chord;

  static final pattern = RegExp(
    r"^(#?)(S|1)?(T|2)?(K?)(P|3)?(W?)(H|4)?(R?)(A|5)?(O|0)?(\*|-)?(E?)(U?)(F|6)?(R?)(P|7)?(B?)(L|8)?(G?)(T|9)?(S?)(D?)(Z?)$",
  );
  static final digitCheck = RegExp(r"\d");

  @override
  String toString() => _chord;

  int toMask() {
    final match = pattern.firstMatch(_chord);
    if (match == null) {
      print("Unable to split chord: $_chord");
      exit(1);
    }
    var mask = 0;
    for (var i = 1; i <= match.groupCount; ++i) {
      final group = match.group(i);
      if (group != null && group != '' && group != '-') {
        mask |= (1 << (i - 1));
      }
      if (digitCheck.hasMatch(_chord)) {
        mask |= 1;
      }
    }
    return mask;
  }
}

class Chords {
  Chords(String s) : chords = _chords(s);

  final List<Chord> chords;

  static List<Chord> _chords(String s) => s.split('/').map(Chord.new).toList();

  @override
  int get hashCode => chords.toString().hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! Chords) return false;
    return chords.toString() == other.chords.toString();
  }

  @override
  String toString() => chords.toString();
}
