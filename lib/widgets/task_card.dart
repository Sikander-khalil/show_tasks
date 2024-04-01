import 'package:flutter/material.dart';

import '../constant/color.dart';
import '../model/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
          color: task.color,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(color: MyColors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      task.date, // Displaying the task date
                      style: const TextStyle(color: MyColors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      task.note,
                      style: const TextStyle(color: MyColors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      'Notification Time: ${task.notifyTime}',
                      style: const TextStyle(color: MyColors.white),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
