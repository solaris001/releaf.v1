import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeUtil on DateTime {
  int get calenderWeek {
    final firstDayOfYear = DateTime(year);
    final daysSinceFirstDayOfYear = difference(firstDayOfYear).inDays;
    return (daysSinceFirstDayOfYear / 7).ceil();
  }
}

/// Like DateTime, but without time
///
/// This class is immutable, and has no time component.
///
/// It does not account for time zones or daylight saving time.
@immutable
class Date implements Comparable<Date> {
  const Date(this.year, [this.month = 1, this.day = 1]);

  Date.fromDateTime(DateTime dateTime)
      : year = dateTime.year,
        month = dateTime.month,
        day = dateTime.day;

  Date.fromMillisecondsSinceEpoch(int millisecondsSinceEpoch)
      : this.fromDateTime(
          DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
        );

  Date.fromIso8601String(String iso8601String)
      : this.fromDateTime(
          DateTime.parse(iso8601String),
        );

  Date.fromMicrosecondsSinceEpoch(int microsecondsSinceEpoch)
      : this.fromDateTime(
          DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch),
        );

  Date.fromDaysSinceEpoch(int daysSinceEpoch)
      : this.fromDateTime(
          DateTime(1970).add(Duration(days: daysSinceEpoch)),
        );

  Date subtract(int days) =>
      Date.fromDateTime(toDateTime().subtract(Duration(days: days)));

  Date add(int days) =>
      Date.fromDateTime(toDateTime().add(Duration(days: days)));

  int difference(Date other) =>
      toDateTime().difference(other.toDateTime()).inDays;

  static Date today() => Date.fromDateTime(DateTime.now());

  bool isBefore(Date other) => compareTo(other) < 0;

  bool isAfter(Date other) => compareTo(other) > 0;

  int get calenderWeek {
    final firstDayOfYear = Date(year);
    final daysSinceFirstDayOfYear = difference(firstDayOfYear) + 1;
    return (daysSinceFirstDayOfYear / 7).ceil();
  }

  final int year;
  final int month;
  final int day;

  int get millisecondsSinceEpoch => toDateTime().millisecondsSinceEpoch;

  int get microsecondsSinceEpoch => toDateTime().microsecondsSinceEpoch;

  int get weekday => toDateTime().weekday;

  int get daysSinceEpoch => toDateTime().difference(DateTime(1970)).inDays;

  DateTime toDateTime() => DateTime(year, month, day);

  @override
  String toString() => '$year-$month-$day';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Date &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;

  Date copyWith({
    int? year,
    int? month,
    int? day,
  }) {
    return Date(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
    );
  }

  @override
  int compareTo(Date other) {
    if (year != other.year) {
      return year.compareTo(other.year);
    }
    if (month != other.month) {
      return month.compareTo(other.month);
    }
    return day.compareTo(other.day);
  }
}

extension DateFormatDate on DateFormat {
  String formatDate(Date date) {
    return DateFormat(pattern).format(date.toDateTime());
  }
}
