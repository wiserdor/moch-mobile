import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/moch_notification.dart';
import 'shared_preferences_util.dart';

class LotteryChecker {
  final loginUrl = 'https://www.dira.moch.gov.il/api/users/Login';

  var loginData = <String, dynamic>{};
  var history = <String, dynamic>{};

  Future<void> main() async {
    history = await loadHistory();
  }

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

  Future<void> saveHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('history', json.encode(history));
  }

  Future<bool> checkLottery(
      {String? userId, String? userPassword, String? userPartnerId}) async {
    var loginData;
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

    var session = http.Client();

    try {
      var response = await session.post(Uri.parse(loginUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(loginData));

      if (response.statusCode == 200) {
        var sessionId = response.headers['sessionid'];
        var cookie = response.headers['set-cookie'];

        if (sessionId == null || cookie == null) {
          print('Login failed, session id or cookie is null');
          return false;
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
              var lastItem = history[item['id']].last;
              if (lastItem['order'] != item['order'] ||
                  lastItem['resident_order'] != item['resident_order']) {
                print('Order changed for lottery id ${item['id']}.');
                print('Previous data: $lastItem');
                print('Current data: $item');
                history[item['id']].add(historyItem);
                await SharedPreferencesUtil.saveNotification(MochNotification(
                  message:
                      'התקדמתם במיקום עבור הגרלה מספר ${item["id"]}\nבעיר ${item["city"]} שנערכה בתאריך ${item["lottery_date"].toString().split("T")[0].split('-').reversed.join('-')}\nממיקום ${lastItem["order"]} ל ${item["order"]}.\nמיקום בתור תושב העיר ${lastItem["resident_order"]} ל ${item["resident_order"]}.',
                  timestamp: DateTime.now(),
                ));
              }
            }
          }

          await saveHistory();
        } else {
          print('Failed to get data, status code: ${response.statusCode}');
          return false;
        }
      } else {
        print('Login failed, status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      session.close();
    }
    return true;
  }
}
