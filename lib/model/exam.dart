import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lab4/formatter/date_time_formatter.dart';
import 'package:nanoid/nanoid.dart';

class Exam {
  String id;
  String title;
  DateTime dateTime;

  Exam({this.id = '', required this.title, required this.dateTime}) {
    if (id.isEmpty) {
      id = nanoid(6);
    }
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'dateTime': dateTime};

  static Exam fromJson(Map<String, dynamic> json) => Exam(
      id: json['id'],
      title: json['title'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(
          (json['dateTime'] as Timestamp).millisecondsSinceEpoch));
}
