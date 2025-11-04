import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../repo/auth_service/auth_service.dart';

class AuthServicesImplementation implements AuthServices{
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthServicesImplementation({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;



  @override
  Future<void> signInWithEmail({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No user found with this email.";
          break;
        case 'wrong-password':
          message = "Incorrect password. Please try again.";
          break;
        case 'invalid-credential':
          message = "Incorrect user or password. Please try again.";
          break;
        case 'invalid-email':
          message = "The email address is not valid.";
          break;
        case 'user-disabled':
          message = "This account has been disabled.";
          break;
        case 'too-many-requests':
          message = "Too many failed attempts. Please try again later.";
          break;
        case 'network-request-failed':
          message = "Network error. Please check your internet connection.";
          break;
        default:
          message = "Login failed. Please check your email and password.";
      }
      throw message;
    } catch (e) {
      throw "Something went wrong. Please try again.";
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // ✅ Web flow
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        final userCredential = await _auth.signInWithPopup(googleProvider);
        await _createUserDocIfNeeded(userCredential.user!);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        await _createUserDocIfNeeded(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No user found with this email.";
          break;
        case 'wrong-password':
          message = "Incorrect password. Please try again.";
          break;
        case 'invalid-email':
          message = "The email address is not valid.";
          break;
        case 'user-disabled':
          message = "This account has been disabled.";
          break;
        case 'too-many-requests':
          message = "Too many failed attempts. Please try again later.";
          break;
        case 'network-request-failed':
          message = "Network error. Please check your internet connection.";
          break;
        default:
          message = "Login failed. Please check your email and password.";
      }
      throw message;
    } catch (e) {
      throw "Something went wrong. Please try again.";
    }
  }

  @override
  Future<void> signUpWithEmail({required String email, required String password, required String name, required String phoneNumber}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,

      );
      await _createUserDocIfNeeded(userCredential.user!,name: name,phone: phoneNumber);
    } on FirebaseAuthException catch (e) {
      // ✅ Friendly messages for common sign-up errors
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = "This email is already registered. Try logging in instead.";
          break;
        case 'invalid-email':
          message = "The email address is invalid. Please check and try again.";
          break;
        case 'operation-not-allowed':
          message =
          "Email/password accounts are not enabled. Please contact support.";
          break;
        case 'weak-password':
          message = "Your password is too weak. Please use a stronger one.";
          break;
        case 'network-request-failed':
          message = "Network error. Please check your internet connection.";
          break;
        default:
          message = "Sign up failed. Please try again later.";
      }
      throw message;
    } catch (e) {
      throw "Something went wrong during sign up. Please try again.";
    }
  }


  @override
  Future<void> signOut()async  {
    try {
      if (kIsWeb) {
        // ✅ On Web, sign out only from Firebase Auth
        await _auth.signOut();
      } else {
        // ✅ On mobile, sign out from both Google and Firebase
        await _googleSignIn.signOut();
        await _auth.signOut();
      }
    } catch (e) {
      debugPrint("Sign-out error: $e");
      rethrow;
    }
  }


  @override
  Stream<User?> get userChanges => _auth.userChanges();

  Future<void> _createUserDocIfNeeded(
      User user, {
        String? name,
        String? phone,
      }) async {
    final doc = _firestore.collection('users').doc(user.uid);
    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        'name': user.displayName ?? name ?? '',
        'email': user.email ?? '',
        'phone': phone ?? '',
        'photoUrl':
        user.photoURL ??
            'https://firebasestorage.googleapis.com/v0/b/q-it-46b42.firebasestorage.app/o/default-image.png?alt=media&token=66b063bb-4e4f-4770-813e-55933a8da439',
      });
    }
  }

  @override
  Future<void> saveUserProfile(User user, {String? name, String? phone})async {
    final ref = _firestore.collection('users').doc(user.uid);
    await ref.set({
      'uid': user.uid,
      'email': user.email,
      'name': name ?? user.displayName ?? '',
      'phone': phone ?? '',
      'photoUrl': user.photoURL ?? '',
    }, SetOptions(merge: true));
  }



  @override
  Future<void> updateProfile(String name, String phone, {User? user,String? photo}) async{
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).update({
      'name': name,
      'phone': phone,
      'photoUrl': photo,
    });
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently signed in");
    }
    return _firestore.collection('users').doc(currentUser.uid).snapshots();
  }



}