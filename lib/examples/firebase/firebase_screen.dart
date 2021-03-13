import 'package:android_course/examples/firebase/firebase_repository.dart';
import 'package:android_course/examples/firebase/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef _Builder = Widget Function(BuildContext);

class _FirebaseExample {
  final String name;
  final _Builder builder;

  _FirebaseExample(this.name, this.builder);
}

class FirebaseScreen extends StatefulWidget {
  @override
  _FirebaseScreenState createState() => _FirebaseScreenState();
}

class _FirebaseScreenState extends State<FirebaseScreen> {
  int? _selectedIndex = 0;

  static const userId = 'ybftiB2mepd0Eh8JljJI';

  final List<_FirebaseExample> info = [
    _FirebaseExample('One-time get', (context) => GetUserName(userId)),
    _FirebaseExample('Read all documents', (context) => GetAllUsers()),
    _FirebaseExample('Realtime get', (context) => GetUserNameRealtime(userId)),
    _FirebaseExample(
        'Read all documents (realtime)', (context) => GetAllUsersRealtime()),
    _FirebaseExample('Cloud Storage', (context) => CloudStorageUploader()),
    _FirebaseExample(
        'Transaction Read/Write', (context) => TransactionReadWrite())
  ];

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => FirebaseRepository(1),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Firebase Examples'),
        ),
        body: Column(
          children: [
            Container(
              height: 60.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: info.length,
                itemBuilder: (context, index) {
                  final item = info[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(item.name),
                          Radio(
                            value: index,
                            groupValue: _selectedIndex,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedIndex = value;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
                padding: EdgeInsets.all(16.0),
                child: info[_selectedIndex!].builder(context)
                // Build the selected widget,
                )
          ],
        ),
      ),
    );
  }
}
