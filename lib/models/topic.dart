import 'package:hive/hive.dart';

part 'topic.g.dart';

@HiveType(typeId: 1)
enum TopicStatus {
  @HiveField(0)
  notStarted,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
}

@HiveType(typeId: 2)
class Topic extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double estimatedHours;

  @HiveField(4)
  final TopicStatus status;

  @HiveField(5)
  final DateTime createdAt;

  Topic({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.estimatedHours,
    required this.status,
    required this.createdAt,
  });

  Topic copyWith({
    String? name,
    double? estimatedHours,
    TopicStatus? status,
  }) {
    return Topic(
      id: this.id,
      subjectId: this.subjectId,
      name: name ?? this.name,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      status: status ?? this.status,
      createdAt: this.createdAt,
    );
  }
}
