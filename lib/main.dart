import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_flutter/presentation/screen/main_screen.dart';
import 'package:firebase_flutter/presentation/screen/sign_in.dart';
import 'package:firebase_flutter/presentation/screen/sign_up.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

final FirebaseFirestore fireStore = FirebaseFirestore.instance;
Future<void> add() {
  final user = fireStore.collection('user');
  return user
  .add(
  {
  'name': 'John Doe',
  'age': 30,
  'email': 'johndoe@example.com',
  },
  )
  .then((value) => print("User Added"))
  .catchError((error) => print("Failed to add user: $error"));
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  
  /*FirebaseAuth.instance.createUserWithEmailAndPassword(email: 'isip_a.n.veprickiy@mpt.ru',password: '123456').then((value) {
    print(value.user?.email);
    print(value.user?.uid);
  });*/
  runApp(const MyApp());
  //await add();
  
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        SignIn.routeName: (context) =>  const SignIn(),
        SignUp.routeName: (context) =>  const SignUp(),
        MainScreen.routeName: (context) => MainScreen(),
      },
    initialRoute: SignIn.routeName,
    );
  }
}
