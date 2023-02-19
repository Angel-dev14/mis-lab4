import 'package:date_field/date_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './formatter/date_time_formatter.dart';
import 'model/exam.dart';

class CreateExam extends StatefulWidget {
  final Function createCallback;

  CreateExam({required this.createCallback}) {}

  @override
  State<StatefulWidget> createState() => _CreateExamState();
}

class _CreateExamState extends State<CreateExam> {
  final _titleController = TextEditingController();

  DateTime? dateTime;

  void _create() {
    if (_titleController.text.isEmpty) {
      return;
    }
    if (dateTime == null) {
      return;
    }
    final String title = _titleController.text;
    Exam exam = Exam(title: title, dateTime: dateTime!);
    widget.createCallback(exam);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration:
                InputDecoration(labelText: "Title", icon: Icon(Icons.title)),
          ),
          DateTimeField(
            decoration: InputDecoration(
                labelText: "Date and Time", icon: Icon(Icons.date_range)),
            mode: DateTimeFieldPickerMode.dateAndTime,
            dateFormat: DateTimeFormatter.formatter,
            selectedDate: dateTime,
            onDateSelected: (DateTime value) {
              setState(() {
                dateTime = value;
              });
            },
          ),
          ElevatedButton(onPressed: _create, child: Text("Add"))
        ],
      ),
    );
  }
}
