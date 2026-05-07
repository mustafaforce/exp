import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/tag_repository.dart';
import '../data/models/tag_model.dart';

final tagsProvider =
    AsyncNotifierProvider<TagsNotifier, List<TagModel>>(
  TagsNotifier.new,
);

class TagsNotifier extends AsyncNotifier<List<TagModel>> {
  @override
  Future<List<TagModel>> build() async {
    final repo = ref.read(tagRepositoryProvider);
    return repo.getAll();
  }

  Future<void> addTag(TagModel tag) async {
    final repo = ref.read(tagRepositoryProvider);
    await repo.insert(tag);
    ref.invalidateSelf();
  }

  Future<void> deleteTag(int id) async {
    final repo = ref.read(tagRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}
