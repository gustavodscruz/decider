import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decider/extensions/string_extension.dart';
import 'package:decider/models/Questions.dart';
import 'package:decider/services/auth_service.dart';
import 'package:decider/views/history_view.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _questionController = TextEditingController();
  String _answer = "";
  bool _askBtnActive = false;
  final Question _question = Question();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //mudança de foco na aplicação, aplicar para outros projetos!
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('Decider'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {},
                child: const Icon(Icons.shopping_bag),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HistoryView()));
                },
                child: const Icon(Icons.history),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Decisions Left: ##"),
                ),
                const Spacer(),
                _buildQuestionsForm(),
                const Spacer(
                  flex: 3,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Account Type: Free"),
                ),
                Text("${AuthService().currentUser?.uid}")
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsForm() {
    return Column(
      children: <Widget>[
        Text(
          "Should I...",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
          child: TextField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                helperText: "Enter a question"),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            controller: _questionController,
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              setState(() {
                _askBtnActive = value.length >= 3 ? true : false;
              });
            },
          ),
        ),
        ElevatedButton(
            onPressed: _askBtnActive == true ? _answerQuestion : null,
            child: const Text("Ask")),
        _questionAndAnswer()
      ],
    );
  }

  String _getAnswer() {
    var answerOptions = ['Yes', 'No', 'Definitily', 'not right now'];
    return answerOptions[Random().nextInt(answerOptions.length)];
  }

  Widget _questionAndAnswer() {
    if (_answer != "") {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text("Should I ${_questionController.text}?"),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              "Answer: ${_answer.capitalize()}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  void _answerQuestion() async {
    setState(() {
      _answer = _getAnswer();
    });
    _question.query = _questionController.text;
    _question.answer = _answer;
    _question.created = DateTime.now();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(AuthService().currentUser?.uid)
        .collection('questions')
        .add(_question.toJson());
  }
}
