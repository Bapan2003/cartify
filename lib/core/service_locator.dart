import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qit/data/services/auth_services/auth_services_imple.dart';

import '../repo/auth_service/auth_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Register Firebase instances (singletons)
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton(() => FirebaseStorage.instance);
  getIt.registerLazySingleton(() => GoogleSignIn());

  // Register your Auth service
  getIt.registerLazySingleton<AuthServices>(
    () => AuthServicesImplementation(
      auth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );
}
