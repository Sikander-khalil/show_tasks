import 'package:flutter/material.dart';

class Task {
  final String title;
  final String note;
  final String date;
  final String notifyTime;
  final Color color;

  Task({
    required this.title,
    required this.note,
    required this.date,
    required this.notifyTime,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'note': note,
      'date': date,
      'notifyTime': notifyTime,
      'color': color.value,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      note: map['note'],
      date: map['date'],
      notifyTime: map['notifyTime'],
      color: Color(map['color']),
    );
  }
}
