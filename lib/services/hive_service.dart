import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../models/study_session.dart';

class HiveService {
  static const String subjectsBoxName = 'subjects';
  static const String topicsBoxName = 'topics';
  static const String sessionsBoxName = 'sessions';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(TopicStatusAdapter());
    Hive.registerAdapter(TopicAdapter());
    Hive.registerAdapter(StudySessionAdapter());

    // Open Boxes
    await Hive.openBox<Subject>(subjectsBoxName);
    await Hive.openBox<Topic>(topicsBoxName);
    await Hive.openBox<StudySession>(sessionsBoxName);
  }

  static Box<Subject> getSubjectsBox() => Hive.box<Subject>(subjectsBoxName);
  static Box<Topic> getTopicsBox() => Hive.box<Topic>(topicsBoxName);
  static Box<StudySession> getSessionsBox() => Hive.box<StudySession>(sessionsBoxName);
}
