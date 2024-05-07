extension DurationToString on Duration {
  /// converts a [Duration] to a [String] in "hh:mm:ss" format
  ///
  /// ```dart
  /// Duration(hours: 1, minutes: 10, seconds: 9).toHHMMSSString()
  /// ```
  /// returns
  /// `01:10:09`
  String toHHMMSSString() {
    final hours = inHours;
    final minutes = inMinutes - inHours * 60;
    final seconds = inSeconds - inMinutes * 60;
    return "${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }

  /// converts a [Duration] to a [String] in "mm:ss" format
  ///
  /// ```dart
  /// Duration(hours: 1, minutes: 10, seconds: 9).toHHMMSSString()
  /// ```
  /// returns
  /// `70:09`
  String toMMSSString() {
    final minutes = inMinutes;
    final seconds = inSeconds - inMinutes * 60;
    return "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }
}

/// returns true if the [previous] date was in the last week or older relative to [current]
/// returns false if [previous] is in the same week as [current]
bool wasInPreviousWeek(DateTime previous, DateTime current) {
  return (previous.weekday > current.weekday ||
          current.difference(previous) >= const Duration(days: 7)) &&
      previous.isBefore(current);
}
