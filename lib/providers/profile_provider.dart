import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../data/model/order_model.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool currentPasswordVisible = false;
  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;

  final ImagePicker _picker = ImagePicker();

  String name = '';
  String? profileImage; // URL from Firebase Storage
  XFile? pickedImage;

  // Password fields
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';

  bool loading = false;

  // Load user data from Firestore
  Future<void> loadUserData() async {
    final user = _auth.currentUser!;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data != null) {
      name = data['name'] ?? '';
      profileImage = data['photoUrl'];
      notifyListeners();
    }
  }
  void setPassword(String field, String value) {
    switch (field) {
      case 'current':
        currentPassword = value;
        break;
      case 'new':
        newPassword = value;
        break;
      case 'confirm':
        confirmPassword = value;
        break;
    }
    notifyListeners();
  }

  void toggleVisibility(String field) {
    switch (field) {
      case 'current':
        currentPasswordVisible = !currentPasswordVisible;
        break;
      case 'new':
        newPasswordVisible = !newPasswordVisible;
        break;
      case 'confirm':
        confirmPasswordVisible = !confirmPasswordVisible;
        break;
    }
    notifyListeners();
  }

  // Pick image (works on web & mobile)
  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      pickedImage = picked;
      notifyListeners();
    }
  }

  OrderModel? _selectedOrder;

  OrderModel? get selectedOrder => _selectedOrder;

  void setSelectedOrder(OrderModel order) {
    _selectedOrder = order;
    notifyListeners();
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(XFile image) async {
    final user = _auth.currentUser!;
    final ref = _storage.ref().child('profile_images/${user.uid}_${DateTime.now().millisecondsSinceEpoch}');
    if (kIsWeb) {
      // Web: upload as bytes
      Uint8List bytes = await image.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));
    } else {
      // Mobile: upload as File
      await ref.putFile(File(image.path), SettableMetadata(contentType: 'image/png'));
    }
    return await ref.getDownloadURL();
  }


  // Update profile
  Future<void> updateProfile() async {
    loading = true;
    notifyListeners();

    final user = _auth.currentUser!;
    String imageUrl = profileImage ?? '';

    if (pickedImage != null) {
      imageUrl = await _uploadImage(pickedImage!);
    }

    await _firestore.collection('users').doc(user.uid).update({
      'name': name,
      if (imageUrl.isNotEmpty) 'photoUrl': imageUrl,
    });

    pickedImage = null;
    loading = false;
    notifyListeners();
  }

  Stream<List<OrderModel>> getUserOrders() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('orders')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(),id: doc.id))
          .toList();

      return orders;
    });
  }

  // Change password
  Future<String?> changePassword() async {

    final user = _auth.currentUser!;
    if (newPassword != confirmPassword) {
      return 'Passwords do not match';
    }
    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      currentPassword = newPassword = confirmPassword = '';
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
