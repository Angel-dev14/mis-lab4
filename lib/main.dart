import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lab4/pages/login_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  // description
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application name
      title: 'Exam Application',
      // Application theme data, you can set the colors for the application as
      // you want
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // A widget which will be started on application startup
      home: ExamApplication(),
    );
  }
}

class ExamApplication extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExamApplicationState();
}

class _ExamApplicationState extends State<ExamApplication> {
  @override
  Widget build(BuildContext context) {
    return LoginRegisterPage();
    //   StreamBuilder(
    //   stream: Auth().authStateChanges,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       return ExamPage();
    //     }
    //     else {
    //       return LoginRegisterPage();
    //     }
    //   },
    // );
  }
}