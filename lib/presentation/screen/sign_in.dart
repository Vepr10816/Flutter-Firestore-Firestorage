import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter/presentation/screen/sign_up.dart';
import 'package:firebase_flutter/presentation/screen/widgets/custom_button.dart';
import 'package:firebase_flutter/presentation/screen/widgets/text_field_obscure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'main_screen.dart';


class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);
  static const routeName = '/signin';

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _loginController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool isObscure = true;
  bool _isValid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _key,
            child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(child: SizedBox()),
                    const Text(
                      'Учет финансов',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26),
                    ),
                    const Expanded(child: SizedBox()),
                    TextFormField(
                      controller: _loginController,
                      validator: (value) {
                        if (!_isValid) {
                          return null;
                        }
                        if (value!.isEmpty) {
                          return 'Поле логин пустое';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Логин',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      validator: (value) {
                        if (!_isValid) {
                          return null;
                        }
                        if (value!.isEmpty) {
                          return 'Поле пароль пустое';
                        }
                        return null;
                      },
                      obscureText: isObscure,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        suffixIcon: TextFieldObscure(isObscure: (value) {
                          setState(() {
                            isObscure = value;
                          });
                        }),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      content: 'Войти',
                      onPressed: () {
                        _isValid = true;
                        if (_key.currentState!.validate()) {
                          signIn();
                        } else {}
                      },
                    ),
                    const Expanded(flex: 3, child: SizedBox()),
                    InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        _loginController.clear();
                        _passwordController.clear();
                        _isValid = false;
                        _key.currentState!.validate();
                        Navigator.pushNamed(context, SignUp.routeName);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Регистрация в системе',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      
                    ),

                    InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        _loginController.clear();
                        _passwordController.clear();
                        _isValid = false;
                        _key.currentState!.validate();
                        FirebaseAuth.instance.signInAnonymously();
                        Navigator.pushNamed(context, MainScreen.routeName);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Зайти просто так',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      
                    ),
                    
                  ],
            ),
          ),
        ),
      ),
    );
  }
 
 String email = '';
  void signIn() async {
    final auth = FirebaseAuth.instance;
    //FirebaseAuth.instance.signInWithEmailAndPassword(email: _loginController.text, password: _passwordController.text);
    //Navigator.pushNamed(context, MainScreen.routeName);
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: _loginController.text,
        password: _passwordController.text,
      );
      Navigator.pushNamed(context, MainScreen.routeName);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found')
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Пользователь не найден')));
      else if (e.code == 'wrong-password')
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Не правильный пароль')));
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString())));
    }
  }
}
