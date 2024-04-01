import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constant/color.dart';
import '../helper/db.dart';
import '../model/task.dart';
import '../widgets/task_card.dart';
import 'add_task.dart';
import 'badge.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<List<Task>> _tasksFuture = Future.value([]);
  DatabaseHelper dbHelper = DatabaseHelper();
  DateTime selectDate = DateTime.now();
  int currentDateSelectedIndex = 0;
  ScrollController scrollController = ScrollController();
  List<String> listOfMonths = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  List<String> listOfDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  void initState() {
    super.initState();
    _showTask();
    _initializeNotifications();
  }

  Future<void> _showTask() async {
    setState(() {
      _tasksFuture = _fetchTasks(selectDate);
    });
  }

  Future<List<Task>> _fetchTasks(DateTime selectedDate) async {
    return dbHelper.getTasks(selectedDate);
  }

  void _initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    var initSetttings =
        InitializationSettings(android: initializationSettingsAndroid);
    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(initSetttings,
        onDidReceiveNotificationResponse: (NotificationResponse? response) {
      if (response != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                NotificationBadgeScreen(payload: response.payload),
          ),
        );
      }
    });

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null) {
      String? payload =
          notificationAppLaunchDetails.notificationResponse?.payload;
      print("This is Payload: ${payload}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${selectDate.day}-${listOfMonths[selectDate.month - 1]}, ${selectDate.year}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: MyColors.black,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTaskScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 120),
                      decoration: BoxDecoration(
                        color: MyColors.indigo,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "+ Add Task",
                          style: TextStyle(color: MyColors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 100,
                child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(width: 10);
                  },
                  itemCount: 365,
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          currentDateSelectedIndex = index;
                          selectDate =
                              DateTime.now().add(Duration(days: index));
                          _showTask();
                        });
                      },
                      child: Container(
                        height: 80,
                        width: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: MyColors.white,
                              offset: Offset(3, 3),
                              blurRadius: 5,
                            ),
                          ],
                          color: currentDateSelectedIndex == index
                              ? MyColors.indigo
                              : MyColors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              listOfMonths[DateTime.now()
                                      .add(Duration(days: index))
                                      .month -
                                  1],
                              style: TextStyle(
                                fontSize: 16,
                                color: currentDateSelectedIndex == index
                                    ? MyColors.white
                                    : MyColors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              DateTime.now()
                                  .add(Duration(days: index))
                                  .day
                                  .toString(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: currentDateSelectedIndex == index
                                    ? MyColors.white
                                    : MyColors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              listOfDays[DateTime.now()
                                      .add(Duration(days: index))
                                      .weekday -
                                  1],
                              style: TextStyle(
                                fontSize: 16,
                                color: currentDateSelectedIndex == index
                                    ? MyColors.white
                                    : MyColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: _tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final tasks = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return TaskCard(task: tasks[index]);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
