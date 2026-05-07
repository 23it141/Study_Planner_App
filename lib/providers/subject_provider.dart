import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/subject.dart';
import '../services/hive_service.dart';

final subjectRepositoryProvider = Provider((ref) => SubjectRepository());

final subjectsProvider = StateNotifierProvider<SubjectNotifier, List<Subject>>((ref) {
  return SubjectNotifier(ref.watch(subjectRepositoryProvider));
});

class SubjectNotifier extends StateNotifier<List<Subject>> {
  final SubjectRepository _repository;

  SubjectNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAll();
  }

  Future<void> addSubject(Subject subject) async {
    await _repository.add(subject);
    _load();
  }

  Future<void> updateSubject(Subject subject) async {
    await _repository.update(subject);
    _load();
  }

  Future<void> deleteSubject(String id) async {
    await _repository.delete(id);
    _load();
  }
}

class SubjectRepository {
  Box<Subject> get _box => HiveService.getSubjectsBox();

  List<Subject> getAll() => _box.values.toList();

  Future<void> add(Subject subject) async {
    await _box.put(subject.id, subject);
  }

  Future<void> update(Subject subject) async {
    await _box.put(subject.id, subject);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Stream<BoxEvent> watch() => _box.watch();
}
