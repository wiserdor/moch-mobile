import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:moch_mobile/models/moch_notification.dart';

import 'shared_preferences_util.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<MochNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = SharedPreferencesUtil.getNotifications();
  }

  @override
  void dispose() {
    SharedPreferencesUtil.markAllAsSeen();
    super.dispose();
  }

  String _formatTimestamp(DateTime timestamp) {
    return intl.DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<List<MochNotification>>(
        future: _notificationsFuture,
        builder: (BuildContext context,
            AsyncSnapshot<List<MochNotification>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'אין התראות חדשות.',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 18,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        snapshot.data![index].message,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF333333),
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _formatTimestamp(snapshot.data![index].timestamp),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      trailing: snapshot.data![index].seen
                          ? null
                          : const Icon(
                              Icons.circle,
                              color: Color(0xFF4CAF50),
                              size: 12,
                            ),
                    ),
                  );
                },
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 16,
                ),
                textDirection: TextDirection.rtl,
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            );
          }
        },
      ),
    );
  }
}
