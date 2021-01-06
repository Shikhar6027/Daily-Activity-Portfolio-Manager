import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todolist/loginscreen.dart';
import 'package:todolist/uipage.dart';
import 'package:flutter/material.dart';
import 'package:todolist/authentication.dart';

class MyHomePage extends StatefulWidget {
  final String uid;

  MyHomePage({Key key, @required this.uid}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState(uid);
}

class _MyHomePageState extends State<MyHomePage> {
  final String uid;
  _MyHomePageState(this.uid);
  //final db = Firestore.instance;
  var taskcollection = Firestore.instance.collection('Tasks');
  String task;
  void showdialog(bool isUpdate, DocumentSnapshot ds) {
    GlobalKey formkey = GlobalKey<FormState>();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: isUpdate ? Text("Update todos..") : Text("Add Todo"),
            content: Form(
                key: formkey,
                autovalidate: true,
                child: TextFormField(
                  autofocus: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "TASk",
                  ),
                  validator: (_val) {
                    if (_val.isEmpty) {
                      return "Can't be empty";
                    } else
                      return null;
                  },
                  onChanged: (_val) {
                    task = _val;
                  },
                )),
            actions: <Widget>[
              RaisedButton(
                onPressed: () {
                  if (isUpdate) {
                    taskcollection
                        .document(uid)
                        .collection('Tasks')
                        .document(ds.documentID)
                        .updateData({'task': task, 'time': DateTime.now()});
                  } else {
                    taskcollection
                        .document(uid)
                        .collection('Tasks')
                        .add({'task': task, 'time': DateTime.now()});

                    // db
                    //     .collection('Tasks')
                    //     .add({'task': task, 'time': DateTime.now()});
                  }

                  Navigator.pop(context);
                },
                child: Text("Add"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Todo List",
            style: TextStyle(
              fontFamily: "tepeno",
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () => signOutUser().then((value) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false);
              }),
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: taskcollection
              .document(uid)
              .collection('Tasks')
              .orderBy('time')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.documents[index];
                  return Card(
                    color: Colors.deepPurple[300],
                    child: ListTile(
                      leading: IconButton(
                          color: Colors.white,
                          icon: Icon(Icons.update),
                          onPressed: () => showdialog(true, ds)),
                      title: Text(
                        ds.data['task'],
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        color: Colors.white,
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // db.collection('Tasks').document(ds.documentID).delete();
                          taskcollection
                              .document(uid)
                              .collection('Tasks')
                              .document(ds.documentID)
                              .delete();
                        },
                      ),
                      // onLongPress:
                      //onTap: () => showdialog(true, ds),
                    ),
                  );
                },
              );
            } else if (snapshot.error) {
              return CircularProgressIndicator();
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showdialog(false, null),
          child: Icon(Icons.add),
          backgroundColor: Colors.deepPurple,
        ),
      )),
    );
  }
}
