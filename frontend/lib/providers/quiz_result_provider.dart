import 'package:flutter/material.dart';
import 'package:releaf/main.dart';

class QuizResultsProvider with ChangeNotifier {
  QuizResultsProvider() {
    _loadResults();
  }
  List<num> _scores = [];

  List<num> get scores => _scores;

  static String _getPrefsScoreKey(int index) => 'quizScore_$index';

  void updateScoresNoNotify(
    List<num> Function(List<num> oldScores) setNewScores,
  ) {
    final newScores = setNewScores(_scores);
    _scores = newScores;
    _saveResults();
  }

  void updateScores(List<num> Function(List<num> oldScores) setNewScores) {
    updateScoresNoNotify(setNewScores);
    notifyListeners();
  }

  void _saveResults() {
    for (var i = 0; i < _scores.length; i++) {
      preferencesInstance.setDouble(
        _getPrefsScoreKey(i),
        _scores[i].toDouble(),
      );
    }
  }

  void _loadResults() {
    double? val;
    var i = 0;
    do {
      val = preferencesInstance.getDouble(_getPrefsScoreKey(i));
      i++;
      if (val != null) _scores.add(val);
    } while (val != null);
  }

  num get totalScore => _scores.fold<num>(0, (prev, el) => prev + el);
  num get maxScore => _scores.fold<num>(0, (prev, el) => el > prev ? el : prev);
  List<double> get relativeScore => List<double>.generate(
        _scores.length,
        (index) => _scores[index] / totalScore,
      );
}
