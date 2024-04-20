import 'package:flutter_test/flutter_test.dart';
import 'package:releaf/utilities/datetime_extension.dart';

void main() {
  test('test Date class .subtract()', () {
    expect(
      const Date(2023, 07, 12).subtract(1),
      equals(const Date(2023, 07, 11)),
    );
    expect(
      const Date(2023, 07, 12).subtract(0),
      equals(const Date(2023, 07, 12)),
    );
    expect(
      const Date(2023, 07, 12).subtract(2),
      equals(const Date(2023, 07, 10)),
    );
    // Edge case: Subtracting 1 day from the start of a month
    expect(
      const Date(2023, 07).subtract(1),
      equals(const Date(2023, 06, 30)),
    );

    // Edge case: Subtracting 1 day from the start of a year
    expect(
      const Date(2023).subtract(1),
      equals(const Date(2022, 12, 31)),
    );

    // Subtracting 0 days should return the same date
    expect(
      const Date(2023, 07, 12).subtract(0),
      equals(const Date(2023, 07, 12)),
    );

    // Subtracting 2 days from the start of a month
    expect(
      const Date(2023, 07).subtract(2),
      equals(const Date(2023, 06, 29)),
    );

    // Subtracting 2 days from the start of a year
    expect(
      const Date(2023).subtract(2),
      equals(const Date(2022, 12, 30)),
    );
  });

  test('test Date class .add()', () {
    expect(
      const Date(2023, 07, 12).add(1),
      equals(const Date(2023, 07, 13)),
    );
    expect(
      const Date(2023, 07, 12).add(0),
      equals(const Date(2023, 07, 12)),
    );
    expect(
      const Date(2023, 07, 12).add(2),
      equals(const Date(2023, 07, 14)),
    );
    // Edge case: Adding 1 day to the end of a month
    expect(
      const Date(2023, 07, 31).add(1),
      equals(const Date(2023, 08)),
    );

    // Edge case: Adding 1 day to the end of a year
    expect(
      const Date(2023, 12, 31).add(1),
      equals(const Date(2024)),
    );

    // Adding 0 days should return the same date
    expect(
      const Date(2023, 07, 12).add(0),
      equals(const Date(2023, 07, 12)),
    );

    // Adding 2 days to the end of a month
    expect(
      const Date(2023, 07, 31).add(2),
      equals(const Date(2023, 08, 02)),
    );

    // Adding 2 days to the end of a year
    expect(
      const Date(2023, 12, 31).add(2),
      equals(const Date(2024, 01, 02)),
    );
  });

  test('test Date class .difference()', () {
    expect(
      const Date(2023, 07, 12).difference(const Date(2023, 07, 11)),
      equals(1),
    );
    expect(
      const Date(2023, 07, 12).difference(const Date(2023, 07, 12)),
      equals(0),
    );
    expect(
      const Date(2023, 07, 12).difference(const Date(2023, 07, 10)),
      equals(2),
    );
    // Edge case: Subtracting 1 day from the start of a month
    expect(
      const Date(2023, 07).difference(const Date(2023, 06, 30)),
      equals(1),
    );

    // Edge case: Subtracting 1 day from the start of a year
    expect(
      const Date(2023).difference(const Date(2022, 12, 31)),
      equals(1),
    );

    // Subtracting 0 days should return the same date
    expect(
      const Date(2023, 07, 12).difference(const Date(2023, 07, 12)),
      equals(0),
    );

    // Subtracting 2 days from the start of a month
    expect(
      const Date(2023, 07).difference(const Date(2023, 06, 29)),
      equals(2),
    );

    // Subtracting 2 days from the start of a year
    expect(
      const Date(2023).difference(const Date(2022, 12, 30)),
      equals(2),
    );
  });

  test('test Date class ==', () {
    expect(
      const Date(2023, 07, 12) == const Date(2023, 07, 12),
      equals(true),
    );
    expect(
      const Date(2023, 07, 12) == const Date(2023, 07, 11),
      equals(false),
    );
    expect(
      const Date(2023, 07, 12) == const Date(2023, 07, 13),
      equals(false),
    );
    expect(
      const Date(2023, 07, 12) == const Date(2024, 07, 12),
      equals(false),
    );
    expect(
      const Date(2023, 07, 12) == const Date(2023, 08, 12),
      equals(false),
    );
  });

  test('test Date class .compareTo()', () {
    expect(
      const Date(2023, 07, 12).compareTo(const Date(2023, 07, 12)),
      equals(0),
    );
    expect(
      const Date(2023, 07, 12).compareTo(const Date(2023, 07, 11)),
      equals(1),
    );
    expect(
      const Date(2023, 07, 12).compareTo(const Date(2023, 07, 13)),
      equals(-1),
    );
    expect(
      const Date(2023, 07, 12).compareTo(const Date(2024, 07, 12)),
      equals(-1),
    );
    expect(
      const Date(2023, 07, 12).compareTo(const Date(2023, 08, 12)),
      equals(-1),
    );
  });

  // test isBefore
  test('test Date class .isBefore()', () {
    expect(
      const Date(2023, 07, 12).isBefore(const Date(2023, 07, 12)),
      equals(false),
    );
    expect(
      const Date(2023, 07, 12).isBefore(const Date(2023, 07, 11)),
      equals(false),
    );
    expect(
      const Date(2023, 07, 12).isBefore(const Date(2023, 07, 13)),
      equals(true),
    );
    expect(
      const Date(2023, 07, 12).isBefore(const Date(2024, 07, 12)),
      equals(true),
    );
    expect(
      const Date(2023, 07, 12).isBefore(const Date(2023, 08, 12)),
      equals(true),
    );
  });

  // test isAfter
  test('test Date class .isAfter()', () {
    expect(
      const Date(2023, 07, 12).isAfter(const Date(2023, 07, 12)),
      equals(false),
    );
    expect(
      const Date(2023, 07, 12).isAfter(const Date(2023, 07, 11)),
      equals(true),
    );
    expect(
      const Date(2023, 07, 12).isAfter(const Date(2023, 07, 13)),
      equals(false),
    );
    expect(
      const Date(2023, 07, 12).isAfter(const Date(2024, 07, 12)),
      equals(false),
    );
    expect(
      const Date(2023, 07, 12).isAfter(const Date(2023, 08, 12)),
      equals(false),
    );
  });

  // test calenderWeek
  test('test Date class .calenderWeek', () {
    expect(
      const Date(2023).calenderWeek,
      equals(1),
    );
    expect(
      const Date(2023, 01, 07).calenderWeek,
      equals(1),
    );
    expect(
      const Date(2023, 01, 08).calenderWeek,
      equals(2),
    );
    expect(
      const Date(2023, 01, 14).calenderWeek,
      equals(2),
    );
    expect(
      const Date(2023, 01, 15).calenderWeek,
      equals(3),
    );
    expect(
      const Date(2023, 01, 21).calenderWeek,
      equals(3),
    );
    expect(
      const Date(2023, 01, 22).calenderWeek,
      equals(4),
    );
    expect(
      const Date(2023, 01, 28).calenderWeek,
      equals(4),
    );
    expect(
      const Date(2023, 01, 29).calenderWeek,
      equals(5),
    );
    expect(
      const Date(2023, 02, 04).calenderWeek,
      equals(5),
    );
    expect(
      const Date(2023, 02, 05).calenderWeek,
      equals(6),
    );
    expect(
      const Date(2023, 02, 11).calenderWeek,
      equals(6),
    );
    expect(
      const Date(2023, 02, 12).calenderWeek,
      equals(7),
    );
    expect(
      const Date(2023, 02, 18).calenderWeek,
      equals(7),
    );
    expect(
      const Date(2023, 02, 19).calenderWeek,
      equals(8),
    );
    expect(
      const Date(2023, 02, 25).calenderWeek,
      equals(8),
    );
    expect(
      const Date(2023, 02, 26).calenderWeek,
      equals(9),
    );
    expect(
      const Date(2023, 03, 04).calenderWeek,
      equals(9),
    );
  });
}
