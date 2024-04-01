import 'dart:convert';

import 'package:date_todo/screens/home_screen.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../constant/color.dart';
import '../helper/db.dart';
import '../model/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  DateTime? _selectedDate;
  DatabaseHelper dbHelper = DatabaseHelper();
  bool isChecked = true;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? _notifyHour, notifyMinute, notifyTime;

  TimeOfDay notificationTime = TimeOfDay(hour: 00, minute: 00);
  DateTime dateTime = DateTime.now();

  Color selectedColor = MyColors.red;
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  TextEditingController dateController = TextEditingController();

  TextEditingController notifyTimeController = TextEditingController();

  Future<Null> _notifySelectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: notificationTime,
    );
    if (picked != null) {
      setState(() {
        notificationTime = picked;
        _notifyHour = notificationTime.hour.toString();
        notifyMinute = notificationTime.minute.toString();
        notifyTime = '${_notifyHour!} : ${notifyMinute!}';
        notifyTimeController.text = notifyTime!;
        notifyTimeController.text = DateFormat('hh : mm a').format(DateTime(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            notificationTime.hour,
            notificationTime.minute));
      });
    }
  }

  Future<void> _scheduleNotification(String? payload) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    DateTime endTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      notificationTime.hour,
      notificationTime.minute,
    );

    tz.TZDateTime scheduledEndTime = tz.TZDateTime.from(endTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      titleController.text,
      noteController.text,
      scheduledEndTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationTime = TimeOfDay.fromDateTime(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "Add Task",
            style: TextStyle(
                color: MyColors.indigo,
                fontWeight: FontWeight.bold,
                fontSize: 23),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListTile(
                    title: Text(
                      "Title",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    subtitle: TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                          hintText: 'Enter Title',
                          border: OutlineInputBorder()),
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 20.0),
                  child: ListTile(
                    title: Text(
                      "Note",
                      style: TextStyle(
                          color: MyColors.black, fontWeight: FontWeight.bold),
                    ),
                    subtitle: TextFormField(
                      controller: noteController,
                      decoration: InputDecoration(
                          hintText: 'Enter Note', border: OutlineInputBorder()),
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 20.0),
                  child: ListTile(
                    title: Text(
                      "Date",
                      style: TextStyle(
                          color: MyColors.black, fontWeight: FontWeight.bold),
                    ),
                    subtitle: TextFormField(
                      controller: dateController,
                      decoration: InputDecoration(
                          suffixIcon: InkWell(
                              onTap: () {
                                _selectDate(context);
                              },
                              child: Icon(Icons.calendar_today)),
                          hintText: 'Enter Date',
                          border: OutlineInputBorder()),
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 20.0),
                  child: ListTile(
                    title: Text(
                      "Notfication Time",
                      style: TextStyle(
                          color: MyColors.black, fontWeight: FontWeight.bold),
                    ),
                    subtitle: TextFormField(
                      controller: notifyTimeController, // add this line.
                      decoration: InputDecoration(
                          hintText: 'Enter Notification Time',
                          border: OutlineInputBorder(),
                          suffixIcon: InkWell(
                            onTap: () async {
                              _notifySelectTime(context);
                            },
                            child: Icon(Icons.alarm_rounded),
                          )),

                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'cant be empty';
                        }
                        return null;
                      },
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 20.0),
                child: ListTile(
                  title: Text(
                    "Color",
                    style: TextStyle(
                        color: MyColors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        colorContainer(MyColors.red),
                        colorContainer(MyColors.indigo),
                        colorContainer(MyColors.amber),
                        colorContainer(MyColors.black),
                      ],
                    ),
                  ),
                ),
              ),
              MaterialButton(
                  color: MyColors.indigo,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () async {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(_selectedDate!);
                    Task newTask = Task(
                      title: titleController.text,
                      note: noteController.text,
                      date: formattedDate,
                      color: selectedColor,
                      notifyTime: notifyTimeController.text,
                    );

                    await dbHelper.insertTask(newTask);

                    await _scheduleNotification(
                      jsonEncode({
                        "title": titleController.text,
                        "body": noteController.text,
                        "formatDate": formattedDate,
                      }),
                    );

                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    });
                  },
                  child: Text(
                    "Create Task",
                    style: TextStyle(color: MyColors.white),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget colorContainer(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100),
        ),
        child: isChecked && selectedColor == color
            ? Icon(
                Icons.check,
                color: MyColors.white,
              )
            : null,
      ),
    );
  }

  _selectDate(BuildContext context) async {
    Intl.defaultLocale = 'en_US';

    DateTime? nowSelectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      initialDate: _selectedDate != null ? _selectedDate! : DateTime.now(),
      lastDate: DateTime(2040),
      builder: (BuildContext context, Widget? child) {
        return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: MyColors.indigo,
                onPrimary: MyColors.white,
                surface: MyColors.black,
                onSurface: MyColors.white,
              ),
              dialogBackgroundColor: MyColors.indigo,
            ),
            child: child ?? Container());
      },
    );

    if (nowSelectedDate != null) {
      setState(() {
        _selectedDate = nowSelectedDate;

        String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
        dateController
          ..text = formattedDate
          ..selection = TextSelection.fromPosition(TextPosition(
              offset: dateController.text.length,
              affinity: TextAffinity.upstream));
      });
    }
  }
}
