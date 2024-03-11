import 'package:flutter/material.dart';
import 'package:moch_mobile/lottery_checker.dart';
import 'package:moch_mobile/profile_page.dart';
import 'package:moch_mobile/shared_preferences_util.dart';

import 'login_page.dart';
import 'lottery_page.dart';
import 'notifications_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var isLoggedIn = await SharedPreferencesUtil.isLoggedIn();
  runApp(MaterialApp(home: isLoggedIn ? const MyApp() : const LoginPage()));

  if (isLoggedIn) {
    var lotteryChecker = LotteryChecker();
    await lotteryChecker.checkLottery();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'מחיר למשתכן',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Color(0xFF333333)),
          titleTextStyle: TextStyle(
            color: Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF333333)),
          bodyMedium: TextStyle(color: Color(0xFF666666)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFF60F9F),
          unselectedItemColor: Color(0xFF666666),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  var lotteryChecker = LotteryChecker();
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _updateLotteryData() async {
    var lotteryChecker = LotteryChecker();
    await lotteryChecker.checkLottery();

    // Load the updated lottery history
    var history = await lotteryChecker.loadHistory();

    // Update the UI with the latest lottery data
    setState(() {
      // Update the relevant UI widgets with the loaded history
      // For example:
      // _lotteryHistory = history;
      // _lotteryDataList = history.values.toList();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      var isLoggedIn = await SharedPreferencesUtil.isLoggedIn();
      if (isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('מעדכן...'),
            duration: Duration(seconds: 1),
          ),
        );
        _updateLotteryData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const <Widget>[
          LotteryPage(),
          NotificationsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.list),
              color: _selectedIndex == 0
                  ? const Color(0xFF99C2A2)
                  : const Color(0xFF666666),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              color: _selectedIndex == 1
                  ? const Color(0xFF99C2A2)
                  : const Color(0xFF666666),
              onPressed: () => _onItemTapped(1),
            ),
            IconButton(
              icon: const Icon(Icons.person),
              color: _selectedIndex == 2
                  ? const Color(0xFF99C2A2)
                  : const Color(0xFF666666),
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }
}
