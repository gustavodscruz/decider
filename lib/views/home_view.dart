import 'dart:math';

import 'package:decider/extensions/string_extension.dart';
import 'package:decider/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _answer = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onTap: () {},
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
    );
  }

  Widget _buildQuestionsForm() {
    return Column(
      children: <Widget>[
        Text(
          "Should I...",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
          child: TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                helperText: "Enter a question"),
          ),
        ),
        ElevatedButton(
            onPressed: () {
              setState(() {
                _answer = _getAnswer();
              });
              _getAnswer();
            },
            child: const Text("Ask")),
        _questionAndAnswer()
      ],
    );
  }

  String _getAnswer() {
    var answerOptions = ['Yes', 'No', 'Definitily', 'not right now'];
    return answerOptions[Random().nextInt(answerOptions.length)];
  }

  Widget _questionAndAnswer(){
    if(_answer != ""){
      return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text("Should I ####?"),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text("Answer: ${_answer.capitalize()}", style: Theme.of(context).textTheme.titleMedium,),
        )
      ],
    );
    }
    else{
      return Container();
    }
    
  }

}
