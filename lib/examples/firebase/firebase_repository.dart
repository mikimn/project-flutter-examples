import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final int version;

  FirebaseRepository(this.version);

  DocumentReference db() => _db.collection('versions').doc('v$version');
}
