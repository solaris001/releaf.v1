import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:releaf/models/app_colors.dart';
import 'package:releaf/models/theme_data.dart';
import 'package:releaf/pages/pages.dart';
import 'package:releaf/providers/quiz_result_provider.dart';
import 'package:releaf/providers/stats_provider.dart';
import 'package:releaf/providers/timer_provider.dart';
import 'package:releaf/providers/wiki_provider.dart';
import 'package:releaf/services/notify_service.dart';
import 'package:releaf/utilities/datetime_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

late final SharedPreferences preferencesInstance;

void main() async {
  // has to be initialized for SharedPreferences to be available
  WidgetsFlutterBinding.ensureInitialized();
  // initialize Key-Value store and read from disk
  preferencesInstance = await SharedPreferences.getInstance();

  notificationServiceInstance = NotificationService();
  await notificationServiceInstance.initNotification();

  //set timezone
  tz.initializeTimeZones();

  await initializeIntroPage();

  runApp(
    // Provides stateManagement with access from whole app e.g. via context.watch<WikiProvide>() with automatic rebuild
    MultiProvider(
      providers: [
        ChangeNotifierProvider<WikiProvider>(
          create: (_) => WikiProvider(),
        ),
        ChangeNotifierProvider<TimerProvider>(
          create: (_) => TimerProvider(),
        ),
        ChangeNotifierProvider<QuizResultsProvider>(
          create: (_) => QuizResultsProvider(),
        ),
        ChangeNotifierProvider<StatsProvider>(
          create: (_) => StatsProvider(),
        ),
      ],
      child: const Main(),
    ),
  );
}

