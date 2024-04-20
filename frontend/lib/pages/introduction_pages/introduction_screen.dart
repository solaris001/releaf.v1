import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:releaf/main.dart';
import 'package:releaf/models/app_colors.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({
    required this.mainPageController,
    super.key,
  });

  final PageController mainPageController;

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  int _currentPage = 0;
  int _selectedOption = 0;
  final int _pagesLength = 4;
  final PageController _pageController = PageController();
  late List<String> answers;

  @override
  void initState() {
    super.initState();
    answers = List.filled(_pagesLength - 2, '');
  }

  void _nextPage() {
    setState(() {
      if (_currentPage < _pagesLength - 1) {
        _currentPage++;
        _selectedOption = 0;
        _pageController.jumpToPage(_currentPage);
      }

      // If on last page
      else {
        preferencesInstance.setBool('intro_page_done', true);
        preferencesInstance.setStringList(
          'questionnaire_answers',
          answers,
        );
        Navigator.pushReplacementNamed(context, '/main');
      }
    });
  }

  void _previousPage() {
    setState(() {
      // If not on first page
      if (_currentPage > 0) {
        _currentPage--;
        _selectedOption = 0;
        _pageController.jumpToPage(_currentPage);
      }
    });
  }

  Widget _buildOptionGrid(List<String> optionNames) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: (MediaQuery.of(context).size.width / 2) /
          (MediaQuery.of(context).size.height / 20),
      children: List.generate(4, (index) {
        final i = index + 1;
        return Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: ListTile(
            title: Text(
              optionNames[index],
              style: const TextStyle(fontSize: 18),
            ),
            leading: Radio<int>(
              value: i,
              groupValue: _selectedOption,
              onChanged: (int? value) {
                if (value != null) {
                  setState(() {
                    _selectedOption = value;
                    answers[_currentPage - 1] = optionNames[index];
                  });
                }
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPageContent({
    required String heading,
    required String text,
    List<Widget>? options,
    String? buttonNameLeft,
    String? buttonNameRight,
  }) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Builder(
              builder: (context) {
                String assetName;
                Alignment alignment;
                double scale;

                if (_currentPage < _pagesLength - 1) {
                  assetName = 'assets/images/intro_screen_mascot.svg';
                  alignment = Alignment.bottomLeft;
                  scale = 0.9;
                } else {
                  assetName = 'assets/images/winking_mascot.svg';
                  alignment = Alignment.bottomCenter;
                  scale = 1;
                }

                return Transform.scale(
                  scale: scale,
                  alignment: alignment,
                  child: SvgPicture.asset(
                    assetName,
                    width: MediaQuery.of(context).size.width,
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 50, right: 20),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      '${_currentPage + 1}/$_pagesLength',
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                if (_currentPage + 1 == _pagesLength)
                  Align(
                    alignment: Alignment.topCenter,
                    child: SvgPicture.asset(
                      'assets/images/check.svg',
                      width: 90,
                    ),
                  ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    heading,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    text,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                if (options != null) ...options,
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0 && buttonNameLeft != null)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            side: const BorderSide(color: Colors.transparent),
                          ),
                          onPressed: _previousPage,
                          child: Row(
                            children: [
                              const Icon(Icons.arrow_back),
                              const SizedBox(width: 5),
                              Text(
                                buttonNameLeft,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 15),
                      if (_currentPage < _pagesLength &&
                          buttonNameRight != null)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            side: const BorderSide(color: Colors.transparent),
                          ),
                          onPressed: _nextPage,
                          child: Row(
                            children: [
                              Text(
                                buttonNameRight,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define introduction and questionnaire pages
    final pages = <Widget>[
      _buildPageContent(
        heading: "Hey there, I'm Kat, your Student Helper!",
        text: 'Together, we are going to improve your productivity and '
            'calm your mind, so you can finally focus on what really matters!',
        buttonNameRight: "Let's Start!",
      ),
      _buildPageContent(
        heading: 'First things first',
        text: 'Long text for question one, long text for question one. '
            'Long text for question one, long text for question one.',
        options: [
          _buildOptionGrid([
            'Option A',
            'Option B',
            'Option C',
            'Option D',
          ]),
        ],
        buttonNameLeft: 'Back',
        buttonNameRight: 'Next',
      ),
      _buildPageContent(
        heading: 'Second Question',
        text: 'Long text for question one, long text for question one. '
            'Long text for question one, long text for question one.',
        options: [
          _buildOptionGrid([
            'Option 1',
            'Option 2',
            'Option 3',
            'Option 4',
          ]),
        ],
        buttonNameLeft: 'Back',
        buttonNameRight: 'Done!',
      ),
      _buildPageContent(
        heading: "You're all set!",
        text: 'Thank you for filling out the Questionnaire!',
        buttonNameLeft: 'Back',
        buttonNameRight: "Let's go!",
      ),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: pages,
      ),
    );
  }
}
