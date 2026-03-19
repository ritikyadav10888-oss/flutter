import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
// Firebase imports removed
import 'core/theme/app_theme.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/owner/viewmodels/organizer_viewmodel.dart';
import 'features/owner/viewmodels/tournament_viewmodel.dart';
import 'features/auth/views/login_view.dart';
import 'features/owner/views/owner_dashboard.dart';
import 'features/organizer/views/organizer_dashboard.dart';
import 'features/player/views/player_dashboard.dart';
import 'features/auth/views/player_profile_form_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp removed for custom Node.js backend

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => OrganizerViewModel()),
        ChangeNotifierProvider(create: (_) => TournamentViewModel()),
      ],
      child: MaterialApp(
        title: 'Force Player Register',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    if (authViewModel.isInitializing) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryIndigo,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Syncing session...',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (authViewModel.user == null) {
      return const LoginView();
    }

    // Role-based navigation based on activeRole
    switch (authViewModel.user!.activeRole.name) {
      case 'owner':
        return const OwnerDashboard();
      case 'organizer':
        return const OrganizerDashboard();
      case 'player':
      default:
        if (!authViewModel.user!.isProfileComplete) {
          return PlayerProfileFormView(uid: authViewModel.user!.uid);
        }
        return const PlayerDashboard();
    }
  }
}
