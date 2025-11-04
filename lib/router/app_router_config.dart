import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qit/presentations/screens/auth/login.dart';
import 'package:qit/presentations/screens/dashboard/dashboard_screen.dart';
import 'package:qit/presentations/screens/product/product_details_screen.dart';
import 'package:qit/presentations/screens/profile/profile_screen.dart';

import '../presentations/my_app.dart';
import '../presentations/screens/splash/splash_screen.dart';
import '../providers/auth_providers.dart';
import 'app_route.dart';


enum TransitionType { fade, slide, scale, bottomToTop }

class AppRouterConfig {
  late final GoRouter router = GoRouter(
    routes: _routes,
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: AppRoute.root,
    redirect: (context, state) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final isSplash = state.matchedLocation == AppRoute.root;
      final isLoggedIn = auth.user != null;

      if (isSplash) return null; // stay on splash until check completes
      if (!isLoggedIn && state.matchedLocation != AppRoute.login) return AppRoute.login;
      if (isLoggedIn && state.matchedLocation == AppRoute.login) return AppRoute.dashboard;
      return null;
    },
  );

  late final _routes = <RouteBase>[
    GoRoute(
      path: AppRoute.root,
      name: AppRoute.root,
      pageBuilder: (context, state) => buildTransitionPage(
        child: SplashScreen(),
        state: state,
        type: TransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRoute.login,
      name: AppRoute.login,
      pageBuilder: (context, state) => buildTransitionPage(
        child: const LoginScreen(),
        state: state,
        type: TransitionType.slide,
      ),
    ),
    GoRoute(
      path: AppRoute.dashboard,
      name: AppRoute.dashboard,
      pageBuilder: (context, state) => buildTransitionPage(
        child: const DashboardScreen(),
        state: state,
        type: TransitionType.scale,
      ),
    ),
    GoRoute(
      path: AppRoute.productDetails,
      name: AppRoute.productDetails,
      pageBuilder: (context, state) {
        final productId = state.uri.queryParameters['productId'];
        return buildTransitionPage(
          child: ProductDetailsPage(productId: productId),
          state: state,
          type: TransitionType.bottomToTop,
        );
      },
    ),

  ];

  void dispose() {}

  CustomTransitionPage buildTransitionPage({
    required Widget child,
    required GoRouterState state,
    TransitionType type = TransitionType.slide,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case TransitionType.fade:
            return FadeTransition(opacity: animation, child: child);
          case TransitionType.slide:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0), // right to left
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case TransitionType.scale:
            return ScaleTransition(scale: animation, child: child);
          case TransitionType.bottomToTop:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1), // 👈 bottom to top
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
        }
      },
    );
  }
}
