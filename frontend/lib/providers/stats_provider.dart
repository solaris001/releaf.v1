// ignore_for_file: use_setters_to_change_properties

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:releaf/utilities/datetime_extension.dart';
import 'package:releaf/utilities/pretty_print.dart';

class DailyStats {
  /// Creates a new [DailyStats] instance for the given day
  ///
  /// The [studyGoalMinutes] can only be set once in the constructor
  /// if the user changes the study goal in the app's settings, it will only apply for future [DailyStats] instances
  DailyStats(int studyGoalMinutes) {
    _date = Date.today();

    _studyGoalMinutes = studyGoalMinutes;
  }

  /// Creates a new [DailyStats] instance from JSON Map
  factory DailyStats.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'date': final int daysSinceEpoch, // in days since epoch
          'articlesRead': final int articlesRead,
          'minutesSpentStudying': final int minutesSpentStudying,
          'studyGoalMinutes': final int studyGoalMinutes,
          'happyHourStats': final Map<String, dynamic> happyHourStats,
        }) {
      final date = Date.fromDaysSinceEpoch(daysSinceEpoch);

      if (date.isBefore(const Date(1900)) || date.isAfter(const Date(3000))) {
        throw Exception('Invalid date: $date');
      }

      return DailyStats._(
        date: date,
        articlesRead: articlesRead,
        minutesSpentStudying: minutesSpentStudying,
        studyGoalMinutes: studyGoalMinutes,
        happyHourStats: HappyHourStats.fromJson(happyHourStats),
      );
    }
    throw Exception('Unable to parse DailyStats:\n $json');
  }

  /// internal constructor to create a new [DailyStats] instance from JSON
  DailyStats._({
    required Date date,
    required int articlesRead,
    required int minutesSpentStudying,
    required int studyGoalMinutes,
    required HappyHourStats happyHourStats,
  })  : _date = date,
        _articlesRead = articlesRead,
        _minutesSpentStudying = minutesSpentStudying,
        _studyGoalMinutes = studyGoalMinutes,
        _happyHourStats = happyHourStats;

  /// converts the [DailyStats] instance to JSON compatible Map
  Map<String, dynamic> toJson() {
    return {
      'date': _date.daysSinceEpoch,
      'articlesRead': _articlesRead,
      'minutesSpentStudying': _minutesSpentStudying,
      'studyGoalMinutes': _studyGoalMinutes,
      'happyHourStats': _happyHourStats.toJson(),
    };
  }

  /// The day for which the stats are tracked
  Date get date => _date;
  late Date _date;

  /// The number of articles the user has read on the given day
  int get articlesRead => _articlesRead;
  int _articlesRead = 0;

  /// The number of feedbacks the user has given on the given day
  int get feedbacksGiven {
    var count = 0;
    if (_happyHourStats.entryHappy.isNotEmpty) count++;
    if (_happyHourStats.entryProud.isNotEmpty) count++;
    if (_happyHourStats.entryThankful.isNotEmpty) count++;
    if (_happyHourStats.entryTomorrow.isNotEmpty) count++;
    return count;
  }

  /// The number of minutes the user has spent studying on the given day
  int get minutesSpentStudying => _minutesSpentStudying;
  int _minutesSpentStudying = 0;

  /// The number of minutes the user has spent studying on the given day
  /// can only be set once in the constructor
  /// if the user changes the study goal in the app's settings, it will only apply for future [DailyStats] instances
  int get studyGoalMinutes => _studyGoalMinutes;
  late final int _studyGoalMinutes;

  HappyHourStats get happyHourStats => _happyHourStats;
  HappyHourStats _happyHourStats = HappyHourStats('', '', '', '');

  /// The number of articles the user has read in total to earn the article leaf
  static const int articleLeafThreshold = 5;

  /// The number of feedbacks the user has given in total to earn the feedback leaf
  static const int feedbackLeafThreshold = 4;

  /// whether the user has earned the article leaf, based on the number of articles read vs the threshold
  bool get hasArticleLeaf => _articlesRead >= articleLeafThreshold;

  /// whether the user has earned the feedback leaf, based on the number of feedbacks given vs the threshold
  bool get hasFeedbackLeaf => feedbacksGiven >= feedbackLeafThreshold;

  /// whether the user has earned the study leaf, based on the number of minutes spent studying vs the study goal
  bool get hasStudyLeaf => _minutesSpentStudying >= _studyGoalMinutes;

  /// The progress of the user towards earning the article leaf (0 - 1)
  double get articleLeafProgress => _articlesRead / articleLeafThreshold;

  /// The progress of the user towards earning the feedback leaf (0 - 1)
  double get feedbackLeafProgress => feedbacksGiven / feedbackLeafThreshold;

  /// The progress of the user towards earning the study leaf (0 - 1)
  double get studyLeafProgress => _minutesSpentStudying / _studyGoalMinutes;

  /// The total progress of the user towards earning all leaves (0 - 1)
  double get totalProgress =>
      (articleLeafProgress + feedbackLeafProgress + studyLeafProgress) / 3;

  int get leafCount {
    var count = 0;
    if (hasArticleLeaf) count++;
    if (hasFeedbackLeaf) count++;
    if (hasStudyLeaf) count++;
    return count;
  }

  void _incrementArticlesRead() {
    _articlesRead++;
  }

  void _setArticlesRead(int articlesRead) {
    _articlesRead = articlesRead;
  }

  void _incrementMinutesSpentStudying(int minutesSpentStudying) {
    _minutesSpentStudying += minutesSpentStudying;
  }

  void _setMinutesSpentStudying(int minutesSpentStudying) {
    _minutesSpentStudying = minutesSpentStudying;
  }

  void _setHappyHourStats(HappyHourStats happyHourStats) {
    _happyHourStats = happyHourStats;
  }

  @override
  String toString() {
    return 'DailyStats{\n\tdate: $_date, \n\tarticlesRead: $_articlesRead, \n\tminutesSpentStudying: $_minutesSpentStudying, \n\tstudyGoalMinutes: $_studyGoalMinutes, \n\thappyHourStats: $_happyHourStats\n}';
  }
}

