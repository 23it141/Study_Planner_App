import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/study_session.dart';
import '../services/hive_service.dart';

final sessionRepositoryProvider = Provider((ref) => StudySessionRepository());

final sessionsProvider = StateNotifierProvider<SessionNotifier, List<StudySession>>((ref) {
  return SessionNotifier(ref.watch(sessionRepositoryProvider));
});

class SessionNotifier extends StateNotifier<List<StudySession>> {
  final StudySessionRepository _repository;

  SessionNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    state = _repository.getAll();
  }

  Future<void> addSession(StudySession session) async {
    await _repository.add(session);
    _load();
  }

  Future<void> updateSession(StudySession session) async {
    await _repository.update(session);
    _load();
  }

  Future<void> deleteSession(String id) async {
    await _repository.delete(id);
    _load();
  }
}

class StudySessionRepository {
  Box<StudySession> get _box => HiveService.getSessionsBox();

  List<StudySession> getAll() => _box.values.toList();

  Future<void> add(StudySession session) async {
    await _box.put(session.id, session);
  }

  Future<void> update(StudySession session) async {
    await _box.put(session.id, session);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Stream<BoxEvent> watch() => _box.watch();
}
