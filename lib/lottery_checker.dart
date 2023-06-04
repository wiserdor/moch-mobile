import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mutex/mutex.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/moch_notification.dart';
import 'shared_preferences_util.dart';

enum LoginStatusType {
  loginSuccess,
  loginFailed,
  getDataFailed,
}

class LotteryChecker {
  final loginUrl = 'https://www.dira.moch.gov.il/api/users/Login';
  final locker = Mutex();

  var loginData = <String, dynamic>{};

  Future<Map<String, dynamic>> getLoginData() async {
    var idNumber = await SharedPreferencesUtil.userId;
    var password = await SharedPreferencesUtil.userPassword;

    loginData = {
      'identity': idNumber,
      'password': password,
    };

    return loginData;
  }

  // get dataUrl
  Future<String> getDataUrl({String? userId, String? userPartnerId}) async {
    var idNumber = userId ?? await SharedPreferencesUtil.userId;
    var partnerIdNumber =
        userPartnerId ?? await SharedPreferencesUtil.userPartnerId;
    if (partnerIdNumber == null || partnerIdNumber.isEmpty) {
      partnerIdNumber = idNumber;
    }

    return 'https://www.dira.moch.gov.il/api/InvokerAuth?method=LotteryResult%2FMyLotteryListQuery&param=%3FFirstApplicantIdentityNumber%3D$idNumber%26SecondApplicantIdentityNumber%3D$partnerIdNumber%26LoginId%3D$idNumber%26';
  }

  Future<Map<String, dynamic>> loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString('history') ?? '{}');
  }

  Future<void> saveHistory(Map<String, dynamic> history) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('history', json.encode(history));
  }

  Future<LoginStatusType> checkLottery(
      {String? userId, String? userPassword, String? userPartnerId}) async {
    Map<String, dynamic> loginData;
    if (userId == null || userPassword == null) {
      loginData = await getLoginData();
    } else {
      loginData = {
        'identity': userId,
        'password': userPassword,
      };
    }
    var dataUrl =
        await getDataUrl(userPartnerId: userPartnerId, userId: userId);
    var history = await loadHistory();

    var session = http.Client();

    try {
      locker.acquire();
      var response = await session.post(Uri.parse(loginUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(loginData));

      if (response.statusCode == 200) {
        var actionStatus = json.decode(response.body)['ActionStatus'];
        if (actionStatus != 1) {
          return LoginStatusType.loginFailed;
        }

        var sessionId = response.headers['sessionid'];
        var cookie = response.headers['set-cookie'];

        if (sessionId == null || cookie == null) {
          return LoginStatusType.loginFailed;
        }

        response = await session.get(Uri.parse(dataUrl), headers: {
          'Authorization': 'Basic $sessionId',
          'Cookie': cookie,
        });

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          var myLotteryList = data['MyLotteryList'].map((d) => {
                'id': d['LotteryNumber'],
                'city': d['CityDescription'],
                'order': d['ApartmentSelectOrder'],
                'resident_order': d['ApartmentSelectOrderLocal'],
                'total_apartments': d['LotteryApartmentsCount'],
                'lottery_date': d['LotteryDate'],
              });

          var timestamp = DateTime.now().millisecondsSinceEpoch;

          for (var item in myLotteryList) {
            var historyItem = {
              'timestamp': timestamp,
              'order': item['order'],
              'resident_order': item['resident_order'],
              'city': item['city'],
              'total_apartments': item['total_apartments'],
              'lottery_date': item['lottery_date'],
              'id': item['id'],
            };

            if (!history.containsKey(item['id'])) {
              history[item['id']] = [historyItem];
            } else {
              var lastItem = history[item['id']]!.last;
              if (lastItem['order'] != item['order'] ||
                  lastItem['resident_order'] != item['resident_order']) {
                history[item['id']]!.add(historyItem);

                try {
                  var notificationMessage =
                      "התקדמתם במיקום עבור הגרלה מספר ${item["id"]}\nבעיר ${item["city"]} שנערכה בתאריך ${item["lottery_date"].toString().split("T")[0].split('-').reversed.join('-')}\n";
                  notificationMessage +=
                      'ממקום ${lastItem['order']} למקום ${item['order']}\n';

                  if (lastItem['resident_order'] != item['resident_order'] &&
                      item['resident_order'] > 0) {
                    notificationMessage +=
                        'מיקום בתור תושב העיר ${lastItem["resident_order"]} ל ${item["resident_order"]}.';
                  }
                  await SharedPreferencesUtil.saveNotification(MochNotification(
                    message: notificationMessage,
                    timestamp: DateTime.now(),
                  ));
                } catch (e) {
                  print(e);
                }
              }
            }
          }

          await saveHistory(history);
        } else {
          print('Failed to get data, status code: ${response.statusCode}');
          return LoginStatusType.getDataFailed;
        }
      } else {
        print('Login failed, status code: ${response.statusCode}');
        return LoginStatusType.loginFailed;
      }
    } catch (e) {
      return LoginStatusType.getDataFailed;
    } finally {
      locker.release();
      session.close();
    }
    return LoginStatusType.loginSuccess;
  }
}