Future<void> initializeIntroPage() async {
  await preferencesInstance.setBool('logged_in', false);

  final now = DateTime.now();
  final summerSemester = DateTime(now.year, 04);
  final winterSemester = DateTime(now.year, 10);
  final newSemester =
      now.month == summerSemester.month || now.month == winterSemester.month;

  final isIntroPageDone = preferencesInstance.getBool('intro_page_done');

  // If there is no key value pair in SharedPreferences,
  if (isIntroPageDone == null) {
    await preferencesInstance.setBool('intro_page_done', false);

    if (newSemester) {
      await preferencesInstance.setBool(
        'first_launch_on_new_semester_done',
        true,
      );
    } else {
      await preferencesInstance.setBool(
        'first_launch_on_new_semester_done',
        false,
      );
    }
  } else {
    final isFirstLaunchOnNewSemesterDone =
        preferencesInstance.getBool('first_launch_on_new_semester_done');

    if (newSemester && !isFirstLaunchOnNewSemesterDone!) {
      await preferencesInstance.setBool(
        'first_launch_on_new_semester_done',
        true,
      );
      await preferencesInstance.setBool('intro_page_done', false);
    } else if (!newSemester) {
      await preferencesInstance.setBool(
        'first_launch_on_new_semester_done',
        false,
      );
    }
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  ThemeMode appThemeMode = ThemeMode.light;

  void onThemeChanged(ThemeMode themeMode) {
    setState(() {
      appThemeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // * Themes
      // * DARK Theme
      darkTheme: AppTheme.dark,
      // * LIGHT Theme
      theme: AppTheme.light,
      // * Theme switch
      themeMode: appThemeMode,
      // * Hide "Debug" Banner  (debug mode only)
      debugShowCheckedModeBanner: false,
      // * Layout
      home: preferencesInstance.getBool('logged_in') ?? false
          ? MainPage(onThemeChanged: onThemeChanged)
          : LoginPage(mainPageController: PageController()),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(
              mainPageController: PageController(),
            ),
        '/register': (context) => const RegistrationPage(),
        '/password_recovery': (context) => const PasswordRecoveryPage(),
        '/introduction': (context) => IntroductionScreen(
              mainPageController: PageController(),
            ),
        '/main': (context) => MainPage(
              onThemeChanged: onThemeChanged,
            ),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({required this.onThemeChanged, super.key});

  final void Function(ThemeMode themeMode) onThemeChanged;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final int initialPage = 0;

  /// controls the scrolling/animation between the main pages
  late PageController mainPageController;

  late int selectedIndex;

  @override
  void initState() {
    super.initState();

    mainPageController = PageController(
      initialPage: initialPage,
    );

    selectedIndex = initialPage;
  }

  @override
  void dispose() {
    mainPageController.dispose();
    super.dispose();
  }

  /// updates the selected page index in the navbar
  ///
  /// called by the PageView Widget when swiped to another page
  void onPageSwiped(int pageIndex) {
    setState(() {
      selectedIndex = pageIndex;
    });
  }

  /// animates the PageView to the page tapped in the navbar
  ///
  /// called by the BottomNavigationBar Widget
  void onPageSelected(int pageIndex) {
    setState(() {
      selectedIndex = pageIndex;
      if (mainPageController.hasClients) {
        mainPageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutQuad,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();

    return SafeArea(
      child: Scaffold(
        appBar: statsAppBar(stats),
        body: PageView(
          controller: mainPageController,
          onPageChanged: onPageSwiped,
          children: pages(),
        ),
        bottomNavigationBar: roundedNavBar(),
      ),
    );
  }

  List<Widget> pages() {
    return [
      const HomePage(),
      const TimerPage(),
      const WikiPage(),
      const HappyHourPage(),
    ];
  }

  List<BottomNavigationBarItem> navigationBarItems() {
    return [
      BottomNavigationBarItem(
        icon: SvgPicture.asset('assets/images/map.svg'),
        label: 'Map',
        activeIcon: buildActiveNavbarIcon('assets/images/map.svg'),
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset('assets/images/timer.svg'),
        label: 'Timer',
        activeIcon: buildActiveNavbarIcon('assets/images/timer.svg'),
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset('assets/images/wiki.svg'),
        label: 'Wiki',
        activeIcon: buildActiveNavbarIcon('assets/images/wiki.svg'),
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset('assets/images/happyhour.svg'),
        label: 'Happy Hour',
        activeIcon: buildActiveNavbarIcon('assets/images/happyhour.svg'),
      ),
    ];
  }

  Widget buildActiveNavbarIcon(String iconPath) {
    return Stack(
      children: [
        SvgPicture.asset(
          iconPath,
          colorFilter: const ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }

  Widget roundedNavBar() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(95, 122, 122, 122),
            blurRadius: 30,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          items: navigationBarItems(),
          currentIndex: selectedIndex,
          onTap: onPageSelected,
        ),
      ),
    );
  }

  AppBar statsAppBar(StatsProvider stats) {
    return AppBar(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Add functionality here, Open happy hour page
            },
          ),
          Row(
            // Use a for loop to iterate through days
            children: [
              if (stats.perDayStats.length > 3)
                for (int index = 2; index >= 0; index--)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _buildDaySquare(index, stats),
                  ),
            ],
          ),
          const Spacer(),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.accentBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        4,
                        48 /* Space for the golden leaf*/,
                        4,
                      ),
                      child: Text(
                        stats.leafStreak.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/images/goldenleaf.svg',
                height: 48,
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => SettingsPage(
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          indent: 20,
          endIndent: 20,
          thickness: 0.3,
          height: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDaySquare(
    int index,
    StatsProvider stats,
  ) {
    final MapEntry(key: date, value: stat) =
        stats.perDayStats.entries.elementAt(index);

    final letter = DateFormat('EEEE').formatDate(date).substring(0, 1);
    final leafs = stat?.leafCount;

    var squareColor = AppColors.accentBackgroundColor;

    if (leafs == 1) {
      squareColor = AppColors.primary;
    } else if (leafs == 2) {
      squareColor = AppColors.primaryAccent;
    } else if (leafs == 3) {
      squareColor = AppColors.tertiary;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: squareColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
