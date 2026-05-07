import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/expenses/presentation/screens/expense_list_screen.dart';
import 'features/insights/presentation/screens/insights_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/settings/providers/currency_provider.dart';
import 'features/settings/providers/theme_provider.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'core/providers/navigation_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(initCurrencyProvider);
    ref.watch(initThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final onboardingDone = ref.watch(onboardingDoneProvider);

    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: onboardingDone.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => const MainShell(),
        data: (done) => done ? const MainShell() : const OnboardingScreen(),
      ),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final _screens = const [
    HomeScreen(),
    ExpenseListScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(tabIndexProvider);
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          HapticFeedback.lightImpact();
          ref.read(tabIndexProvider.notifier).state = index;
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
