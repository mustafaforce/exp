import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/account_repository.dart';
import '../data/models/account_model.dart';

final accountsProvider =
    AsyncNotifierProvider<AccountsNotifier, List<AccountModel>>(
  AccountsNotifier.new,
);

final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
  return accounts.fold<double>(0, (sum, a) => sum + a.balance);
});

class AccountsNotifier extends AsyncNotifier<List<AccountModel>> {
  @override
  Future<List<AccountModel>> build() async {
    final repo = ref.read(accountRepositoryProvider);
    return repo.getAll();
  }

  Future<void> addAccount(AccountModel account) async {
    final repo = ref.read(accountRepositoryProvider);
    await repo.insert(account);
    ref.invalidateSelf();
  }

  Future<void> updateAccount(AccountModel account) async {
    final repo = ref.read(accountRepositoryProvider);
    await repo.update(account);
    ref.invalidateSelf();
  }

  Future<void> deleteAccount(int id) async {
    final repo = ref.read(accountRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}
