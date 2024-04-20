// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:releaf/utilities/duration_extension.dart';

void main() {
  test('test wasInPreviousWeek from Wednesday', () {
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 1), DateTime(2023, 07, 12)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 2), DateTime(2023, 07, 12)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 3), DateTime(2023, 07, 12)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 4), DateTime(2023, 07, 12)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 5), DateTime(2023, 07, 12)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 6), DateTime(2023, 07, 12)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 7), DateTime(2023, 07, 12)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 8), DateTime(2023, 07, 12)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 9), DateTime(2023, 07, 12)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 10), DateTime(2023, 07, 12)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 11), DateTime(2023, 07, 12)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 12), DateTime(2023, 07, 12)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 13), DateTime(2023, 07, 12)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 14), DateTime(2023, 07, 12)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 15), DateTime(2023, 07, 12)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 16), DateTime(2023, 07, 12)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 17), DateTime(2023, 07, 12)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 18), DateTime(2023, 07, 12)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 19), DateTime(2023, 07, 12)),
      equals(false),
    );
  });

  test('test wasInPreviousWeek from Monday', () {
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 1), DateTime(2023, 07, 10)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 2), DateTime(2023, 07, 10)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 3), DateTime(2023, 07, 10)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 4), DateTime(2023, 07, 10)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 5), DateTime(2023, 07, 10)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 6), DateTime(2023, 07, 10)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 7), DateTime(2023, 07, 10)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 8), DateTime(2023, 07, 10)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 9), DateTime(2023, 07, 10)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 10), DateTime(2023, 07, 10)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 11), DateTime(2023, 07, 10)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 12), DateTime(2023, 07, 10)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 13), DateTime(2023, 07, 10)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 14), DateTime(2023, 07, 10)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 15), DateTime(2023, 07, 10)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 16), DateTime(2023, 07, 10)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 17), DateTime(2023, 07, 10)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 18), DateTime(2023, 07, 10)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 19), DateTime(2023, 07, 10)),
      equals(false),
    );
  });

  test('test wasInPreviousWeek from Sunday', () {
    expect(
      wasInPreviousWeek(DateTime(2020, 01, 1), DateTime(2023, 07, 16)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 06, 30), DateTime(2023, 07, 16)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 1), DateTime(2023, 07, 16)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 2), DateTime(2023, 07, 16)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 3), DateTime(2023, 07, 16)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 4), DateTime(2023, 07, 16)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 5), DateTime(2023, 07, 16)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 6), DateTime(2023, 07, 16)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 7), DateTime(2023, 07, 16)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 8), DateTime(2023, 07, 16)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 9), DateTime(2023, 07, 16)),
      equals(true),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 10), DateTime(2023, 07, 16)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 11), DateTime(2023, 07, 16)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 12), DateTime(2023, 07, 16)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 13), DateTime(2023, 07, 16)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 14), DateTime(2023, 07, 16)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 15), DateTime(2023, 07, 16)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 16), DateTime(2023, 07, 16)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 17), DateTime(2023, 07, 16)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 18), DateTime(2023, 07, 16)),
      equals(false),
    );
    expect(
      wasInPreviousWeek(DateTime(2023, 07, 19), DateTime(2023, 07, 16)),
      equals(false),
    );
  });

  test('test wasInPreviousWeek edge cases', () {
    expect(
      wasInPreviousWeek(
        DateTime(2023, 07, 09, 23, 59, 59, 999, 999),
        DateTime(2023, 07, 10, 0, 0, 0, 0),
      ),
      equals(true),
    );
    expect(
      wasInPreviousWeek(
        DateTime(2023, 07, 10, 0, 0, 0, 0),
        DateTime(2023, 07, 10, 0, 0, 0, 0),
      ),
      equals(false),
    );
    expect(
      wasInPreviousWeek(
        DateTime(2023, 07, 10, 0, 0, 0, 0),
        DateTime(2023, 07, 16, 23, 59, 59, 999, 999),
      ),
      equals(false),
    );
    expect(
      wasInPreviousWeek(
        DateTime(2023, 07, 10, 0, 0, 0, 0),
        DateTime(2023, 07, 17, 0, 0, 0, 0, 0),
      ),
      equals(true),
    );
  });
}
