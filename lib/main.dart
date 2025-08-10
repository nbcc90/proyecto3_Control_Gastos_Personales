import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

import 'views/login.dart';
import 'views/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    final router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isLoggedIn = box.read('isLoggedIn') ?? false;
        final goingToLogin = state.matchedLocation == '/login';
        if (!isLoggedIn && !goingToLogin) return '/login';
        if (isLoggedIn && goingToLogin) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gastos Personales',
      routerConfig: router,
    );
  }
}