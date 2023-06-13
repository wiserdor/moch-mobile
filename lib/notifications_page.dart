import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MochNotification>>(
      future: SharedPreferencesUtil.getNotifications(),
      builder: (BuildContext context,
          AsyncSnapshot<List<MochNotification>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            // If there are no notifications, show a message.
            return const Center(
              child: Text('.אין התראות חדשות'),
            );
          } else {
            // If there are notifications, build a list.
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Directionality(
                    textDirection: TextDirection.rtl,
                    child: ListTile(
                      title: Text(
                        snapshot.data![index].message,
                      ),
                      subtitle: Text(
                          '${snapshot.data![index].timestamp.toString().substring(10, 16)} ${snapshot.data![index].timestamp.toString().substring(0, 10).split('-').reversed.join('-')}'),
                      trailing: snapshot.data![index].seen
                          ? null
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                      minVerticalPadding: 20,
                      shape:
                          const Border(bottom: BorderSide(color: Colors.grey)),
                    ));
              },
            );
          }
        } else if (snapshot.hasError) {
          // If there's an error, show the error message.
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          // While waiting for the future to complete, show a loading spinner.
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
