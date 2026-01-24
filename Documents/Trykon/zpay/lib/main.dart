import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:zpay/screens/dashboard_screen.dart';
import 'package:zpay/screens/transfers_screen.dart';
import 'package:zpay/screens/wallet_screen.dart';
import 'package:zpay/screens/bills_screen.dart';
import 'package:zpay/screens/savings_screen.dart';
import 'package:zpay/screens/virtual_cards_screen.dart';
import 'package:zpay/screens/merchants_screen.dart';
import 'package:zpay/screens/donations_screen.dart';
import 'package:zpay/screens/cash_out_screen.dart';
import 'package:zpay/screens/login_screen.dart';
import 'package:zpay/screens/profile_screen.dart';
import 'package:zpay/screens/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For web, supply FirebaseOptions (replace placeholders with your project's configs)
  // You can generate a firebase_options.dart using the FlutterFire CLI (`flutterfire configure`).
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'YOUR_API_KEY',
        authDomain: 'YOUR_PROJECT.firebaseapp.com',
        projectId: 'YOUR_PROJECT_ID',
        storageBucket: 'YOUR_PROJECT.appspot.com',
        messagingSenderId: 'SENDER_ID',
        appId: 'APP_ID',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const ProviderScope(child: ZPayApp()));
}

class ZPayApp extends ConsumerWidget {
  const ZPayApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _router = GoRouter(
      initialLocation: DashboardScreen.routeName,
      routes: [
        GoRoute(
            path: DashboardScreen.routeName,
            builder: (context, state) => const DashboardScreen()),
        GoRoute(
            path: '/transfers',
            builder: (context, state) => const TransfersScreen()),
        GoRoute(
            path: '/wallet', builder: (context, state) => const WalletScreen()),
        GoRoute(
            path: '/bills', builder: (context, state) => const BillsScreen()),
        GoRoute(
            path: '/savings',
            builder: (context, state) => const SavingsScreen()),
        GoRoute(
            path: '/virtual-cards',
            builder: (context, state) => const VirtualCardsScreen()),
        GoRoute(
            path: '/merchants',
            builder: (context, state) => const MerchantsScreen()),
        GoRoute(
            path: '/donations',
            builder: (context, state) => const DonationsScreen()),
        GoRoute(
            path: '/cash-out',
            builder: (context, state) => const CashOutScreen()),
        GoRoute(
            path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen()),
        GoRoute(
            path: '/admin', builder: (context, state) => const AdminScreen()),
      ],
    );

    final theme = ThemeData(
      primarySwatch: Colors.blueGrey,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey)
          .copyWith(secondary: Colors.teal),
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: Colors.white,
    );

    return MaterialApp.router(
      title: 'zpay',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: ThemeData.dark().copyWith(
        colorScheme:
            ThemeData.dark().colorScheme.copyWith(primary: Colors.teal),
      ),
      routerConfig: _router,
    );
  }
}
