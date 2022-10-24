import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crclib/catalog.dart';
import 'package:plover_json_convert/chords.dart';
import 'package:plover_json_convert/plover_json_convert.dart';

void main(List<String> arguments) {
  final dictionary = <Chords, String>{};

  for (final filename in arguments.reversed) {
    dictionary.addAll(loadDictionary(filename));
  }

  final byStrokes = splitByStrokeCount(dictionary);
  print('// *** Autogenerated file ***');
  print('');
  print('// This is build using the following dictionaries');
  for (final filename in arguments) {
    print('// * ${filename.split('/').last}');
  }
  print('');
  print('#include "main_dictionary.h"');
  print('#include "map_dictionary_definition.h"');
  print('');

  final wordToOffsetMap = writeTextBlock(dictionary);

  for (var i = 0; i < byStrokes.length; ++i) {
    writeStrokeCount(i + 1, byStrokes[i], wordToOffsetMap);
    print('');
  }

  print('');
  print('const StenoMapDictionaryStrokesDefinition strokes[] = {');
  for (var i = 1; i <= byStrokes.length; ++i) {
    print(
      '  {.hashMapSize = hashMapSize$i, .data = data$i, .offsets = offsets$i},',
    );
  }
  print('};');
  print('');

  print(
      'constexpr StenoMapDictionaryDefinition MainDictionary::definition = {');
  print('  STENO_MAP_DICTIONARY_MAGIC,');
  print('  ${byStrokes.length},');
  print('  textBlock,');
  print('  strokes,');
  print('};');
}

class HashEntry {
  HashEntry(this.chords, this.text);

  final Chords chords;
  final String text;
}

void writeStrokeCount(
  int strokeCount,
  Map<Chords, String> map,
  Map<String, int> wordToOffsetMap,
) {
  if (map.isEmpty) {
    print('const size_t hashMapSize$strokeCount = 0;');
    print('const uint32_t *const data$strokeCount = nullptr;');
    print('const uint32_t *const offsets$strokeCount = nullptr;');
    return;
  }

  // Target duty cycle of 66%.
  final minimumHashMapSize = map.length + (map.length >> 1);
  var hashMapSize = 2;
  while (hashMapSize < minimumHashMapSize) {
    hashMapSize <<= 1;
  }

  // Build hashmap.
  final hashMap = List<HashEntry?>.filled(hashMapSize, null);
  map.forEach((key, value) {
    final hashValue = key.crc32Hash();
    var index = hashValue % hashMapSize;
    while (hashMap[index] != null) {
      index = (index + 1) % hashMapSize;
    }
    hashMap[index] = HashEntry(key, value);
  });

  print('const size_t hashMapSize$strokeCount = $hashMapSize;');

  writeData(strokeCount, hashMap, wordToOffsetMap);
}

void writeData(
  int strokeCount,
  List<HashEntry?> hashMap,
  Map<String, int> wordToOffsetMap,
) {
  final hashMapToOffset = <HashEntry, int>{};

  print('const uint32_t data$strokeCount[] = {');
  var offset = 1;

  for (final entry in hashMap) {
    if (entry == null) continue;

    stdout.write('  ${wordToOffsetMap[entry.text]},');
    for (var i = 0; i < strokeCount; ++i) {
      stdout.write(' ${entry.chords.chords[i].toMask()},');
    }
    print('');
    hashMapToOffset[entry] = offset;
    ++offset;
  }
  print('};');

  print('const uint32_t offsets$strokeCount[] = {');
  for (final entry in hashMap) {
    if (entry == null) {
      print('  0,');
    } else {
      print('  ${hashMapToOffset[entry]},');
    }
  }
  print('};');
}

Map<String, int> writeTextBlock(Map<Chords, String> map) {
  final wordToOffsetMap = <String, int>{};
  final builder = BytesBuilder();

  final wordList = map.values.toList()..sort((a, b) => b.length - a.length);

  builder.addByte(0);
  for (final word in wordList) {
    if (wordToOffsetMap.containsKey(word)) continue;

    final start = builder.length;
    wordToOffsetMap[word] = start;
    builder.add(utf8.encode(word));
    builder.addByte(0);

    for (var i = 1; i < word.length - 1; ++i) {
      final prefix = word.substring(0, i);
      final suffix = word.substring(i);
      final offset = utf8.encode(prefix).length;
      wordToOffsetMap[suffix] = start + offset;
    }
  }

  final data = builder.toBytes();
  stdout.write('const uint8_t textBlock[${data.length}] = {');
  for (var i = 0; i < data.length; ++i) {
    if (i % 16 == 0) stdout.write('\n ');
    stdout.write(' 0x${data[i].toRadixString(16).padLeft(2, '0')},');
  }
  stdout.write('\n};\n');

  return wordToOffsetMap;
}
