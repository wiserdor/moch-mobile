import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/moch_notification.dart';

class SharedPreferencesUtil {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  static Future<void> saveNotification(MochNotification notification) async {
    final SharedPreferences prefs = await _prefs;
    List<String>? notifications = prefs.getStringList('notifications') ?? [];
    notifications.add(jsonEncode({
      'message': notification.message,
      'timestamp': notification.timestamp.toIso8601String(),
    }));
    await prefs.setStringList('notifications', notifications);
  }

  static Future<List<MochNotification>> getNotifications() async {
    final SharedPreferences prefs = await _prefs;
    List<String>? encodedNotifications = prefs.getStringList('notifications');
    if (encodedNotifications == null) {
      return [];
    } else {
      return encodedNotifications
          .map((encodedNotification) {
            Map<String, dynamic> notificationData =
                jsonDecode(encodedNotification);
            return MochNotification(
              message: notificationData['message'],
              timestamp: DateTime.parse(notificationData['timestamp']),
              seen: notificationData['seen'] ?? false,
            );
          })
          .toList()
          .reversed
          .toList();
    }
  }

  static Future<void> markAllAsSeen() async {
    final SharedPreferences prefs = await _prefs;
    List<String>? encodedNotifications = prefs.getStringList('notifications');
    if (encodedNotifications != null) {
      var updatedNotifications =
          encodedNotifications.map((encodedNotification) {
        Map<String, dynamic> notificationData = jsonDecode(encodedNotification);
        notificationData['seen'] = true;
        return jsonEncode(notificationData);
      }).toList();
      await prefs.setStringList('notifications', updatedNotifications);
    }
  }

  static Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.containsKey('userId');
  }

  // get login data
  static Future<String?> get userId {
    return _prefs.then((SharedPreferences prefs) {
      return prefs.getString('userId');
    });
  }

  static Future<String?> get userPartnerId {
    return _prefs.then((SharedPreferences prefs) {
      return prefs.getString('userPartnerId');
    });
  }

  static Future<String?> get userPassword {
    return _prefs.then((SharedPreferences prefs) {
      return prefs.getString('userPassword');
    });
  }

  // clear shared preferences
  static Future<void> clear() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.clear();
  }

  static clearLoginData() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove('userId');
    await prefs.remove('userPartnerId');
    await prefs.remove('userPassword');
  }
}
