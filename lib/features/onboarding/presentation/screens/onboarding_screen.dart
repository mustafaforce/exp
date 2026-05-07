import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/providers/currency_provider.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../accounts/providers/accounts_provider.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Currency step
  String _selectedCurrency = 'USD';

  // Account step
  final _accountNameController = TextEditingController(text: 'Cash');
  String _accountType = 'cash';
  final _balanceController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _accountNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    HapticFeedback.mediumImpact();

    // Save currency
    await changeCurrency(ref, _selectedCurrency);

    // Update or create first account
    final accounts = ref.read(accountsProvider).valueOrNull ?? [];
    final balance = double.tryParse(_balanceController.text.trim()) ?? 0.0;
    final name = _accountNameController.text.trim().isEmpty
        ? 'Cash'
        : _accountNameController.text.trim();

    if (accounts.isNotEmpty) {
      // Update the default account
      final first = accounts.first;
      final updated = first.copyWith(
        name: name,
        type: _accountType,
        balance: balance,
        currency: _selectedCurrency,
      );
      await ref.read(accountsProvider.notifier).updateAccount(updated);
    } else {
      // Create new account
      final account = AccountModel(
        name: name,
        type: _accountType,
        balance: balance,
        icon: _accountType,
        color: '#10B981',
        currency: _selectedCurrency,
        createdAt: DateTime.now().toIso8601String(),
      );
      await ref.read(accountsProvider.notifier).addAccount(account);
    }

    // Mark onboarding done
    await markOnboardingDone(ref);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(onNext: _nextPage),
                  _CurrencyPage(
                    selected: _selectedCurrency,
                    onSelect: (code) => setState(() => _selectedCurrency = code),
                    onNext: _nextPage,
                  ),
                  _AccountPage(
                    nameController: _accountNameController,
                    balanceController: _balanceController,
                    accountType: _accountType,
                    onTypeChanged: (t) => setState(() => _accountType = t),
                    currencySymbol: currencySymbolMap[_selectedCurrency] ?? '\$',
                    onFinish: _finish,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 1: Welcome ──────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Expense Tracker',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track spending, set budgets, and stay on top of your finances.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 2: Currency ─────────────────────────────────────────────

class _CurrencyPage extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;

  const _CurrencyPage({
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencies = currencySymbolMap.entries.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Choose your currency',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You can change this later in settings.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final entry = currencies[index];
                final isSelected = entry.key == selected;
                return GestureDetector(
                  onTap: () => onSelect(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.value,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.key,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Page 3: First Account ────────────────────────────────────────

class _AccountPage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController balanceController;
  final String accountType;
  final ValueChanged<String> onTypeChanged;
  final String currencySymbol;
  final Future<void> Function() onFinish;

  const _AccountPage({
    required this.nameController,
    required this.balanceController,
    required this.accountType,
    required this.onTypeChanged,
    required this.currencySymbol,
    required this.onFinish,
  });

  static const _types = [
    ('cash', Icons.money, 'Cash'),
    ('bank', Icons.account_balance, 'Bank'),
    ('credit_card', Icons.credit_card, 'Credit Card'),
    ('savings', Icons.savings, 'Savings'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Set up your account',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add your primary account to start tracking.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Account type selector
            Text('Type', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((t) {
                final isSelected = accountType == t.$1;
                return GestureDetector(
                  onTap: () => onTypeChanged(t.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.$2,
                            size: 16,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          t.$3,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Account name
            Text('Name', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Cash, Main Bank',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              style: theme.textTheme.titleMedium,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),

            // Initial balance
            Text('Starting balance', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: balanceController,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                prefixText: '$currencySymbol ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 32),

            // Finish button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onFinish,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Start Tracking'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
