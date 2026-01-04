import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Signup
  Future<User?> signUp(String email, String password, String name, String phone, String role) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user in Firestore
      await _firestore.collection("users").doc(userCred.user!.uid).set({
        "name": name,
        "phone": phone,
        "email": email,
        "role": role,
        "createdAt": DateTime.now(),
      });

      return userCred.user;
    } catch (e) {
      print("Signup error: $e");
      return null;
    }
  }

  // ✅ Login
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // ✅ Get User Role
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("users").doc(uid).get();
      return doc["role"];
    } catch (e) {
      print("Get role error: $e");
      return null;
    }
  }

  // ✅ Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
