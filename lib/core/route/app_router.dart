import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/screens/welcome_splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/chat/screens/chat_dashboard_screen.dart';
import '../../features/chat/screens/immersive_chat_screen.dart';
import '../../features/call/screens/video_call_screen.dart';
import '../../features/profile/screens/find_connections_screen.dart';
import '../../features/profile/screens/profile_settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isAuthRoute = state.matchedLocation == '/' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    // Unauthenticated users can only access auth routes
    if (!isLoggedIn && !isAuthRoute) return '/';
    // Authenticated users trying to access auth routes -> home
    if (isLoggedIn && isAuthRoute) return '/home';

    return null;
  },
  routes: [
    // ─── Auth ──────────────────────────────────────
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeSplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // ─── Chat ──────────────────────────────────────
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

    // ─── Call ──────────────────────────────────────
    GoRoute(
      path: '/video-call',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return VideoCallScreen(
          calleeId: extra['calleeId'] ?? '',
          calleeName: extra['calleeName'] ?? 'User',
          isCaller: extra['isCaller'] ?? true,
        );
      },
    ),

    // ─── Profile ──────────────────────────────────
    GoRoute(
      path: '/find-connections',
      builder: (context, state) => const FindConnectionsScreen(),
    ),
    GoRoute(
      path: '/profile-settings',
      builder: (context, state) => const ProfileSettingsScreen(),
    ),
  ],
);
