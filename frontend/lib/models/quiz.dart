/// Holds the date for a Quiz that counts points towards certain categories
///
/// questions are stored in [questions]
///
/// the categories that are referenced via index in each question are stored in [categories]
///
/// Construct such a quiz using the static [fromJSON] method
class CategorizedPointQuiz {
  CategorizedPointQuiz(this._questions, this._categories);
  late final List<CategorizedPointQuizQuestion> _questions;
  late final List<String> _categories;

  List<CategorizedPointQuizQuestion> get questions => _questions;
  List<String> get categories => _categories;

  /// parses json from a Map to an instance of [CategorizedPointQuiz]
  ///
  /// [json] should contain a list of categories in the "categories" field and
  /// a list of questions in the "questions" field
  static CategorizedPointQuiz fromJSON(Map<String, dynamic> json) {
    final categories = <String>[];
    if (json case {'categories': final List<dynamic> cats}) {
      for (final dynamic element in cats) {
        if (element is String) {
          categories.add(element);
        }
      }
    }
    final questions = <CategorizedPointQuizQuestion>[];
    if (json case {'questions': final List<dynamic> quests}) {
      for (final dynamic element in quests) {
        if (element is Map<String, dynamic>) {
          final question = CategorizedPointQuizQuestion.fromJSON(element);
          if (question != null) questions.add(question);
        }
      }
    }
    return CategorizedPointQuiz(questions, categories);
  }
}

/// Holds a single question for a [CategorizedPointQuiz]
///
/// A question consists of a [prompt] and the possible [answers], each of which
/// have an answer [text], a corresponding [category] and an amount of [points]
/// that should be counted towards the associated category.
class CategorizedPointQuizQuestion {
  CategorizedPointQuizQuestion(
    String prompt, {
    List<({String text, int category, num points})>? answers,
  }) {
    _prompt = prompt;
    _answers = answers ?? [];
  }
  late String _prompt;
  late List<({String text, int category, num points})> _answers;

  String get prompt => _prompt;

  List<({String text, int category, num points})> get answers => _answers;

  static CategorizedPointQuizQuestion? fromJSON(Map<String, dynamic> json) {
    if (json
        case {
          'prompt': final String prompt,
          'answers': final List<dynamic> ans
        }) {
      final answers = <({String text, int category, num points})>[];
      for (final dynamic answer in ans) {
        if (answer
            case {
              'text': final String text,
              'category': final int category,
              'points': final num points
            }) {
          answers.add((text: text, category: category, points: points));
        }
      }
      return CategorizedPointQuizQuestion(prompt, answers: answers);
    }
    return null;
  }
}
