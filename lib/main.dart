import 'package:flutter/material.dart';
import 'package:moch_mobile/lottery_checker.dart';
import 'package:moch_mobile/profile_page.dart';
import 'package:moch_mobile/shared_preferences_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'lottery_page.dart';
import 'models/moch_notification.dart';
import 'notifications_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // var item = {
  //   "id": 1,
  //   "city": "ירושלים",
  //   "order": 2,
  //   "resident_order": 2,
  //   "lottery_date": "2021-10-01T00:00:00"
  // };
  // var lastItem = {
  //   "id": 1,
  //   "city": "ירושלים",
  //   "order": 1,
  //   "resident_order": 1,
  //   "lottery_date": "2021-10-01T00:00:00"
  // };
  // // await SharedPreferencesUtil.clear();
  // var notificationMessage =
  //     "התקדמתם במיקום עבור הגרלה מספר ${item["id"]}\nבעיר ${item["city"]} שנערכה בתאריך ${item["lottery_date"].toString().split("T")[0].split('-').reversed.join('-')}\n";
  // notificationMessage +=
  //     'מיקום בתור תושב העיר ${lastItem["resident_order"]} ל ${item["resident_order"]}.\n';

  // if (lastItem['resident_order'] != item['resident_order']) {
  //   notificationMessage +=
  //       'מיקום בתור תושב העיר ${lastItem["resident_order"]} ל ${item["resident_order"]}.';
  // }

  // await SharedPreferencesUtil.saveNotification(MochNotification(
  //   message: notificationMessage,
  //   timestamp: DateTime.now(),
  // ));

  var isLoggedIn = await SharedPreferencesUtil.isLoggedIn();

  if (isLoggedIn) {
    var lotteryChecker = LotteryChecker();
    await lotteryChecker.checkLottery();
  }
  runApp(MaterialApp(home: isLoggedIn ? const MyApp() : const LoginPage()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'מחיר למשתכן',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
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

    // Add the observer.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove the observer
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    // These are the callbacks
    switch (state) {
      case AppLifecycleState.resumed:
        var isLoggedIn = await SharedPreferencesUtil.isLoggedIn();
        if (isLoggedIn) {
          // alert dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('מעדכן...'), duration: Duration(seconds: 1)),
          );

          await lotteryChecker.checkLottery();
        }
        break;
      case AppLifecycleState.inactive:
        // widget is inactive
        break;
      case AppLifecycleState.paused:
        // widget is paused
        break;
      case AppLifecycleState.detached:
        // widget is detached
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'ההגרלות שלי',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'התראות',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'פרופיל',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // if you don't want the user to swipe between pages
        children: const <Widget>[
          LotteryPage(),
          NotificationsPage(),
          ProfilePage(),
        ],
      ),
    );
  }
}
