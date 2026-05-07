import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/topic.dart';
import '../services/hive_service.dart';

final topicRepositoryProvider = Provider((ref) => TopicRepository());

final topicsProvider = StateNotifierProvider<TopicNotifier, List<Topic>>((ref) {
  return TopicNotifier(ref.watch(topicRepositoryProvider));
});

class TopicNotifier extends StateNotifier<List<Topic>> {
  final TopicRepository _repository;

  TopicNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAll();
  }

  Future<void> addTopic(Topic topic) async {
    await _repository.add(topic);
    _load();
  }

  Future<void> updateTopic(Topic topic) async {
    await _repository.update(topic);
    _load();
  }

  Future<void> deleteTopic(String id) async {
    await _repository.delete(id);
    _load();
  }
}

class TopicRepository {
  Box<Topic> get _box => HiveService.getTopicsBox();

  List<Topic> getAll() => _box.values.toList();

  List<Topic> getBySubject(String subjectId) {
    return _box.values.where((t) => t.subjectId == subjectId).toList();
  }

  Future<void> add(Topic topic) async {
    await _box.put(topic.id, topic);
  }

  Future<void> update(Topic topic) async {
    await _box.put(topic.id, topic);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Stream<BoxEvent> watch() => _box.watch();
}
