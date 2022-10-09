import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'chords.dart';

Map<Chords, String> loadDictionary(String filename) {
  final file = File(filename);
  final source = file.readAsStringSync();
  final jsonMap = jsonDecode(source);

  final result = <Chords, String>{};

  for (final key in jsonMap.keys) {
    final chords = Chords(key!);
    final value = jsonMap[key].toString();
    result[chords] = value;
  }

  return result;
}

List<Map<Chords, String>> splitByStrokeCount(Map<Chords, String> map) {
  final maxStrokes = map.keys.fold(0, (p, e) => max(p, e.chords.length));
  final result =
      List<Map<Chords, String>>.generate(maxStrokes, (_) => <Chords, String>{});

  map.forEach((key, value) {
    result[key.chords.length - 1][key] = value;
  });

  return result;
}
