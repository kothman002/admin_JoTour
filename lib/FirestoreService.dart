import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_login_page/user_control.dart';

class FirestoreService {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');

  Stream<List<User>> getUsers() {
    return usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => User.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addUser(User user) async {
    await usersCollection.doc(user.email).set({
      'email': user.email,
      'username': user.username,
      'bio': user.bio,
    });
  }

  Future<void> deleteUser(String email) async {
    await usersCollection.doc(email).delete();
  }
}
