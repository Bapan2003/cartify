import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qit/presentations/my_app.dart';


import 'core/service_locator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();
  runApp(const MyApp());
}

Future<void> initializeApp() async {

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initHive();
  // ✅ Initialize GetIt dependency locator
  setupLocator();
}

Future<void> initHive() async {
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
  }

  await Hive.openBox<String>('search_history');
}

