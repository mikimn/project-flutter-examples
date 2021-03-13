import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';

class GetUserName extends StatelessWidget {
  final String documentId;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  GetUserName(this.documentId);

  Future<DocumentSnapshot> _getUser() {
    return db.collection('users').doc(documentId).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _getUser(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // ...
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data?.data() ??
              {'first_name': 'unknown', 'last_name': 'unknown'};
          return Text('Full Name: ${data['first_name']} ${data['last_name']}');
        }
        return CircularProgressIndicator();
      },
    );
  }
}

class MyUser {
  String? firstName;
  String? lastName;
  String? occupation;

  MyUser(this.firstName, this.lastName, this.occupation);

  MyUser.fromJson(Map<String, dynamic> m)
      : this(m['first_name'], m['last_name'], m['occupation']);
}

class GetAllUsers extends StatelessWidget {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<MyUser>> _getAllUsers() {
    return db.collection('users').get().then((value) => value.docs
        .map((e) => MyUser.fromJson({...?e.data()}))
        .toList()); // Map the query result to the list of documents
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MyUser>>(
      future: _getAllUsers(),
      builder: (BuildContext context, AsyncSnapshot<List<MyUser>> snapshot) {
        // ...
        if (snapshot.connectionState == ConnectionState.done) {
          List<MyUser> data = snapshot.data!;
          print(data);
          return SizedBox(
            height: 200.0,
            child: ListView.separated(
                itemBuilder: (context, index) {
                  final MyUser item = data[index];
                  return ListTile(
                    title: Text(
                        '${item.firstName} ${item.lastName}, ${item.occupation}'),
                  );
                },
                separatorBuilder: (_, __) => Divider(),
                itemCount: data.length),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}

class GetUserNameRealtime extends StatelessWidget {
  final String documentId;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  GetUserNameRealtime(this.documentId);

  Stream<DocumentSnapshot> _getUser() {
    return db.collection('users').doc(documentId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _getUser(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // ...
        if (snapshot.hasData) {
          Map<String, dynamic> data = snapshot.data?.data() ??
              {'first_name': 'unknown', 'last_name': 'unknown'};
          return Text('Full Name: ${data['first_name']} ${data['last_name']}');
        }
        return CircularProgressIndicator();
      },
    );
  }
}

class GetAllUsersRealtime extends StatelessWidget {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<List<QueryDocumentSnapshot>> _getAllUsers() {
    return db.collection('users').snapshots().map(
        (value) => value.docs); // Map the query result to the list of documents
  }

  Future<void> _deleteUser(String userId) {
    return db.collection('users').doc(userId).delete();
  }

  Future<void> _updateUserOccupation(String userId, String newOccupation) {
    return db
        .collection('users')
        .doc(userId)
        .update({'occupation': newOccupation});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _getAllUsers(),
      builder: (BuildContext context,
          AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
        // ...
        if (snapshot.hasData) {
          final List<QueryDocumentSnapshot> data = snapshot.data!;
          return SizedBox(
            height: 200.0,
            child: ListView.separated(
                itemBuilder: (context, index) {
                  final Map<String, dynamic> item = data[index].data()!;
                  final userId = data[index].id;
                  return ListTile(
                    title: Text(
                        '${item['first_name']} ${item['last_name']}, ${item['occupation']}'),
                    leading: IconButton(
                      icon: Icon(Icons.thumb_down),
                      onPressed: () {
                        _updateUserOccupation(userId, 'Unemployed');
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: () {
                        _deleteUser(userId);
                      },
                    ),
                  );
                },
                separatorBuilder: (_, __) => Divider(),
                itemCount: data.length),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}

class CloudStorageUploader extends StatefulWidget {
  @override
  _CloudStorageUploaderState createState() => _CloudStorageUploaderState();
}

class _CloudStorageUploaderState extends State<CloudStorageUploader> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const FILE_NAME = 'avatar.png';

  String? _imageUrl;

  Future<String> _getImageUrl(String name) {
    return _storage.ref('images').child(name).getDownloadURL();
  }

  Future<String> _uploadNewImage(File file, String name) {
    return _storage
        .ref('images')
        .child(name)
        .putFile(file)
        .then((snapshot) => snapshot.ref.getDownloadURL());
  }

  @override
  void initState() {
    super.initState();
    _getImageUrl(FILE_NAME).then((value) => setState(() {
          _imageUrl = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _imageUrl == null
                    ? SizedBox(
                        width: 60.0,
                        height: 60.0,
                        child: Center(child: CircularProgressIndicator()))
                    : Image.network(
                        _imageUrl!,
                        height: 60.0,
                        width: 60.0,
                      ),
                VerticalDivider(),
                RaisedButton.icon(
                  icon: Icon(Icons.cloud_upload),
                  label: Text('Upload new'),
                  onPressed: () async {
                    // Pick an image with the file_picker library
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: FileType.image);

                    if (result != null) {
                      File file = File(result.files.single.path!);
                      setState(() {
                        _imageUrl = null;
                      });
                      _imageUrl = await _uploadNewImage(file, FILE_NAME);
                      setState(() {});
                    }
                  },
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Html(
                data:
                    'Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>'),
          ],
        ),
      ),
    );
  }
}

class TransactionReadWrite extends StatefulWidget {
  @override
  _TransactionReadWriteState createState() => _TransactionReadWriteState();
}

class _TransactionReadWriteState extends State<TransactionReadWrite> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: StreamBuilder<Map<String, dynamic>?>(
            stream: _db
                .collection('counters')
                .doc('global-counter')
                .snapshots()
                .map((event) => event.data()),
            initialData: {'value': 'Loading...'},
            builder: (context, snapshot) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlineButton(
                    highlightedBorderColor: Colors.green,
                    child: Text(
                      '+ Counter (${snapshot.data!['value']})',
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: _doTransaction,
                  ),
                  VerticalDivider(),
                  OutlineButton(
                    highlightedBorderColor: Colors.red,
                    child: Text('- Counter (${snapshot.data!['value']})',
                        style: TextStyle(color: Colors.red)),
                    onPressed: () => _doTransaction(isSubstraction: true),
                  ),
                ],
              );
            }),
      ),
    );
  }

  Future<void> _doTransaction({bool isSubstraction = false}) async {
    // Create a reference to the document the transaction will use
    DocumentReference documentReference =
        _db.collection('counters').doc('global-counter');

    return _db
        .runTransaction((transaction) async {
          // Get the document
          DocumentSnapshot snapshot = await transaction.get(documentReference);

          if (!snapshot.exists) {
            throw Exception('Counter does not exist!');
          }

          // Update the counter based on the current value
          // Note: this could be done without a transaction
          // by updating the field using FieldValue.increment()
          int? oldCount = snapshot.data()!['value'];
          int newCount = isSubstraction ? oldCount! - 1 : oldCount! + 1;

          // Perform an update on the document
          transaction.update(documentReference, {'value': newCount});

          // Return the new count
          return newCount;
        })
        .then((value) => print('Counter updated to $value'))
        .catchError((error) => print('Failed to update counter: $error'));
  }
}
