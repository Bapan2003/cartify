import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qit/repo/auth_service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthServices _authServices;
  AuthProvider({required AuthServices authService}):_authServices=authService;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  User? get user => _auth.currentUser;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isLoginMode = true;

  bool get isLoginMode => _isLoginMode;

  void toggleMode() {
    _isLoginMode = !_isLoginMode;
    notifyListeners();
  }

  Future<void> signInWithEmail(
      String email,
      String password,
      ) async {
    _isLoading=true;
    notifyListeners();
    try{
      await _authServices.signInWithEmail(email: email, password: password);
    }catch(e){
      rethrow;
    }finally{
      _isLoading=false;
      notifyListeners();
    }

  }


  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
    // String phoneNumber,
  ) async {
    _isLoading=true;
    notifyListeners();
    try{
      await _authServices.signUpWithEmail(email: email, password: password,name: name,);
    }catch(e){
      rethrow;
    }finally{
      _isLoading=false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle()async {
    try{
      await _authServices.signInWithGoogle();
    }catch(e){
      rethrow;
    }
  }


  Future<void> signOut() async {
    try{
      await _authServices.signOut();
    }catch(e){
      rethrow;
    }
  }

  // 🔹 Save or update user profile
  Future<void> saveUserProfile(User user, {String? name, String? phone}) async {
    try{
      await _authServices.saveUserProfile(user,name: name,phone: phone);
    }catch(e){
      rethrow;
    }
  }

  // 🔹 Fetch user data stream (real-time)
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream() {
    try {

      return _authServices.getUserDataStream();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile(String name, String phone, {String? photo}) async {
    try{
      return _authServices.updateProfile(name, phone,photo: photo,user: user);
    }catch(e){
      rethrow;
    }
  }


  Future<String?> uploadProfileImage(String uid, File imageFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(uid);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload failed: $e');
      return null;
    }
  }
}
