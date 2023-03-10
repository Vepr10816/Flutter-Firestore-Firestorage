import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter/presentation/screen/sign_up.dart';
import 'package:firebase_flutter/presentation/screen/widgets/custom_button.dart';
import 'package:firebase_flutter/presentation/screen/widgets/text_field_obscure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
  static const routeName = '/main';
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('user').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пользователи'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              setState(() {
                showAddScreen();
              });
            },
            child: const Text("Добавить")),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
          return
              ListView(
                padding: const EdgeInsets.all(8),
                children: snapshot.data!.docs
                    .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  onPressed: () async {
                                      deleteUser(document.id);
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showUpdateScreen(data['email'], document.id );
                                    });
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      Text(data['email'])
                                ),
                              ]

                      );
                      
                      /*ListTile(
                        title: Text(data['email'])
                      );*/
                    })
                    .toList()
                    .cast(),
              );
        },
      ),
    );
  }

  void showUpdateScreen(String email, String uid) async {
    // await context.read<ListCubit>().getID(index);
    _emailController.text = email;
    showDialog(
      context: context,
      builder: (context) => gradeDialog(1, uid),
    );
  }
  
  void showAddScreen() async {
    _emailController.text ='';
                showDialog(
      context: context,
      builder: (context) => gradeDialog(-1, ''),
    );
  }

  StatefulBuilder gradeDialog(int index, String uid) {
    return StatefulBuilder(
      builder: (context, _setter) {
        return SimpleDialog(
          children: [
            const Spacer(),
            const Text(
              'Менеджмент электронных почт',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26),
            ),
            const Spacer(),
            TextFormField(
              controller: _emailController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Поле email пустое';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
                content: 'Сохранить',
                onPressed: () {
                  if(index!=-1)
                  {
                    updUser(uid);
                  }
                  else{
                    addUser();
                  }
                }),
          ],
        );
      },
    );
  }

  void addUser() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
      await fireStore
          .collection('user')
          .add(
            {'email': _emailController.text},
          )
          .then((value) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("User Added"))))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to add user: $error"))));
      Navigator.pop(context);
  }

  void updUser(String uid) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
      await fireStore
          .collection('user').doc(uid)
          .set(
            {'email': _emailController.text},
          )
          .then((value) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("User Update"))))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to update user: $error"))));
      Navigator.pop(context);
  }

  void deleteUser(String uid) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
      await fireStore
          .collection('user').doc(uid)
          .delete(
          )
          .then((value) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("User Delete"))))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to delete user: $error"))));
  }

  
}
