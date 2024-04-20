import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:provider/provider.dart';
import 'package:releaf/models/quiz.dart';
import 'package:releaf/pages/wiki_entry_page.dart';
import 'package:releaf/providers/quiz_result_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// Note! The questionnaire is develope using a Large Language Model for a first
// running prototype. A final questionnaire, will be developed by psychologists
// using scientific methods.

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool loading = true;
  CategorizedPointQuiz? quiz;

  @override
  void initState() {
    super.initState();
    loadQuiz();
  }

  /// Asynchronously loads the questionnair from the asset file
  /// and updates the UI once loaded
  Future<void> loadQuiz() async {
    final jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/data/quiz.json');
    final dynamic json = jsonDecode(jsonString);
    if (json is! Map<String, dynamic>) return;
    quiz = CategorizedPointQuiz.fromJSON(json);
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Yourself!'),
      ),
      body: Builder(
        builder: (context) {
          if (loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (quiz == null) {
            return const Center(
              child: Text('Failed to load Quiz data'),
            );
          }
          return QuizWidget(quiz!);
        },
      ),
    );
  }
}

/// The widget that keeps track of and displays the answers and counts the points
/// towards the categories.
class QuizWidget extends StatefulWidget {
  const QuizWidget(this.quiz, {super.key});
  final CategorizedPointQuiz quiz;

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  int currentQuestionIndex = 0;
  List<bool> answered = [];
  bool showResults = false;

  @override
  void initState() {
    super.initState();
    final results = context.read<QuizResultsProvider>();
    if (results.scores.isEmpty || results.totalScore == 0) {
      resetQuiz();
    } else {
      showResults = true;
    }
    resetAnswered();
  }

  void resetQuiz() {
    final results = context.read<QuizResultsProvider>();
    // initialize scores if empty
    results.updateScoresNoNotify(
      (oldScores) => List<num>.filled(widget.quiz.categories.length, 0),
    );
    // keeps track of which questions already have been answered
    currentQuestionIndex = 0;
    showResults = false;
  }

  void resetAnswered() {
    answered = List.filled(widget.quiz.questions.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[currentQuestionIndex];

    if (!showResults) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: SfLinearGauge(
              maximum: widget.quiz.questions.length.toDouble(),
              showLabels: false,
              showTicks: false,
              animateAxis: true,
              animateRange: true,
              animationDuration: 250,
              barPointers: [
                LinearBarPointer(
                  value: currentQuestionIndex + 1,
                  thickness: 20,
                  edgeStyle: LinearEdgeStyle.bothCurve,
                ),
              ],
              axisTrackStyle: LinearAxisTrackStyle(
                color: Theme.of(context).colorScheme.surface,
                edgeStyle: LinearEdgeStyle.bothCurve,
                thickness: 20,
              ),
            ),
          ),
          Expanded(
            child:
                SingleChildScrollView(child: questionText(question, context)),
          ),
          answers(question),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: currentQuestionIndex == 0
                    ? null
                    : () {
                        setState(() {
                          currentQuestionIndex = (currentQuestionIndex - 1)
                              .clamp(0, widget.quiz.questions.length - 1);
                        });
                      },
                icon: const Icon(Icons.arrow_back),
              ),
              IconButton(
                onPressed: !answered[currentQuestionIndex]
                    ? null
                    : () {
                        setState(() {
                          currentQuestionIndex = (currentQuestionIndex + 1)
                              .clamp(0, widget.quiz.questions.length - 1);
                        });
                      },
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ],
      );
    }
    return resultsChart(context);
  }

  Widget answers(CategorizedPointQuizQuestion question) {
    final results = context.watch<QuizResultsProvider>();

    return ListView.builder(
      itemCount: question.answers.length,
      shrinkWrap: true,
      itemBuilder: (context, answerIndex) {
        // destructure the pattern into individual variables
        final (category: categoryIndex, text: answerText, points: points) =
            question.answers[answerIndex];
        return Padding(
          padding: const EdgeInsets.all(8),
          child: TextButton(
            onPressed: answered[currentQuestionIndex]
                ? null
                : () {
                    setState(() {
                      answered[currentQuestionIndex] = true;

                      // track score for answer category
                      results.updateScores((oldScores) {
                        oldScores[categoryIndex] += points;
                        return oldScores;
                      });

                      // go to next question
                      currentQuestionIndex++;

                      // show results after last question
                      if (currentQuestionIndex >=
                          widget.quiz.questions.length) {
                        currentQuestionIndex--;
                        showResults = true;
                      }
                    });
                  },
            child: Text(
              answerText,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget questionText(
    CategorizedPointQuizQuestion question,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        question.prompt,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  /// Holds the UUIDs of the wiki entries related to the learning types which are linked to below the [resultsChart]
  List<String> learnTypeWikiUUIDs = [
    '026737e7-bb84-4f61-a8c2-4b63de6d65ce',
    '3a851d11-43bf-4025-85f4-6323bf9bc858',
    'a7e9d6cf-dc2d-45f5-ad40-670a1397fa6a',
    '1361fd13-9d9d-45be-87f7-27279cdaa72b',
  ];

  /// builds the radar chart based on the current [score] and calculates the relative scores between categories
  Widget resultsChart(BuildContext context) {
    final results = context.watch<QuizResultsProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: RadarChart(
              ticks: List<int>.generate(
                4,
                (index) => (results.maxScore ~/ 2) * index,
              ),
              // display the category names around the chart
              features: widget.quiz.categories,
              data: [results.scores],
              sides: 4,
              axisColor: Theme.of(context).colorScheme.secondary,
              outlineColor: Theme.of(context).colorScheme.secondary,
              featuresTextStyle: Theme.of(context).textTheme.bodyLarge!,
              graphColors: [Theme.of(context).colorScheme.primary],
            ),
          ),
        ),
        // display the relative score for each category
        // [score] and [widget.quiz.categories] should have the same length
        ...List<Widget>.generate(
          results.scores.length,
          (index) => Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: TextButton(
                    onPressed: () {
                      // open the wiki page with the corresponding wiki entry
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => WikiEntryPage(
                            entryUUID: learnTypeWikiUUIDs[index],
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "${widget.quiz.categories[index].replaceAll("\n", "")}: ",
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    '${(results.relativeScore[index] * 100).toStringAsFixed(2)} %',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            resetQuiz();
            resetAnswered();
            setState(() {});
          },
          child: const Text('Reset Test'),
        ),
      ],
    );
  }
}
