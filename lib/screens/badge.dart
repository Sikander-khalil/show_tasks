import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/color.dart';

class NotificationBadgeScreen extends StatelessWidget {
  const NotificationBadgeScreen({
    Key? key,
    this.payload,
  }) : super(key: key);
  final String? payload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Notfication"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (payload != null)
                _buildNotifiedReminderCard(context, [payload!])
              else
                Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    "No notfication yet!",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifiedReminderCard(
      BuildContext context, List<String> payloads) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: payloads.length,
      itemBuilder: (context, index) {
        final data = jsonDecode(payloads[index]);
        final title = data["title"];
        final body = data["body"];
        final formatDate = data["formatDate"];

        _saveNotificationToSharedPreferences(title, body, formatDate);

        return Card(
          color: MyColors.indigo,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(
                  Icons.alarm,
                  size: 60.0,
                  color: MyColors.white,
                ),
                SizedBox(height: 12.0),
                Text(
                  "Your reminder for",
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500,
                    color: MyColors.white,
                  ),
                ),
                SizedBox(height: 12.0),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.w500,
                    color: MyColors.white,
                  ),
                ),
                SizedBox(height: 12.0),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                    color: MyColors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time),
                    SizedBox(width: 8.0),
                    Text(
                      formatDate,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: MyColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveNotificationToSharedPreferences(
      String title, String body, String formatDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? notifications = prefs.getStringList('notifications') ?? [];

    notifications.add(jsonEncode({
      "title": title,
      "body": body,
      "formatDate": formatDate,
    }));

    prefs.setStringList('notifications', notifications);
  }
}
