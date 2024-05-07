import 'package:flutter/foundation.dart';

extension ListPrettyPrint<T> on List<T> {
  String prettyString([int indentation = 0]) {
    final indent = '  ' * indentation;
    final buffer = StringBuffer();

    buffer.writeln('[');

    for (final element in this) {
      buffer.write('$indent  ');
      if (element is List) {
        buffer.writeln(element.prettyString(indentation + 1));
      } else if (element is Map) {
        buffer.writeln(element.prettyString(indentation + 1));
      } else {
        buffer.writeln(element);
      }
    }

    buffer.write('$indent]');

    return buffer.toString();
  }
}

extension MapPrettyPrint<K, V> on Map<K, V> {
  String prettyString([int indentation = 0]) {
    final indent = '  ' * indentation;
    final buffer = StringBuffer();

    buffer.writeln('{');

    for (final entry in entries) {
      buffer.write('$indent  ${entry.key}: ');
      if (entry.value case final Map<dynamic, dynamic> valMap) {
        buffer.writeln(valMap.prettyString(indentation + 1));
      } else if (entry.value case final List<dynamic> valList) {
        buffer.writeln(valList.prettyString(indentation + 1));
      } else {
        buffer.writeln(entry.value);
      }
    }

    buffer.write('$indent}');

    return buffer.toString();
  }
}

void debPrint(Object? object) {
  if (kDebugMode) print(object);
}
