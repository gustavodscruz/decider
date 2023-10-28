import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decider/models/Question.dart';
import 'package:decider/services/auth_service.dart';
import 'package:decider/views/helpers/question_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<Object> _historyList = [];

  @override
  void didChangeDependecies() {
    // TODO: implement didChangesDependecies
    super.didChangeDependencies();
    getUsersQuestionsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Past Decisions"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
          child: ListView.builder(
        itemCount: _historyList.length,
        itemBuilder: (context, index) {
          return QuestionCard(_historyList[index] as Question);
        },
      )),
    );
  }

  Future getUsersQuestionsList() async {
    final uid = context.read<AuthService>().currentUser?.uid;
    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('questions')
        .orderBy('created', descending: true)
        .get();
    setState(() {
      _historyList =
          List.from(data.docs.map((doc) => Question.fromSnapshot(doc)));
    });
  }
}
