import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decider/firebase_options.dart';
import 'package:decider/models/Account.dart';
import 'package:decider/services/auth_service.dart';
import 'package:decider/views/home_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService().getOrCreateUser();
  initializeDateFormatting('pt-BR', null).then((_) => runApp(MultiProvider(
        providers: [Provider.value(value: AuthService())],
        child: const DeciderApp(),
      )));
}

class DeciderApp extends StatelessWidget {
  const DeciderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Decider',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.red, backgroundColor: Colors.white),
          useMaterial3: true,
        ),
        home: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(context.read<AuthService>().currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              Account account = Account.fromSnapshot(snapshot.data, context.read<AuthService>().currentUser?.uid);
              return HomeView(account: account);           
            }
            return const CircularProgressIndicator();
          }
        ));
  }
}
