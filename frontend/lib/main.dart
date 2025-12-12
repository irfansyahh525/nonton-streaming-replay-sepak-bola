import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:streaming_bola_app/services/auth_service.dart';
import 'package:streaming_bola_app/pages/login_page.dart';
import 'package:streaming_bola_app/pages/dashboard_page.dart';
import 'package:video_player_web_hls/video_player_web_hls.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp.router(
        title: 'Streaming Bola',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF1A73E8),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: const Color(0xFF34A853),
          ),
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A1A1A),
            elevation: 0,
            centerTitle: true,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F0F0F),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
            bodyMedium: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}