class StatsProvider with ChangeNotifier {
  StatsProvider() {
    loadStatsFromFile().then((_) {
      // ! SAMPLE DATA

      _dailyStats.addAll(
        {
          Date.today().subtract(1): DailyStats._(
            date: Date.today().subtract(1),
            articlesRead: 5,
            minutesSpentStudying: 132,
            studyGoalMinutes: 120,
            happyHourStats: HappyHourStats('yes', 'no', 'maybe', 'tomorrow?'),
          ),
          Date.today().subtract(2): DailyStats._(
            date: Date.today().subtract(2),
            articlesRead: 4,
            minutesSpentStudying: 30,
            studyGoalMinutes: 60,
            happyHourStats: HappyHourStats('yes', 'no', 'maybe', 'tomorrow?'),
          ),
          Date.today().subtract(3): DailyStats._(
            date: Date.today().subtract(3),
            articlesRead: 3,
            minutesSpentStudying: 60,
            studyGoalMinutes: 60,
            happyHourStats: HappyHourStats('yes', 'no', 'maybe', 'tomorrow?'),
          ),
          Date.today().subtract(4): DailyStats._(
            date: Date.today().subtract(4),
            articlesRead: 2,
            minutesSpentStudying: 60,
            studyGoalMinutes: 120,
            happyHourStats: HappyHourStats('yes', 'no', 'maybe', 'tomorrow?'),
          ),
          Date.today().subtract(50): DailyStats._(
            date: Date.today().subtract(50),
            articlesRead: 1,
            minutesSpentStudying: 60,
            studyGoalMinutes: 60,
            happyHourStats: HappyHourStats('yes', 'no', 'maybe', 'tomorrow?'),
          ),
        },
      );

      // ! END SAMPLE DATA

      // ? Recalculate perDayStats
      recalculatePerDayStats();

      // ? Save Changes and update UI
      notifyListeners();
    });
  }

  /*
   Using SplayTreeMap to keep the keys always sorted also using a Map instead of a List prevents us from having duplicate stats for a given day
  */
  SplayTreeMap<Date, DailyStats> get dailyStats => _dailyStats;
  final SplayTreeMap<Date, DailyStats> _dailyStats = SplayTreeMap();

  /// a version of [dailyStats] that includes null values for days that have no stats yet
  Map<Date, DailyStats?> get perDayStats => _perDayStats;
  final Map<Date, DailyStats?> _perDayStats = {};

  int _studyGoalMinutes = 60;

  DailyStats get todaysStats {
    final today = Date.today();

    if (_dailyStats.isEmpty || _dailyStats.lastKey() != today) {
      // TODO(MindStudioOfficial): get study goal from settings

      final newStats = DailyStats(_studyGoalMinutes);
      _dailyStats.addAll({today: newStats});
      return newStats;
    }

    return _dailyStats[today]!;
  }

  /// The number of days with at least one leaf earned
  int get leafStreak {
    var count = 0;
    // Iterate through perDayStats and check the leafCount for each day
    for (final MapEntry(key: _, value: stat) in perDayStats.entries) {
      // Check if DailyStats is not null and has earned at least one leaf
      if (stat?.leafCount != null && stat!.leafCount > 0) {
        count++;
      } else {
        // If there's a day without stats or no leaf earned, break the loop
        break;
      }
    }
    return count;
  }

  void incrementArticlesRead() {
    todaysStats._incrementArticlesRead();
    notifyListeners();
  }

