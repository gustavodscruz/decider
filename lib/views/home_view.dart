import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decider/extensions/string_extension.dart';
import 'package:decider/models/Account.dart';
import 'package:decider/models/Question.dart';
import 'package:decider/services/auth_service.dart';
import 'package:decider/views/history_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

class HomeView extends StatefulWidget {
  final Account account;
  HomeView({required this.account});
  @override
  State<HomeView> createState() => _HomeViewState();
}

enum AppStatus { ready, waiting }

class _HomeViewState extends State<HomeView> {
  final TextEditingController _questionController = TextEditingController();
  String _answer = "";
  bool _askBtnActive = false;
  final Question _question = Question();
  AppStatus? _appStatus;
  int _timeTillNextFree = 0;
  final CountdownController _countDownController = CountdownController();

  @override
  void initState() {
    super.initState();
    _timeTillNextFree = widget.account.nextFreeQuestion
            ?.difference((DateTime.now()))
            .inSeconds ??
        0;
    _giveFreeDecision(widget.account.bank, _timeTillNextFree);
  }

  @override
  Widget build(BuildContext context) {
    _setAppStatus();
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
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Decisions Left: ${widget.account.bank} "),
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
                Text("${context.read<AuthService>().currentUser?.uid}")
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsForm() {
    if (_appStatus == AppStatus.ready) {
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
    } else {
      return _questionAndAnswer();
    }
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

  Widget _nextFreeCountdown() {
    if (_appStatus == AppStatus.waiting) {
      _countDownController.start();
      var f = NumberFormat("00", "en_US");
      return Column(
        children: [
          const Text("You will get one free decision in"),
          Countdown(
            controller: _countDownController,
            seconds: _timeTillNextFree,
            build: (BuildContext context, double time) => Text(
                "${f.format(time ~/ 3600)} : ${f.format(time % 3600 ~/ 60)} : ${f.format(time % 60)}"),
            interval: const Duration(seconds: 1),
            onFinished: () {
              setState(() {
                _timeTillNextFree = 0;
                _appStatus = AppStatus.ready;
              });
            },
          )
        ],
      );
    } else {
      return Container();
    }
  }

  void _setAppStatus() {
    if (widget.account.bank > 0) {
      setState(() {
        _appStatus = AppStatus.ready;
      });
    } else {
      setState(() {
        _appStatus = AppStatus.waiting;
      });
    }
  }

  void _giveFreeDecision(currentBank, timeTillNextFree) {
    if (currentBank <= 0 && timeTillNextFree <= 0) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.account.uid)
          .update({'bank': 1});
    }
  }

  void _answerQuestion() async {
    setState(() {
      _answer = _getAnswer();
    });
    _question.query = _questionController.text;
    _question.answer = _answer;
    _question.created = DateTime.now();

    widget.account.bank = widget.account.bank -= 1;
    widget.account.nextFreeQuestion = DateTime.now().add(Duration(seconds: 20));

    setState(() {
      _timeTillNextFree = widget.account.nextFreeQuestion?.difference((DateTime.now()))
            .inSeconds ??
        0;
        if(widget.account.bank == 0){
          _appStatus = AppStatus.waiting;
        }
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(context.read<AuthService>().currentUser?.uid)
        .collection('questions')
        .add(_question.toJson());

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.account.uid)
        .update(widget.account.toJson());
  }
}
