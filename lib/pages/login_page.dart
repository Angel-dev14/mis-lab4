import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lab4/firestore.dart';
import 'package:lab4/pages/exam_page.dart';

import '../auth.dart';

class LoginRegisterPage extends StatefulWidget {
  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool registerClicked = false;
  String errorMessage = "";

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;
      await Auth().signInWithEmailAndPassword(email: email, password: password);
      setState(() {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ExamPage()));
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message!;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;
      await Auth()
          .createUserWithEmailAndPassword(email: email, password: password);
      setState(() {
        registerClicked = false;
        _emailController.text = '';
        _passwordController.text = '';
      });
      await Fluttertoast.showToast(
          msg: "Registered successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.greenAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message!;
      });
    }
  }

  Widget _createTextField(
      String title, TextEditingController controller, bool obscure) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: title),
      obscureText: obscure,
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
        onPressed: () => registerClicked
            ? createUserWithEmailAndPassword()
            : signInWithEmailAndPassword(),
        child: registerClicked ? Text("Register") : Text("Login"));
  }

  Widget _errorMessage() {
    return Text(errorMessage, style: TextStyle(color: Colors.red));
  }

  _toggle() {
    setState(() => {registerClicked = !registerClicked, errorMessage = ""});
  }

  Widget _loginOrRegisterText() {
    return TextButton(
      child: registerClicked
          ? Text("Aready have an account? Login instead")
          : Text("Don't have an account?"),
      onPressed: () => _toggle(),
      style: ButtonStyle(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _createTextField("Email", _emailController, false),
              _createTextField("Password", _passwordController, true),
              _submitButton(),
              _loginOrRegisterText(),
              _errorMessage()
            ],
          ),
        ),
      ),
    );
  }
}
