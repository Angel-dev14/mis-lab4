import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab4/formatter/date_time_formatter.dart';

import 'auth.dart';
import 'model/exam.dart';

class ExamFirestore {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> createExamForUser(User user, Exam exam) async {
    CollectionReference userExamCollection =
        _usersCollection.doc(user.uid).collection('exams');
    final json = exam.toJson();
    await userExamCollection.doc(exam.id).set(json);
  }

  Future<void> deleteExam(User user, String examId) async {
    await _usersCollection
        .doc(user.uid)
        .collection('exams')
        .doc(examId)
        .delete();
  }

  Stream<List<Exam>> readExams() {
    User user = Auth().currentUser!;
    return _usersCollection
        .doc(user.uid)
        .collection('exams')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Exam.fromJson(doc.data())).toList());
  }

  Stream<List<Exam>> readExamsByDate(DateTime selectedDate) {
    User user = Auth().currentUser!;
    DateTime dateStart =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    DateTime dateEnd = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59);
    print(dateEnd);
    return _usersCollection
        .doc(user.uid)
        .collection('exams')
        .where('dateTime',
            isGreaterThanOrEqualTo: dateStart, isLessThanOrEqualTo: dateEnd)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Exam.fromJson(doc.data())).toList());
  }
}
