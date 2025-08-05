import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siapbos/provider/authProvider.dart';
import 'package:siapbos/screen/loginpageScreen.dart';
import 'package:siapbos/screen/user/userPage.dart';
import 'package:siapbos/widget/bottomNavigation.dart';

GoRouter router(AuthState authState) {
  return GoRouter(
    refreshListenable: authState,
    initialLocation: '/login',
    redirect: (context, state) {
      print('🔁 GoRouter redirect: loading=${authState.loading}, token=${authState.token}, role=${authState.role}');

      if (authState.loading) return '/loading';

      final isLoggedIn = authState.token != null;
      final isLoggingIn = state.fullPath == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';

      if (isLoggedIn && isLoggingIn) {
        switch (authState.role) {
          case 'admin':
            return '/admin';
          case 'manager':
            return '/manager';
          default:
            return '/user';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
      GoRoute(
        path: '/loading',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => bottomNavigationBar(),
      ),
      GoRoute(
        path: '/user',
        builder: (context, state) => bottomNavigationBar(),
      ),
      GoRoute(
        path: '/manager',
        builder: (context, state) => bottomNavigationBar(), 
      ),
    ],
  );
}
