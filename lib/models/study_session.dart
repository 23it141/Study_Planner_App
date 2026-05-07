import 'package:hive/hive.dart';

part 'study_session.g.dart';

@HiveType(typeId: 3)
class StudySession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final String topicId;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final int durationMinutes;

  @HiveField(5)
  final String notes;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.topicId,
    required this.startTime,
    required this.durationMinutes,
    this.notes = '',
  });

  StudySession copyWith({
    DateTime? startTime,
    int? durationMinutes,
    String? notes,
  }) {
    return StudySession(
      id: this.id,
      subjectId: this.subjectId,
      topicId: this.topicId,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
    );
  }
}