  void setArticlesRead(int articlesRead) {
    todaysStats._setArticlesRead(articlesRead);
    notifyListeners();
  }

  void incrementMinutesSpentStudying(int minutesSpentStudying) {
    todaysStats._incrementMinutesSpentStudying(minutesSpentStudying);
    notifyListeners();
  }

  void setMinutesSpentStudying(int minutesSpentStudying) {
    todaysStats._setMinutesSpentStudying(minutesSpentStudying);
    notifyListeners();
  }

  void setStudyGoalMinutes(int studyGoalMinutes) {
    _studyGoalMinutes = studyGoalMinutes;
    notifyListeners();
  }

  void setHappyHourStats(HappyHourStats happyHourStats) {
    todaysStats._setHappyHourStats(happyHourStats);
    notifyListeners();
  }

  /// For loading the daily stats from JSON
  void loadDailyStats(List<dynamic> json) {
    _dailyStats.clear();
    for (final entry in json) {
      if (entry is Map<String, dynamic>) {
        final newDailyStats = DailyStats.fromJson(entry);
        _dailyStats.addAll({newDailyStats.date: newDailyStats});
        debPrint('Loaded stats: ${newDailyStats.date}');
      } else {
        debPrint('Error loading stats: $entry');
      }
    }
  }

  /// For saving the daily stats to JSON
  List<Map<String, dynamic>> get dailyStatsJson {
    final json = <Map<String, dynamic>>[];

    for (final MapEntry(key: _, value: stat) in _dailyStats.entries) {
      json.add(stat.toJson());
    }
    return json;
  }

  void recalculatePerDayStats() {
    _perDayStats.clear();

    final today = Date.today();

    final firstDay = _dailyStats.firstKey();

    if (firstDay == null) {
      return;
    }

    // add null values for days that have no stats yet
    // also traverse the list in reverse order to get the most recent stats first
    for (var day = today;
        day.isAfter(firstDay.subtract(1));
        day = day.subtract(1)) {
      if (_dailyStats.keys.any((dailyDate) => dailyDate == day)) {
        _perDayStats.addAll(
          {
            day: _dailyStats.values
                .firstWhere((dailyStat) => dailyStat.date == day),
          },
        );
      } else {
        _perDayStats.addAll({day: null});
      }
    }
  }

  @override
  void notifyListeners() {
    saveStatsToFile();
    recalculatePerDayStats();
    super.notifyListeners();
  }

  @override
  String toString() {
    return 'StatsProvider{dailyStats: $_dailyStats}';
  }

  Future<File> get _saveFile async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/stats.json');
    if (!file.existsSync()) {
      await file.create();
    }
    return file;
  }

  Future<void> loadStatsFromFile() async {
    try {
      final file = await _saveFile;
      final fileContent = await file.readAsString();
      final jsonList = jsonDecode(fileContent);
      if (jsonList is List) {
        loadDailyStats(jsonList);
      } else {
        debPrint('Error loading stats: $jsonList');
      }
    } catch (e) {
      debPrint('Error loading stats: $e');
    }
  }

  Future<void> saveStatsToFile() async {
    try {
      final file = await _saveFile;
      await file.writeAsString(jsonEncode(dailyStatsJson));
      debPrint('Saved stats.');
    } catch (e) {
      debPrint('Error saving stats: $e');
    }
  }
}

class HappyHourStats {
  HappyHourStats(
    this._entryHappy,
    this._entryProud,
    this._entryThankful,
    this._entryTomorrow,
  );

  factory HappyHourStats.fromJson(Map<String, dynamic> json) {
    return HappyHourStats(
      json['entryHappy'] as String,
      json['entryProud'] as String,
      json['entryThankful'] as String,
      json['entryTomorrow'] as String,
    );
  }

  Map<String, String?> toJson() {
    return {
      'entryHappy': _entryHappy,
      'entryProud': _entryProud,
      'entryThankful': _entryThankful,
      'entryTomorrow': _entryTomorrow,
    };
  }

  String get entryHappy => _entryHappy;
  final String _entryHappy;

  String get entryProud => _entryProud;
  final String _entryProud;

  String get entryThankful => _entryThankful;
  final String _entryThankful;

  String get entryTomorrow => _entryTomorrow;
  final String _entryTomorrow;

  HappyHourStats copyWith({
    String? entryHappy,
    String? entryProud,
    String? entryThankful,
    String? entryTomorrow,
  }) {
    return HappyHourStats(
      entryHappy ?? _entryHappy,
      entryProud ?? _entryProud,
      entryThankful ?? _entryThankful,
      entryTomorrow ?? _entryTomorrow,
    );
  }

  @override
  String toString() {
    return 'HappyHourStats{entryHappy: "$_entryHappy", entryProud: "$_entryProud", entryThankful: "$_entryThankful", entryTomorrow: "$_entryTomorrow"}';
  }
}
