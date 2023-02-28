import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lab4/firestore.dart';
import 'package:lab4/pages/login_page.dart';
import 'package:table_calendar/table_calendar.dart';

import '../auth.dart';
import '../create_exam.dart';
import '../formatter/date_time_formatter.dart';
import '../main.dart';
import '../model/exam.dart';

class ExamPage extends StatefulWidget {
  ExamPage();

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {

  List<Exam> _exams = [];

  final _examStorage = ExamFirestore();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  @override
  initState() {
    super.initState();
    _loadExams();
  }

  _showUpcomingExamNotification(Exam exam,int days) {
    flutterLocalNotificationsPlugin.show(
        1,
        "You have an upcoming exam in ${days} days",
        "${exam.title}",
        NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id, channel.name, channelDescription: channel.description,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher'
            )
        )
    );
  }

  _loadExams() async {
    var exams = await _examStorage
        .readExams()
        .first;
    setState(() {
      _exams = exams;
    });
    var currentDate = DateTime.now();
    var upcomingExam = (_exams.map((e) =>  {'exam': e, 'days': _getDateDifference(currentDate, e.dateTime)})
        .where((examDays) => examDays['days'] as int > 0 && examDays['days'] as int < 4).toList()
      ..sort((a,b) => (a['exam'] as int).compareTo(b['days'] as int))).first;
    _showUpcomingExamNotification(upcomingExam['exam'] as Exam, upcomingExam['days'] as int);
  }

  int _getDateDifference(DateTime currentDate, DateTime otherDate) {
    return otherDate.difference(currentDate).inDays;
  }

  _hasExamOnDay(DateTime day) {
    return _exams.any((exam) => isSameDay(exam.dateTime, day));
  }

  _createExam(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            child: CreateExam(createCallback: _addExam),
          );
        });
  }

  _addExam(Exam exam) async {
    await _examStorage.createExamForUser(Auth().currentUser!, exam);
    setState(() {
      _exams.add(exam);
    });
  }

  _deleteExam(String id) async {
    await _examStorage.deleteExam(Auth().currentUser!, id);
    setState(() {
      _exams.removeWhere((exam) => exam.id == id);
    });
  }

  _logout() async {
    await Auth().signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginRegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Exam application'),
          actions: [
            IconButton(
                onPressed: () => _createExam(context), icon: Icon(Icons.add)),
            IconButton(onPressed: () => _logout(), icon: Icon(Icons.logout))
          ],
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: TableCalendar(
                headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    formatButtonTextStyle: const TextStyle(color: Colors.white),
                    formatButtonVisible: false),
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay =
                        focusedDay; // update `_focusedDay` here as well
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) {
                  if (_hasExamOnDay(day)) {
                    return [day];
                  }
                  return [];
                },
                calendarStyle: const CalendarStyle(
                    weekendTextStyle: TextStyle(color: Colors.red),
                    todayDecoration: BoxDecoration(
                        color: Colors.orange, shape: BoxShape.circle),
                    todayTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white),
                    markerDecoration: BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle)),
              ),
            ),
            StreamBuilder<List<Exam>>(
              stream: _examStorage.readExamsByDate(_selectedDay ?? _focusedDay),
              builder: (ctx, snapshot) {
                if (snapshot.hasData) {
                  List<Exam> filteredExams = snapshot.data!;
                  return filteredExams.isEmpty
                      ? const Text("No exams for selected date")
                      : Expanded(
                      child: ListView.builder(
                        itemCount: filteredExams.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 3,
                            child: ListTile(
                              title: Text(
                                "${filteredExams[index].title}",
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                DateTimeFormatter.formatter.format(
                                  filteredExams[index].dateTime,
                                ),
                                style: TextStyle(fontSize: 14),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    _deleteExam(filteredExams[index].id),
                              ),
                            ),
                          );
                        },
                      ));
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ));
  }
}
