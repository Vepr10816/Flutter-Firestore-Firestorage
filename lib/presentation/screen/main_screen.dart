import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter/presentation/screen/sign_up.dart';
import 'package:firebase_flutter/presentation/screen/widgets/custom_button.dart';
import 'package:firebase_flutter/presentation/screen/widgets/text_field_obscure.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

class MainScreen extends StatefulWidget {

  late final String title;

  @override
  _MainScreenState createState() => _MainScreenState();
  static const routeName = '/main';
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('photos').snapshots();
  int counter = 0;
  late String idUser = '';

  void _incrementCounter() async{
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      dialogTitle: 'Выбор файла',
    );

    if(result != null){
      Uint8List? file = result.files.single.bytes;
      final fileName = result.files.first.name;
      final fileSize = result.files.first.size;
      String fileUrl = '${DateTime.now()}.png';

      final FirebaseFirestore fireStore = FirebaseFirestore.instance;

      Reference ref = FirebaseStorage.instance.ref().child(fileUrl);
      
      UploadTask uploadTask = ref.putData(file!, SettableMetadata(contentType: 'image/png'));
      TaskSnapshot taskSnapshot = await uploadTask
        .whenComplete(() => print('done'))
          .catchError((error) => print('something went wrong'));
      String url = await taskSnapshot.ref.getDownloadURL();

      await fireStore
          .collection('photos')
          .add(
            {
              'user': idUser,
              'fileUrlName': fileUrl,
              'fileName': fileName,
              'fileSize': fileSize,
              'fileUrl': url
            },
          )
          .then((value) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Photo Added"))))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to add photo: $error"))));
    }
    else{
      
    }
    
  }

  String link = '';
  List<ModelTest> fullpath = [];

  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))
  ));

  Future<void> initImage() async {
    fullpath.clear();
    final storageReference = FirebaseStorage.instance.ref().list();
    final list = await storageReference;
    list.items.forEach((element) async {
      final url = await element.getDownloadURL();
      fullpath.add(ModelTest(url, element.name));
      
      setState(() {});

    });
    print(fullpath.length);
    print(list.items.length);
  }

  @override
  void initState(){
    initImage().then((value){

      setState(() {});
      print(fullpath.length);
    }
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;
    idUser = arguments['idUser'].toString();

    return Scaffold(
      /*appBar: AppBar(
         title: const Text('title'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () async{
            await initImage();
          },
            child: const Text("Обновить")),
        ],
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
           children: [
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: fullpath.length,
                itemBuilder: (context, index){
                  return Card(
                    child: InkWell(
                      onLongPress: () async{
                        link = '';
                        await FirebaseStorage.instance.ref("/" + fullpath[index].name!).delete();
                        await initImage();
                        setState(() {});
                      },
                      onTap: () {
                          link = fullpath[index].url!;
                        setState(() {
                        });
                      },
                      child: ListTile(
                        title: Text(fullpath[index].url!),
                      )
                      /*Image.network(
        fullpath[index].url!,
        width: 200,
        height: 200,
        //fit: BoxFit.cover,
      ),*/
                    ),
                  );
                }
                ),
            ),
            Expanded(
              flex: 2,
              child: Image.network(
                link,
                errorBuilder: (context, error, stackTrace){
                  return Text('Ошибка');
                },
              ),
            )
           ],
           ) 
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),*/


















      appBar: AppBar(
        title: const Text('Фотки пользователя'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: _incrementCounter,
            child: const Text("Добавить")),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('photos').where('user', isEqualTo: idUser).snapshots(),
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
                            return /*Row(
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

                            );*/

                          Card(
                          child: InkWell(
                            onLongPress: () async{
                              link = '';
                              await FirebaseStorage.instance.ref("/" + data['fileUrlName']!).delete().then((value) async => 
                              await FirebaseFirestore.instance
                              .collection('photos').doc(document.id)
                              .delete());
                            },
                            onTap: () {
                              setState(() {
                                setState(() {
                                      showPhotoScreen(data['fileUrl']);
                                    });
                              });
                            },
                            child: ListTile(
                              title: Text('${data['fileName']}: ${data['fileSize']} МБ ${data['fileUrl']}'),
                            )
                            /*Image.network(
              fullpath[index].url!,
              width: 200,
              height: 200,
              //fit: BoxFit.cover,
            ),*/
                          ),
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
          ),
          /*Expanded(child: 
          Image.network(
                link,
                errorBuilder: (context, error, stackTrace){
                  return Text('Ошибка');
                },
              ),
          ),*/
        ],
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


  void showPhotoScreen(String fileUrl) async {
    _emailController.text ='';
                showDialog(
      context: context,
      builder: (context) => gradeDialog2(fileUrl),
    );
  }

  StatefulBuilder gradeDialog2(String fileUrl) {
    return StatefulBuilder(
      builder: (context, _setter) {
        return SimpleDialog(
          children: [
            Image.network(
                fileUrl,
                errorBuilder: (context, error, stackTrace){
                  return Text('Ошибка');
                },
              )
          ],
        );
      },
    );
  }

  
}

class ModelTest {

  String? url;
  String? name;
  
  ModelTest( this.url, this.name);

}
