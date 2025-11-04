import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthServices{
   Future<void> signInWithEmail({required String email, required String password});
   Future<void> signUpWithEmail(
       {required String email, required String password, required String name, required String phoneNumber});
   Future<void> signOut();
   Stream<User?> get userChanges;
   Future<void> signInWithGoogle();
   Future<void> saveUserProfile(User user, {String? name, String? phone});
   Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream();
   Future<void> updateProfile(String name, String phone, {User? user,String? photo});

}