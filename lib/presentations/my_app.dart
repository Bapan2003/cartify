import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qit/core/service_locator.dart';
import 'package:qit/presentations/screens/splash/splash_screen.dart';
import 'package:qit/providers/category_provider.dart';
import 'package:qit/providers/search_providers.dart';
import 'package:qit/repo/auth_service/auth_service.dart';

import '../providers/auth_providers.dart';
import '../providers/cart_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/product_provider.dart';
import '../providers/search_history_provider.dart';
import '../router/app_router_config.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouterConfig = AppRouterConfig();

  @override
  void dispose() {
    _appRouterConfig.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService: getIt<AuthServices>())),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => SearchHistoryProvider()..init()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),

      ],
      child: MaterialApp.router(
        routerConfig: _appRouterConfig.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
