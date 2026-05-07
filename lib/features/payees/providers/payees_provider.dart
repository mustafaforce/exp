import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../data/repositories/payee_repository.dart';
import '../data/models/payee_model.dart';

final payeeRepositoryProvider = Provider<PayeeRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PayeeRepository(db);
});

final payeesProvider =
    AsyncNotifierProvider<PayeesNotifier, List<PayeeModel>>(
  PayeesNotifier.new,
);

class PayeesNotifier extends AsyncNotifier<List<PayeeModel>> {
  @override
  Future<List<PayeeModel>> build() async {
    final repo = ref.read(payeeRepositoryProvider);
    return repo.getAll();
  }

  Future<void> addPayee(PayeeModel payee) async {
    final repo = ref.read(payeeRepositoryProvider);
    await repo.insert(payee);
    ref.invalidateSelf();
  }

  Future<void> deletePayee(int id) async {
    final repo = ref.read(payeeRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}
