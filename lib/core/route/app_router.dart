import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/chat/screens/immersive_chat_screen.dart';
import '../../features/call/screens/video_call_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  redirect: (context, state) {
    // Basic synchronous check for Firebase Auth
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    if (!isLoggedIn && !isLoggingIn) return '/login';
    if (isLoggedIn && isLoggingIn) return '/home';

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const ChatDashboardScreen(),
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (context, state) {
        final roomId = state.pathParameters['id']!;
        return ImmersiveChatScreen(chatRoomId: roomId);
      },
    ),
    GoRoute(
      path: '/call/:remoteUserId',
      builder: (context, state) {
        final remoteUserId = state.pathParameters['remoteUserId']!;
        final isCaller = state.uri.queryParameters['isCaller'] == 'true';
        return VideoCallScreen(remoteUserId: remoteUserId, isCaller: isCaller);
      },
    ),
  ],
);

// Temporary placeholder screen for routing tests
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title, 
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
